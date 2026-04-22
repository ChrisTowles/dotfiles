#!/usr/bin/env bun

import { readFileSync, writeFileSync, mkdirSync, lstatSync, renameSync, symlinkSync, readdirSync } from "fs";
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
  "discord@claude-plugins-official",
  "tt@towles-tool",
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
  "document-skills@anthropic-agent-skills",
];

// Plugins to remove. Move entries here from `plugins` to uninstall on next setup.
const uninstallPlugins = [
  "superpowers@superpowers-marketplace",
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