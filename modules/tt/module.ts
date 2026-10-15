import { join } from "node:path";
import { out } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// towles-tool (tt) — personal CLI, built from source via cargo
// https://github.com/ChrisTowles/towles-tool-rs
export default defineModule({
  id: "tt",
  needs: ["rust"],
  installed: (ctx) => ctx.has("tt"),
  // clap has no built-in generator here, so completions come from `tt --help`
  completions: [{ shell: "zsh", help: "tt", name: "_tt" }],
  commands: {
    "tt-update": {
      desc: "Pull and reinstall the tt CLI from ~/code/p/towles-tool-rs",
      async run(ctx) {
        const repo = join(ctx.home, "code", "p", "towles-tool-rs");
        console.log(`tt ${(await out(ctx, ["tt", "--version"])) || "not installed"}`);
        if ((await ctx.exec(["git", "-C", repo, "pull", "--ff-only"])) !== 0) return console.error("git pull failed"), 1;
        if ((await ctx.exec(["cargo", "install", "--path", join(repo, "crates-cli", "tt-cli"), "--force"])) !== 0)
          return console.error("install failed"), 1;
        // `towles-tool` is the CLI's long name — cargo installs only `tt`
        if (ctx.os !== "win32") await ctx.exec(["ln", "-sf", join(ctx.home, ".cargo", "bin", "tt"), join(ctx.home, ".cargo", "bin", "towles-tool")]);
        console.log(`tt ${await out(ctx, ["tt", "--version"])}`);
      },
    },
  },
});
