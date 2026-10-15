import { defineModule } from "../../lib/module";
import { appInstalled } from "../../lib/helpers";

// Karabiner-Elements keyboard remapping (macOS only): PC-style Ctrl shortcuts, home/end keys
export default defineModule({
  id: "karabiner",
  installed: appInstalled({ mac: "Karabiner-Elements" }),
  install: { darwin: { via: "brew", pkg: "karabiner-elements", cask: true } },
  links: [{ from: "config", to: "~/.config/karabiner" }],
});
