import { defineModule } from "../../lib/module";

// pnpm comes from corepack (enabled by the fnm module), so there is no install step.
export default defineModule({
  id: "pnpm",
  needs: ["fnm"],
  env: { PNPM_HOME: { linux: "~/.local/share/pnpm", darwin: "~/.local/share/pnpm" } },
  path: [{ linux: "~/.local/share/pnpm", darwin: "~/.local/share/pnpm" }],
  completions: [{ shell: "zsh", argv: ["pnpm", "completion", "zsh"], name: "_pnpm" }],
  commands: {
    "pnpm-install-global": {
      desc: "Install the global pnpm packages (tsx, @antfu/ni)",
      run: async (ctx) => ctx.exec(["pnpm", "install", "--global", "tsx", "@antfu/ni"]),
    },
  },
  async setup(ctx) {
    if (!ctx.has("pnpm")) return ctx.notice("pnpm not found — make sure corepack is enabled (corepack enable)");
    await ctx.exec(["pnpm", "install", "--global", "tsx", "@antfu/ni"]);
  },
});
