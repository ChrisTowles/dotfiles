import { defineModule } from "../../lib/module";

// uv - fast Python package manager (https://docs.astral.sh/uv)
export default defineModule({
  id: "uv",
  install: {
    linux: { via: "script", url: "https://astral.sh/uv/install.sh" },
    darwin: { via: "brew", pkg: "uv" },
    win32: { via: "winget", id: "astral-sh.uv" },
  },
  path: ["~/.local/bin"],
  completions: [
    { shell: "zsh", argv: ["uv", "generate-shell-completion", "zsh"], name: "_uv" },
    { shell: "pwsh", argv: ["uv", "generate-shell-completion", "powershell"], name: "uv" },
  ],
});
