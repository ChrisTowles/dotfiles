import { defineModule } from "../../lib/module";

// bun - JavaScript runtime & toolkit (https://bun.sh). The bootstrap installs
// it first; this module keeps it on PATH and installs the repo's own packages.
export default defineModule({
  id: "bun",
  install: {
    linux: { via: "script", url: "https://bun.sh/install", shell: "bash" },
    darwin: { via: "script", url: "https://bun.sh/install", shell: "bash" },
    win32: { via: "script", url: "https://bun.sh/install.ps1" },
  },
  env: { BUN_INSTALL: "~/.bun" },
  path: ["~/.bun/bin"],
  completions: [{ shell: "zsh", argv: ["bun", "completions"], name: "_bun" }],
  async setup(ctx) {
    await ctx.exec(["bun", "install", "--cwd", ctx.repo]);
  },
});
