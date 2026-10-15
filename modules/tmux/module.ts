import { join } from "node:path";
import pc from "picocolors";
import { gitCloneOrPull } from "../../lib/helpers";
import { defineModule } from "../../lib/module";
import { TMUX_HELP } from "./help";

// tmux - terminal multiplexer (Linux and macOS; no Windows build)
export default defineModule({
  id: "tmux",
  install: {
    linux: { via: "apt", pkg: "tmux" },
    darwin: { via: "brew", pkg: "tmux" },
  },
  links: [{ from: "tmux.conf", to: "xdg:tmux/tmux.conf" }],
  commands: {
    "tmux-help": {
      desc: "Print the tmux aliases and keybindings",
      async run() {
        console.log(TMUX_HELP.trim().replace(/^── .* ──$/gm, (l) => pc.bold(pc.cyan(l))));
      },
    },
  },
  async setup(ctx) {
    // macOS /bin/bash is 3.2, which lacks associative arrays — tmux plugins need bash 4+
    if (ctx.os === "darwin" && !(await Bun.file("/opt/homebrew/bin/bash").exists())) await ctx.exec(["brew", "install", "bash"]);
    // TPM (tmux plugin manager) in the XDG config dir, then install and update plugins
    const tpm = join(ctx.home, ".config", "tmux", "plugins", "tpm");
    await gitCloneOrPull(ctx, "https://github.com/tmux-plugins/tpm", tpm);
    await ctx.exec([join(tpm, "bin", "install_plugins")]);
    await ctx.exec([join(tpm, "bin", "update_plugins"), "all"]);
  },
});
