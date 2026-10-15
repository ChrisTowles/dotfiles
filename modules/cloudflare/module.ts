import { rmSync } from "node:fs";
import { join } from "node:path";
import { defineModule } from "../../lib/module";

// The Cloudflare CLI (https://blog.cloudflare.com/cf-cli-local-explorer/), npm
// package `cf`. Technical preview, positioned as the next Wrangler. NOT flarectl.
// The binary is `cf`, but that name is the claude-fable alias, so this CLI is
// `cloudflare`. Auth is interactive: `cloudflare auth login`.
export default defineModule({
  id: "cloudflare",
  needs: ["pnpm"],
  bin: "cf",
  install: {
    linux: { via: "pnpm-global", pkg: "cf" },
    darwin: { via: "pnpm-global", pkg: "cf" },
    win32: { via: "pnpm-global", pkg: "cf" },
  },
  aliases: {
    cloudflare: { zsh: "command cf", pwsh: "& (Get-Command cf -CommandType Application | Select-Object -First 1)" },
  },
  async setup(ctx) {
    if (ctx.os === "win32") return;
    // `cf complete zsh` hardcodes `cf` as the command it completes and in its
    // `cf complete -- ...` candidate calls. Retarget both at `cloudflare` / `command cf`.
    const r = await ctx.read(["cf", "complete", "zsh"]);
    if (r.code !== 0) return ctx.log("cf completions skipped");
    const text = r.stdout
      .replace(/^#compdef cf$/m, "#compdef cloudflare")
      .replace(/^compdef _cf cf$/m, "compdef _cf cloudflare")
      .replace(/^( *requestComp=)"cf complete -- /m, '$1"command cf complete -- ');
    await ctx.write(join(ctx.home, ".zsh", "completions", "_cf"), text);
    // compinit caches #compdef mappings in ~/.zcompdump; drop it so the retarget is seen
    if (!ctx.dryRun) rmSync(join(process.env.ZDOTDIR ?? ctx.home, ".zcompdump"), { force: true });
  },
});
