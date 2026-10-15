import { defineModule } from "../../lib/module";

// Karabiner-Elements keyboard remapping (macOS only): PC-style Ctrl shortcuts, home/end keys
export default defineModule({
  id: "karabiner",
  install: { darwin: { via: "brew", pkg: "karabiner-elements", cask: true, app: "Karabiner-Elements" } },
  links: [{ from: "config", to: "~/.config/karabiner" }],
});
