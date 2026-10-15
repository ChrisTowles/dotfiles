import { defineModule } from "../../lib/module";

// delta - syntax-highlighted git diffs (https://github.com/dandavison/delta)
export default defineModule({
  id: "delta",
  needs: ["rust", "git"],
  install: {
    linux: { via: "cargo", crate: "git-delta" },
    darwin: { via: "cargo", crate: "git-delta" },
    win32: { via: "winget", id: "dandavison.delta" },
  },
  // diff two files with syntax highlighting: dif file1 file2
  aliases: { dif: "delta" },
  async setup(ctx) {
    const set = (k: string, v: string) => ctx.exec(["git", "config", "--global", k, v]);
    await set("core.pager", "delta");
    await set("interactive.diffFilter", "delta --color-only");
    await set("delta.navigate", "true");
    await set("delta.side-by-side", "true");
    await set("delta.line-numbers", "true");
    await set("merge.conflictstyle", "zdiff3");
  },
});
