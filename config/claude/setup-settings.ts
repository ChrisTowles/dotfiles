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

settings.teammateMode = "tmux";

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

// --- Marketplaces ---

// [repo, registered marketplace name]. Name comes from each marketplace.json's `name` field
// and is not always the repo basename (e.g. anthropics/skills → anthropic-agent-skills).
const marketplaces: [string, string][] = [
  ["anthropics/claude-plugins-official", "claude-plugins-official"],
  ["anthropics/skills", "anthropic-agent-skills"],
  ["ChrisTowles/towles-tool", "towles-tool"],
  ["EveryInc/compound-engineering-plugin", "compound-engineering-plugin"],
  ["trailofbits/skills", "trailofbits"],
];

// Marketplaces to remove. Move entries here from `marketplaces` to uninstall on next setup.
const uninstallMarketplaces: string[] = [];

const marketplacesDir = join(process.env.HOME!, ".claude", "plugins", "marketplaces");

for (const [repo, name] of marketplaces) {
  if (existsSync(join(marketplacesDir, name))) {
    console.log(` Claude marketplace already added: ${name}`);
  } else {
    console.log(` Adding Claude marketplace: ${repo}`);
    Bun.spawnSync(["claude", "plugin", "marketplace", "add", repo], { stdio: ["ignore", "inherit", "inherit"] });
  }
}

for (const name of uninstallMarketplaces) {
  const result = Bun.spawnSync(["claude", "plugin", "marketplace", "remove", name], { stdout: "pipe", stderr: "pipe" });
  if (result.success) {
    console.log(` Removed Claude marketplace: ${name}`);
  } else {
    console.log(` Claude marketplace already removed: ${name}`);
  }
}

// --- Auto-update for all marketplaces ---

settings.extraKnownMarketplaces ??= {};
for (const name of Object.keys(settings.extraKnownMarketplaces)) {
  settings.extraKnownMarketplaces[name].autoUpdate = true;
}

writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + "\n");

// --- Install plugins ---

const plugins = [
  "typescript-lsp@claude-plugins-official",
  "claude-md-management@claude-plugins-official",
  "frontend-design@claude-plugins-official",
  "plugin-dev@claude-plugins-official",
  "skill-creator@claude-plugins-official",
  "tt@towles-tool",
  "document-skills@anthropic-agent-skills",
];

// Plugins to remove. Move entries here from `plugins` to uninstall on next setup.
const uninstallPlugins = [
  "superpowers@superpowers-marketplace",
  "discord@claude-plugins-official",
  "feature-dev@claude-plugins-official",
  "hookify@claude-plugins-official",
  "postman@claude-plugins-official",
  "code-simplifier@claude-plugins-official",
  "compound-engineering@compound-engineering-plugin",
  "ask-questions-if-underspecified@trailofbits",
  "gh-cli@trailofbits",
  "git-cleanup@trailofbits",
  "insecure-defaults@trailofbits",
  "let-fate-decide@trailofbits",
  "sharp-edges@trailofbits",
  "skill-improver@trailofbits",
  "supply-chain-risk-auditor@trailofbits",
  "workflow-skill-design@trailofbits",
];

for (const plugin of uninstallPlugins) {
  const result = Bun.spawnSync(["claude", "plugin", "uninstall", plugin], { stdout: "pipe", stderr: "pipe" });
  if (result.success) {
    console.log(` Uninstalled Claude plugin: ${plugin}`);
  } else {
    console.log(` Claude plugin already uninstalled: ${plugin}`);
  }
}

for (const plugin of plugins) {
  console.log(` Installing/updating Claude plugin: ${plugin}`);
  Bun.spawnSync(["claude", "plugin", "install", plugin], { stdio: ["ignore", "inherit", "inherit"] });
}

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