import { defineModule } from "../../lib/module";

// broot - tree view + fuzzy search in one navigator (https://dystroy.org/broot)
export default defineModule({
  id: "broot",
  needs: ["rust"],
  install: {
    linux: { via: "cargo", crate: "broot", locked: true },
    darwin: { via: "brew", pkg: "broot" },
    win32: { via: "winget", id: "Dystroy.broot" },
  },
  // broot checks BROOT_CONFIG_DIR before any platform default, so no link is needed
  env: { BROOT_CONFIG_DIR: "{repo}/modules/broot" },
  async setup(ctx) {
    // On its first run broot appends a `source .../launcher/bash/br` line to
    // ~/.zshrc and ~/.bashrc. Declaring the launcher installed suppresses that;
    // the `br` in init.zsh is our copy, in git.
    await ctx.read(["broot", "--set-install-state", "installed"]);
  },
});
