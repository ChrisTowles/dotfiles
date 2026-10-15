import { existsSync, readFileSync, realpathSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { defineModule } from "../../lib/module";

// MCP servers at user scope (stored in ~/.claude.json, not settings.json)
const MCPS: Record<string, string[]> = {
  "chrome-devtools": ["bunx", "chrome-devtools-mcp@latest", "--autoConnect"],
};

// Claude Code CLI. The c/cr/cf/… aliases run `ttd claude <variant>`, which
// restores the terminal after claude exits (see variants.ts).
export default defineModule({
  id: "claude",
  install: {
    linux: { via: "script", url: "https://claude.ai/install.sh", shell: "bash" },
    darwin: { via: "script", url: "https://claude.ai/install.sh", shell: "bash" },
    win32: { via: "script", url: "https://claude.ai/install.ps1" },
  },
  path: ["~/.local/bin"],
  // Fullscreen rendering: flicker-free alternate screen buffer with mouse support
  // https://code.claude.com/docs/en/fullscreen
  env: { CLAUDE_CODE_NO_FLICKER: "1", CLAUDE_CODE_NEW_INIT: "1" },
  // claude has no built-in generator; parsed from --help each setup so they track CLI changes
  completions: [{ shell: "zsh", argv: ["ttd-gen-completions", "claude"], name: "_claude" }],
  aliases: {
    // c/ca: Opus at high effort. cr: resume, no model/effort override (keeps the resumed session's own settings).
    // co/cor: Opus, explicit (cor overrides model/effort on resume, unlike cr).
    // cs/csr: Sonnet at high effort. cf/cfr: Fable at medium effort. cfa/cfar: Fable at xhigh ("architect").
    // cf shadows the Cloudflare CLI binary of the same name; that CLI is `cloudflare` (modules/cloudflare).
    c: "ttd claude opus",
    cr: "ttd claude resume",
    ca: "ttd claude opus agents",
    co: "ttd claude opus",
    cor: "ttd claude opus --resume",
    cs: "ttd claude sonnet",
    csr: "ttd claude sonnet --resume",
    cf: "ttd claude fable",
    cfr: "ttd claude fable --resume",
    cfa: "ttd claude architect",
    cfar: "ttd claude architect --resume",
    cprompts: { zsh: "claude-prompts" },
  },
  async setup(ctx) {
    // Marketplaces, settings, hooks, CLAUDE.md, plugins, rules
    if ((await ctx.exec([process.execPath, "run", join(ctx.dir, "setup-settings.ts")])) !== 0) throw new Error("setup-settings.ts failed");

    let configured: Record<string, unknown> = {};
    try {
      configured = JSON.parse(readFileSync(join(ctx.home, ".claude.json"), "utf8")).mcpServers ?? {};
    } catch {}
    for (const [name, argv] of Object.entries(MCPS)) {
      if (name in configured) continue;
      ctx.log(`adding MCP server (user): ${name}`);
      await ctx.exec(["claude", "mcp", "add", "-s", "user", name, "--", ...argv]);
    }

    // claude-in-chrome native host: point it at the resolved binary so it survives version updates
    const host = join(ctx.home, ".claude", "chrome", "chrome-native-host");
    const bin = join(ctx.home, ".local", "bin", "claude");
    if (ctx.os !== "win32" && existsSync(host) && existsSync(bin)) {
      const target = realpathSync(bin);
      const text = readFileSync(host, "utf8");
      const fixed = text.replace(/exec "[^"]*"/, `exec "${target}"`);
      if (fixed !== text) {
        ctx.log(`fixing claude-in-chrome native host -> ${target}`);
        if (!ctx.dryRun) writeFileSync(host, fixed);
      }
    }
  },
});
