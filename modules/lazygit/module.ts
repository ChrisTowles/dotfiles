import { defineModule } from "../../lib/module";

// lazygit - terminal UI for git. Its `c` key runs `ttd git-ai-commit` (config.yml).
export default defineModule({
  id: "lazygit",
  needs: ["gh"],
  install: {
    linux: { via: "gh-release", repo: "jesseduffield/lazygit", asset: "lazygit_*_linux_x86_64.tar.gz", bins: ["lazygit"] },
    darwin: { via: "brew", pkg: "lazygit" },
    win32: { via: "winget", id: "JesseDuffield.lazygit" },
  },
  links: [{ from: "config.yml", to: "config:lazygit/config.yml" }],
  aliases: { g: "lazygit" },
});
