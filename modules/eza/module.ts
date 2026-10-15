import { join } from "node:path";
import { defineModule } from "../../lib/module";

// eza - modern ls replacement
export default defineModule({
  id: "eza",
  needs: ["rust"],
  install: {
    linux: { via: "cargo", crate: "eza" },
    darwin: { via: "cargo", crate: "eza" },
    win32: { via: "winget", id: "eza-community.eza" },
  },
  aliases: {
    // Long list with hidden files, dirs first, git status column.
    // --icons=auto only emits icons on a tty, so piped output stays clean.
    ls: "eza -la --group-directories-first --git --icons=auto",
  },
  async setup(ctx) {
    if (ctx.os === "win32") return;
    // cargo install doesn't ship completions — fetch them from the eza repo
    const url = "https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza";
    await ctx.exec(["curl", "-fsSL", url, "-o", join(ctx.home, ".zsh", "completions", "_eza")]);
  },
});
