#!/usr/bin/env bun

import { readFileSync, writeFileSync, mkdirSync } from "fs";
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
};

// --- Auto-update for all marketplaces ---

const marketplaces = [
  "skills",
  "claude-plugins-official",
  "towles-tool",
  "superpowers-marketplace",
  "compound-engineering-plugin",
  "trailofbits",
];

settings.extraKnownMarketplaces ??= {};
for (const name of marketplaces) {
  if (settings.extraKnownMarketplaces[name]) {
    settings.extraKnownMarketplaces[name].autoUpdate = true;
  }
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
  "superpowers@superpowers-marketplace",
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

const enabled = settings.enabledPlugins ?? {};
for (const plugin of plugins) {
  if (plugin in enabled) continue;
  console.log(` Installing Claude plugin: ${plugin}`);
  Bun.spawnSync(["claude", "plugin", "install", plugin], { stdio: ["ignore", "inherit", "inherit"] });
}

// --- Symlink CLAUDE.md ---

import { lstatSync, renameSync, symlinkSync, readdirSync } from "fs";

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

ensureSymlink(claudeMdSrc, claudeMdDest);

// --- Symlink rules ---

const rulesSrc = join(configSrc, "rules");
const rulesDest = join(process.env.HOME!, ".claude", "rules");
mkdirSync(rulesDest, { recursive: true });

for (const file of readdirSync(rulesSrc).filter((f) => f.endsWith(".md"))) {
  ensureSymlink(join(rulesSrc, file), join(rulesDest, file));
}