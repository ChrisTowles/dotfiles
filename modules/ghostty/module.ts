import pc from "picocolors";
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
  install: {
    // Ubuntu has no ghostty package: it comes from the mkasberg PPA
    linux: { via: "apt", pkg: "ghostty", repo: { ppa: "mkasberg/ghostty-ubuntu" } },
    darwin: { via: "brew", pkg: "ghostty", cask: true, app: "Ghostty" },
  },
  links: [{ from: "config", to: { linux: "~/.config/ghostty/config", darwin: "config:com.mitchellh.ghostty/config" } }],
  commands: { "ghostty-help": { desc: "Ghostty tips and workarounds", run: async () => void console.log(HELP) } },
});
