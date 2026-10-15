import { defineModule } from "../../lib/module";

// starship - cross-shell prompt with git metrics. Loads last so its prompt hooks win.
export default defineModule({
  id: "starship",
  needs: ["rust", "nerd-fonts"],
  install: {
    unix: { via: "cargo", crate: "starship" },
    win32: { via: "winget", id: "Starship.Starship" },
  },
  // The config used to be written by setup; now it is a link to the file in git
  links: [{ from: "starship.toml", to: "~/.config/starship.toml" }],
  // --print-full-init: the whole init, so the shell start does not spawn starship to fetch it
  capture: { zsh: ["starship", "init", "zsh", "--print-full-init"], pwsh: ["starship", "init", "powershell", "--print-full-init"] },
  completions: [
    { shell: "zsh", argv: ["starship", "completions", "zsh"], name: "_starship" },
    { shell: "pwsh", argv: ["starship", "completions", "powershell"], name: "starship" },
  ],
});
