#!/usr/bin/env bun

import { readFileSync, writeFileSync, mkdirSync, lstatSync, renameSync, symlinkSync, readdirSync, existsSync } from "fs";
import { join, dirname } from "path";

const configSrc = dirname(Bun.main);
const settingsFile = join(process.env.HOME!, ".claude", "settings.json");

mkdirSync(dirname(settingsFile), { recursive: true });

let settings: Record<string, any> = {};
try {
  settings = JSON.parse(readFileSync(settingsFile, "utf8"));
} catch {}

settings.voiceEnabled = true;

settings.statusLine = {
  type: "command",
  command: `bun run ${configSrc}/statusline.ts`,
};

settings.teammateMode = "in-process";

settings.env = {
  ...settings.env,
  CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1",
};

// MCP servers are managed via `claude mcp add` (stored in ~/.claude.json),
// not in settings.json. See 60-claude-code.sh for the setup.

settings.hooks = {
  ...settings.hooks,
  Notification: [
    {
      matcher: "",
      hooks: [
        {
          type: "command",
          command: `bun run ${configSrc}/notify.ts`,
        },
      ],
    },
  ],
  Stop: [
    {
      hooks: [
        {
          type: "command",
          command: `bun run ${configSrc}/stop-guard.ts`,
        },
      ],
    },
  ],
};

type Install =
  | { kind: "github_marketplace"; name: string; marketplace: string }
  // `frontmatter` overrides keys in the installed SKILL.md; a null value deletes
  // the key. Re-applied after every copy, since skills.sh restores upstream.
  | { kind: "npm_skills_single"; name: string; repo: string; frontmatter?: Record<string, string | null> }
  | { kind: "npm_skills_plugin"; repo: string };


// --- Marketplaces ---

// [repo, registered marketplace name]. Name comes from each marketplace.json's `name` field
// and is not always the repo basename (e.g. anthropics/skills → anthropic-agent-skills).
const marketplaces: [string, string][] = [
  ["anthropics/claude-plugins-official", "claude-plugins-official"],
  ["anthropics/skills", "anthropic-agent-skills"],
  ["anthropics/knowledge-work-plugins", "knowledge-work-plugins"],
  ["ChrisTowles/towles-tool-rs", "towles-tool"],
  ["backnotprop/plannotator", "plannotator"],
];



type Uninstall = Exclude<Install, { kind: "npm_skills_plugin" }>;

const installs: Install[] = [
  { kind: "github_marketplace", name: "typescript-lsp",       marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "claude-md-management", marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "frontend-design",      marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "plugin-dev",           marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "skill-creator",        marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "tt",                   marketplace: "towles-tool" },
  { kind: "github_marketplace", name: "towles-tool-app",      marketplace: "towles-tool" },
  { kind: "github_marketplace", name: "document-skills",      marketplace: "anthropic-agent-skills" },
  { kind: "github_marketplace", name: "humanizer",            marketplace: "humanizer" },
  { kind: "github_marketplace", name: "code-simplifier",      marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "data",                 marketplace: "knowledge-work-plugins" },
  { kind: "github_marketplace", name: "plannotator",          marketplace: "plannotator" },
  // Just the one skill, not the whole mattpocock/skills bundle (~40 skills, several
  // of which assume his ticket/spec workflow). Installs globally so it is always on.
  {
    kind: "npm_skills_single", name: "writing-great-skills", repo: "mattpocock/skills",
    // Upstream ships it user-invoked only (`disable-model-invocation`), which also
    // walls it off from other skills. We want it to fire on its own, so drop the
    // flag and swap the human-facing description for a trigger-bearing one.
    frontmatter: {
      "disable-model-invocation": null,
      description:
        "Vocabulary and principles for writing predictable agent skills. Use when writing a new skill, editing or pruning an existing one, or diagnosing a skill that fires unreliably, sprawls, or stops early.",
    },
  },
];

// Move entries here from `installs` to remove them on next setup.
const uninstalls: Uninstall[] = [
  { kind: "github_marketplace", name: "superpowers",                    marketplace: "superpowers-marketplace" },
  { kind: "github_marketplace", name: "discord",                        marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "feature-dev",                    marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "hookify",                        marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "postman",                        marketplace: "claude-plugins-official" },
  { kind: "github_marketplace", name: "compound-engineering",           marketplace: "compound-engineering-plugin" },
];

// Marketplaces to remove. Move entries here from `marketplaces` to uninstall on next setup.
// Also use this for a same-name repo swap (e.g. towles-tool -> towles-tool-rs): the
// `existsSync` check below only keys on the registered name, so if a name already
// points at an old repo it will never be refreshed to the new source unless removed
// first. Removal runs before the add loop so the swap completes in a single run.
// Clear this after that run: removing a marketplace uninstalls every plugin it
// owns, so leaving an entry here re-clones it and drops those plugins on each
// setup — only the ones listed in `installs` come back.
const uninstallMarketplaces: string[] = [];

const marketplacesDir = join(process.env.HOME!, ".claude", "plugins", "marketplaces");

// `bun run` prepends node_modules/.bin to PATH. A stale @anthropic-ai/claude-code
// there leaves a shebang-less `claude` stub that every spawn below resolves to
// first and dies on with ENOEXEC, taking the whole setup with it. Resolve the real
// CLI against a PATH with those entries stripped.
const resolvedClaude = Bun.which("claude", {
  PATH: (process.env.PATH ?? "").split(":").filter((p) => !p.endsWith("node_modules/.bin")).join(":"),
});
if (!resolvedClaude) throw new Error("claude CLI not found on PATH — install it before running setup");
const claudeBin: string = resolvedClaude;

