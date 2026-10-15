import pc from "picocolors";
import { appInstalled } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

const HELP = `${pc.bold(pc.cyan("Ghostty keybindings:"))}
  Cmd+Shift+Click    Open URL (required inside tmux)
  Cmd+Click          Open URL (only works outside tmux)
  Cmd+D              Split right
  Cmd+Shift+D        Split down
  Cmd+Shift+Enter    Toggle fullscreen
  Cmd+Shift+,        Open config

${pc.bold(pc.cyan("Config:"))}
  copy-on-select = clipboard  (selecting text copies it automatically)

${pc.bold(pc.cyan("Known issues:"))}
  Right-click menu in tmux is broken (follows cursor)
    https://github.com/ghostty-org/ghostty/discussions/5362
  Cmd+Click in tmux requires Shift workaround
    https://github.com/ghostty-org/ghostty/issues/11573`;

// Ghostty terminal (https://ghostty.org). No Windows build.
export default defineModule({
  id: "ghostty",
  installed: appInstalled({ bins: ["ghostty"], mac: "Ghostty" }),
  install: {
    darwin: { via: "brew", pkg: "ghostty", cask: true },
  },
  os: ["linux", "darwin"],
  links: [{ from: "config", to: { linux: "~/.config/ghostty/config", darwin: "config:com.mitchellh.ghostty/config" } }],
  commands: { "ghostty-help": { desc: "Ghostty tips and workarounds", run: async () => void console.log(HELP) } },
  async setup(ctx) {
    // Ubuntu has no ghostty package: it comes from the mkasberg PPA
    if (ctx.os === "linux" && !ctx.has("ghostty")) {
      await ctx.sudo(["add-apt-repository", "-y", "ppa:mkasberg/ghostty-ubuntu"]);
      await ctx.sudo(["apt-get", "update", "-qq"]);
      if ((await ctx.sudo(["apt-get", "install", "-y", "-qq", "ghostty"])) !== 0) throw new Error("apt install ghostty failed");
    }
  },
});
