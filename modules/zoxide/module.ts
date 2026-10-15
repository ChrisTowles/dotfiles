import { defineModule } from "../../lib/module";

// zoxide - frecent `z` for pwsh. Linux and macOS keep the zsh-z plugin (modules/zsh).
export default defineModule({
  id: "zoxide",
  install: { win32: { via: "winget", id: "ajeetdsouza.zoxide" } },
  capture: { pwsh: ["zoxide", "init", "powershell"] },
});
