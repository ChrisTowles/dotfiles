import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { gitCloneOrPull } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

const PLUGINS: Record<string, string> = {
  "zsh-autosuggestions": "https://github.com/zsh-users/zsh-autosuggestions",
  "zsh-completions": "https://github.com/zsh-users/zsh-completions.git",
  "zsh-history-substring-search": "https://github.com/zsh-users/zsh-history-substring-search.git",
  "zsh-z": "https://github.com/agkozak/zsh-z.git",
  "fast-syntax-highlighting": "https://github.com/zdharma-continuum/fast-syntax-highlighting.git",
};

export default defineModule({
  id: "zsh",
  os: ["linux", "darwin"],
  install: { linux: { via: "apt", pkg: "zsh" } },
  links: [{ from: "zshrc", to: "~/.zshrc" }],
  aliases: {
    // exec replaces the shell process cleanly; `source ~/.zshrc` can leave stale state
    ez: "exec zsh",
    "ez-setup": "ttd setup && exec zsh",
    "zsh-dotfiles-setup": "ttd setup && exec zsh",
    "zsh-load": "ZSH_DEBUG_TIMING=1 exec zsh",
    "zsh-dotfiles-help": "ttd help",
    // Bare `history` only shows the last ~16 events — `histall | grep x` searches the whole file
    histall: "fc -il 1",
  },
  async setup(ctx) {
    if (!ctx.dryRun) mkdirSync(join(ctx.home, ".zsh", "completions"), { recursive: true });
    for (const [name, url] of Object.entries(PLUGINS)) await gitCloneOrPull(ctx, url, join(ctx.home, ".zsh", name));
    if (!(process.env.SHELL ?? "").endsWith("/zsh")) {
      const zsh = Bun.which("zsh");
      if (zsh) await ctx.sudo(["chsh", "-s", zsh, process.env.USER ?? ""]);
    }
  },
});
