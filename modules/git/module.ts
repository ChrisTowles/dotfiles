import { join, resolve } from "node:path";
import { confirm, out } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

export default defineModule({
  id: "git",
  installed: (ctx) => ctx.has("git"),
  install: { linux: { via: "apt", pkg: "git" }, win32: { via: "winget", id: "Git.Git" } },
  os: ["linux", "darwin", "win32"],
  aliases: {
    gc: "ttd git-ai-commit",
    gcm: "ttd git-ai-commit",
    gca: "git add . && ttd git-ai-commit",
    ga: "git add .",
    gp: "git push",
    gs: "git status",
  },
  async setup(ctx) {
    // Silence "skipped previously applied commit" notices during rebase
    await ctx.exec(["git", "config", "--global", "advice.skippedCherryPicks", "false"]);
  },
  commands: {
    "git-ai-commit": {
      desc: "AI commit message (Claude + fuzzy selector); lazygit's `c` key runs this",
      run: (ctx) => ctx.exec([process.execPath, "run", join(ctx.repo, "modules", "git", "ai-commit.ts")]),
    },
    gmain: {
      desc: "Stash if dirty, switch to main (or master) and pull",
      async run(ctx) {
        const dirty = (await ctx.read(["git", "diff", "--quiet", "HEAD"])).code !== 0;
        if (dirty && (await ctx.exec(["git", "stash"])) !== 0) return console.error("git stash failed"), 1;
        const main = (await out(ctx, ["git", "branch", "-l", "main"])) ? "main" : "master";
        console.log(`checking out ${main}`);
        if ((await ctx.exec(["git", "checkout", main])) !== 0) return console.error("checkout failed"), 1;
        if ((await ctx.exec(["git", "pull"])) !== 0) return console.error("git pull failed"), 1;
      },
    },
    gclean: {
      desc: "Delete local branches whose remote tracking branch is gone",
      async run(ctx) {
        if ((await ctx.exec(["git", "fetch", "--prune"])) !== 0) return console.error("git fetch failed"), 1;
        const refs = await out(ctx, ["git", "for-each-ref", "--format", "%(refname:short) %(upstream:track)", "refs/heads"]);
        const gone = refs.split("\n").filter((l) => l.includes("[gone]")).map((l) => l.split(" ")[0]);
        if (!gone.length) return void console.log("No stale branches to clean up.");
        console.log(`Branches with gone remotes:\n${gone.map((b) => `  ${b}`).join("\n")}\n`);
        if (!confirm("Delete these branches?")) return;
        const current = await out(ctx, ["git", "branch", "--show-current"]);
        for (const b of gone) {
          if (b === current) console.log(`  Skipping ${b} (currently checked out)`);
          else await ctx.exec(["git", "branch", "-D", b]);
        }
      },
    },
    "grebase-preserve": {
      desc: "Rebase onto a branch, keeping each commit's author as its committer",
      args: "[branch]",
      async run(ctx, [target = "main"]) {
        if ((await ctx.exec(["git", "rebase", target])) !== 0) return 1;
        const base = await out(ctx, ["git", "merge-base", "HEAD", target]);
        const filter = 'export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL" GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"';
        return ctx.exec(["git", "filter-branch", "-f", "--env-filter", filter, `${base}..HEAD`]);
      },
    },
    "git-ignored": {
      desc: "List ignored files (except node_modules)",
      async run(ctx) {
        const files = await out(ctx, ["git", "ls-files", ".", "--ignored", "--exclude-standard", "--others"]);
        console.log(files.split("\n").filter((f) => f && !f.includes("node_modules")).join("\n"));
      },
    },
    gitk: {
      desc: "Open GitKraken on a repo (default: cwd)",
      args: "[path]",
      async run(ctx, [path = "."]) {
        const url = `gitkraken://repo/${resolve(path)}`;
        console.log(`open gitkraken to '${resolve(path)}'`);
        const opener = ctx.os === "darwin" ? ["open"] : ctx.os === "win32" ? ["cmd", "/c", "start", ""] : ["xdg-open"];
        return ctx.exec([...opener, url]);
      },
    },
    push: {
      desc: "git push to this repo; on macOS switches gh to the personal account and back",
      args: "[git push args]",
      alias: false,
      async run(ctx, argv) {
        if (ctx.os !== "darwin") return ctx.exec(["git", "push", ...argv]);
        await ctx.exec(["gh", "auth", "switch", "--user", "ChrisTowles"]);
        try {
          return await ctx.exec(["git", "push", ...argv]);
        } finally {
          await ctx.exec(["gh", "auth", "switch", "--user", "212787373_aero"]);
        }
      },
    },
  },
});