for (const name of uninstallMarketplaces) {
  const result = Bun.spawnSync([claudeBin, "plugin", "marketplace", "remove", name], { stdout: "pipe", stderr: "pipe" });
  if (result.success) {
    console.log(` Removed Claude marketplace: ${name}`);
  } else {
    console.log(` Claude marketplace already removed: ${name}`);
  }
}

for (const [repo, name] of marketplaces) {
  if (existsSync(join(marketplacesDir, name))) {
    console.log(` Claude marketplace already added: ${name}`);
  } else {
    console.log(` Adding Claude marketplace: ${repo}`);
    Bun.spawnSync([claudeBin, "plugin", "marketplace", "add", repo], { stdio: ["ignore", "inherit", "inherit"] });
  }
}

// --- Auto-update for all marketplaces ---

settings.extraKnownMarketplaces ??= {};
for (const name of Object.keys(settings.extraKnownMarketplaces)) {
  settings.extraKnownMarketplaces[name].autoUpdate = true;
}

writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + "\n");

// --- Install plugins and npm skills ---
// `npm_skills_plugin` has no uninstall counterpart by design: a wildcard-remove
// would clobber every user skill, not just this repo's. To stop tracking a
// bundle, delete the entry here; if you also want the files gone, list the
// specific names (as `npm_skills_single`) in `uninstalls` for one setup cycle.


function describe(item: Install): string {
  switch (item.kind) {
    case "github_marketplace":  return `${item.name}@${item.marketplace}`;
    case "npm_skills_single":   return `${item.name} (from ${item.repo})`;
    case "npm_skills_plugin":   return `all skills from ${item.repo}`;
  }
}

// skills.sh copies upstream files verbatim on every run, so a local override has
// to be re-applied after each copy or it silently reverts on the next setup.
function patchFrontmatter(skill: string, patch: Record<string, string | null>): void {
  const file = join(process.env.HOME!, ".claude", "skills", skill, "SKILL.md");
  const text = readFileSync(file, "utf8");
  const match = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) throw new Error(`No frontmatter to patch in ${file}`);

  const lines = match[1].split("\n");
  for (const [key, value] of Object.entries(patch)) {
    const i = lines.findIndex((line) => line.startsWith(`${key}:`));
    if (value === null) {
      if (i !== -1) lines.splice(i, 1);
    } else if (i === -1) {
      lines.push(`${key}: ${value}`);
    } else {
      lines[i] = `${key}: ${value}`;
    }
  }

  const patched = `---\n${lines.join("\n")}\n---\n` + text.slice(match[0].length);
  if (patched === text) {
    console.log(`   Frontmatter already patched: ${skill}`);
    return;
  }
  writeFileSync(file, patched);
  console.log(`   Patched frontmatter: ${skill}`);
}

function install(item: Install): void {
  switch (item.kind) {
    case "github_marketplace": {
      console.log(` Installing/updating Claude plugin: ${describe(item)}`);
      Bun.spawnSync(
        [claudeBin, "plugin", "install", `${item.name}@${item.marketplace}`],
        { stdio: ["ignore", "inherit", "inherit"] },
      );
      return;
    }
    case "npm_skills_single": {
      console.log(` Installing/updating npm skill: ${describe(item)}`);
      Bun.spawnSync(
        ["bunx", "skills@latest", "add", item.repo, "-g", "-a", "claude-code", "-s", item.name, "-y"],
        { stdio: ["ignore", "inherit", "inherit"] },
      );
      if (item.frontmatter) patchFrontmatter(item.name, item.frontmatter);
      return;
    }
    case "npm_skills_plugin": {
      console.log(` Installing/updating npm skills plugin: ${describe(item)}`);
      Bun.spawnSync(
        ["bunx", "skills@latest", "add", item.repo, "-g", "-a", "claude-code", "-s", "*", "-y"],
        { stdio: ["ignore", "inherit", "inherit"] },
      );
      return;
    }
  }
}

function uninstall(item: Uninstall): void {
  const { argv, label } = item.kind === "github_marketplace"
    ? { argv: [claudeBin, "plugin", "uninstall", `${item.name}@${item.marketplace}`], label: "Claude plugin" }
    : { argv: ["bunx", "skills@latest", "remove", item.name, "-g", "-a", "claude-code", "-y"], label: "npm skill" };
  const result = Bun.spawnSync(argv, { stdout: "pipe", stderr: "pipe" });
  console.log(result.success
    ? ` Uninstalled ${label}: ${describe(item)}`
    : ` ${label} already uninstalled: ${describe(item)}`);
}

for (const item of uninstalls) uninstall(item);
for (const item of installs) install(item);

// --- Symlink CLAUDE.md ---

const claudeMdSrc = join(configSrc, "global-claude-md.md");
const claudeMdDest = join(process.env.HOME!, ".claude", "CLAUDE.md");

function ensureSymlink(src: string, dest: string) {
  try {
    const stat = lstatSync(dest);
    if (!stat.isSymbolicLink()) {
      renameSync(dest, dest + `.${new Date().toISOString().slice(0, 10)}.bak`);
      symlinkSync(src, dest);
    }
  } catch {
    symlinkSync(src, dest);
  }
}

// Skip on macOS: work Mac uses a work-focused CLAUDE.md managed in ~/code/p/toolbox.
// Linux (home) still gets the dotfiles-managed global CLAUDE.md.
if (process.platform !== "darwin") {
  ensureSymlink(claudeMdSrc, claudeMdDest);
}

// --- Symlink rules ---

const rulesSrc = join(configSrc, "rules");
const rulesDest = join(process.env.HOME!, ".claude", "rules");
mkdirSync(rulesDest, { recursive: true });

for (const file of readdirSync(rulesSrc).filter((f) => f.endsWith(".md"))) {
  ensureSymlink(join(rulesSrc, file), join(rulesDest, file));
}