import { defineModule } from "../../lib/module";

const FD_EXCLUDES = [
  ".git", "node_modules", ".cache", ".npm", ".pnpm-store", ".bun", ".next", ".nuxt", ".turbo", "dist",
  ".output", "coverage", "target", ".venv", "__pycache__", ".trash", ".Trash", ".docker",
].map((d) => `--exclude ${d}`).join(" ");

// fzf - fuzzy finder. Ctrl+T: paste files/dirs, Ctrl+R: history, Alt+C: cd into dir
export default defineModule({
  id: "fzf",
  needs: ["fd", "gh"],
  install: {
    linux: { via: "gh-release", repo: "junegunn/fzf", asset: "fzf-*-linux_amd64.tar.gz", bins: ["fzf"] },
    darwin: { via: "brew", pkg: "fzf" },
    win32: { via: "winget", id: "junegunn.fzf" },
  },
  env: {
    FD_EXCLUDES,
    FZF_DEFAULT_COMMAND: `fd --type f --hidden --follow ${FD_EXCLUDES}`,
    FZF_CTRL_T_COMMAND: `fd --type f --hidden --follow ${FD_EXCLUDES}`,
    FZF_ALT_C_COMMAND: `fd --type d --hidden --follow ${FD_EXCLUDES}`,
  },
  // Static: the key bindings and completion, pasted into the init at gen time
  capture: { zsh: ["fzf", "--zsh"] },
  async setup(ctx) {
    // pwsh key bindings (Ctrl+T, Ctrl+R) come from the PSFzf module
    if (ctx.os === "win32")
      await ctx.exec(["pwsh", "-NoProfile", "-Command", "if (-not (Get-Module -ListAvailable PSFzf)) { Install-Module PSFzf -Scope CurrentUser -Force }"]);
  },
});
