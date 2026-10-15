import { defineModule } from "../../lib/module";

// bat - cat with syntax highlighting.
// NOTE: cat is NOT aliased to bat — tools like Claude Code depend on plain cat output.
export default defineModule({
  id: "bat",
  needs: ["rust"],
  install: {
    linux: { via: "cargo", crate: "bat" },
    darwin: { via: "cargo", crate: "bat" },
    win32: { via: "winget", id: "sharkdp.bat" },
  },
  // fzf Ctrl+T preview
  env: { FZF_CTRL_T_OPTS: "--preview 'bat --color=always --style=numbers --line-range=:200 {}'" },
});
