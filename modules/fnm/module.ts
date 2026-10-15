import { defineModule } from "../../lib/module";

// fnm - Fast Node Manager (https://github.com/Schniz/fnm)
export default defineModule({
  id: "fnm",
  install: {
    unix: { via: "script", url: "https://fnm.vercel.app/install", shell: "bash", args: ["--skip-shell"] },
    win32: { via: "winget", id: "Schniz.fnm" },
  },
  env: { FNM_PATH: { unix: "~/.local/share/fnm" } },
  path: [{ unix: "~/.local/share/fnm" }],
  completions: [
    { shell: "zsh", argv: ["fnm", "completions", "--shell", "zsh"], name: "_fnm" },
    { shell: "pwsh", argv: ["fnm", "completions", "--shell", "power-shell"], name: "fnm" },
  ],
  async setup(ctx) {
    // Latest LTS node; corepack gives projects the pnpm/yarn their packageManager field asks for
    await ctx.exec(["fnm", "install", "--lts"]);
    await ctx.exec(["fnm", "default", "lts-latest"]);
    await ctx.exec(["fnm", "exec", "--using=default", "corepack", "enable"]);
  },
});
