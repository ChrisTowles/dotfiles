import { fzf, out } from "../../lib/helpers";
import { defineModule } from "../../lib/module";
import type { Ctx } from "../../lib/types";

/**
 * The nearest local ancestor branch (not main/master) that already has an open
 * PR, so a stacked branch's PR targets it instead of main.
 */
async function stackedBase(ctx: Ctx, branch: string): Promise<string | undefined> {
  const trunk = (await ctx.read(["git", "show-ref", "--verify", "--quiet", "refs/heads/main"])).code === 0 ? "main" : "master";
  const heads = (await out(ctx, ["git", "for-each-ref", "--format=%(refname:short)", "refs/heads"])).split("\n");
  const candidates: [number, string][] = [];
  for (const c of heads) {
    if (!c || c === branch || c === trunk) continue;
    if ((await ctx.read(["git", "merge-base", "--is-ancestor", c, branch])).code !== 0) continue;
    candidates.push([Number(await out(ctx, ["git", "rev-list", "--count", `${c}..${branch}`])), c]);
  }
  // Nearest ancestor first (fewest commits between it and the current branch)
  for (const [, c] of candidates.sort((a, b) => a[0] - b[0]))
    if ((await out(ctx, ["gh", "pr", "view", c, "--json", "state", "--jq", ".state"])) === "OPEN") return c;
}

async function ghGitConfig(ctx: Ctx): Promise<number> {
  if ((await ctx.read(["gh", "auth", "status"])).code !== 0) return console.error("Not authenticated — run 'gh auth login' first."), 1;
  const name = await out(ctx, ["gh", "api", "user", "--jq", ".name // empty"]);
  const email = await out(ctx, ["gh", "api", "user/emails", "--jq", "[.[] | select(.primary)] | .[0].email // empty"]);
  if (!name || !email) return console.error("Could not fetch name or email from GitHub API."), 1;
  console.log(`Setting git config from GitHub:\n  user.name  = ${name}\n  user.email = ${email}`);
  await ctx.exec(["git", "config", "--global", "user.name", name]);
  await ctx.exec(["git", "config", "--global", "user.email", email]);
  return 0;
}

const GH_ALIASES: [string, string][] = [
  ["m", 'PAGER="less -FX" gh issue list --state open --assignee @me'],
  ["mv", 'PAGER="less -FX" gh issue list --state open --assignee @me --web'],
  ["iv", "gh issue view $1 -w"],
  ["pr-ls", 'PAGER="less -FX" gh pr list'],
];

// GitHub CLI
export default defineModule({
  id: "gh",
  install: {
    linux: {
      via: "apt",
      pkg: "gh",
      repo: {
        name: "github-cli",
        key: "https://cli.github.com/packages/githubcli-archive-keyring.gpg",
        keyring: "/usr/share/keyrings/githubcli-archive-keyring.gpg",
        line: "deb [arch={arch} signed-by={keyring}] https://cli.github.com/packages stable main",
      },
    },
    darwin: { via: "brew", pkg: "gh" },
    win32: { via: "winget", id: "GitHub.cli" },
  },
  completions: [
    { shell: "zsh", argv: ["gh", "completion", "-s", "zsh"], name: "_gh" },
    { shell: "pwsh", argv: ["gh", "completion", "-s", "powershell"], name: "gh" },
  ],
  aliases: {
    gw: "gh browse",
    gpr: "gh pr-ls",
    "pr-list": "gh pr list",
    // Stash, switch to main, and checkout a PR by number
    gco: "git stash && ttd gmain && gh pr checkout",
    gi: "gh issue create --web",
    ghci: "gh run list -L 1",
    "gh-iv": "gh iv",
    "gh-m": "gh m",
    "gh-mv": "gh mv",
  },
  commands: {
    pr: {
      desc: "Push the branch and open PR creation; a stacked branch targets its parent's open PR",
      async run(ctx) {
        const branch = await out(ctx, ["git", "symbolic-ref", "--short", "HEAD"]);
        if (branch === "main" || branch === "master") return console.error(`Error: In ${branch} branch, can't do a PR.`), 1;
        if ((await ctx.exec(["git", "push", "origin", branch])) !== 0) return 1;
        const base = await stackedBase(ctx, branch);
        if (base) console.log(`Stacked PR detected — targeting open PR branch '${base}' instead of main`);
        return ctx.exec(["gh", "pr", "create", "--web", ...(base ? ["--base", base] : [])]);
      },
    },
    gib: {
      desc: "Browse open issues (fzf) and check out a branch for the pick",
      async run(ctx) {
        const issues = await out(ctx, ["gh", "issue", "list", "--state", "open"]);
        const pick = await fzf(issues.split("\n").filter(Boolean), ["--header", "Select issue"]);
        if (!pick) return 1;
        return ctx.exec(["gh", "issue", "develop", pick.split(/\s+/)[0], "--checkout"]);
      },
    },
    "gh-git-config": { desc: "Set git user.name/user.email from your GitHub profile", run: ghGitConfig },
    "gh-alias-setup": {
      desc: "Reset the gh CLI aliases (m, mv, iv, pr-ls)",
      async run(ctx) {
        for (const [name, cmd] of GH_ALIASES) {
          await ctx.read(["gh", "alias", "delete", name]);
          await ctx.exec(["gh", "alias", "set", name, "--shell", cmd]);
        }
      },
    },
  },
  async setup(ctx) {
    for (const [name, cmd] of GH_ALIASES) {
      await ctx.read(["gh", "alias", "delete", name]);
      await ctx.exec(["gh", "alias", "set", name, "--shell", cmd]);
    }
    if ((await ctx.read(["gh", "auth", "status"])).code !== 0) {
      ctx.notice("Run 'gh auth login' then 'gh-git-config' to set git user");
    } else if (!(await out(ctx, ["git", "config", "--global", "user.name"])) || !(await out(ctx, ["git", "config", "--global", "user.email"]))) {
      if (ctx.dryRun || (await ghGitConfig(ctx)) !== 0) ctx.notice("Git user not configured — run 'gh-git-config' to set it from GitHub");
    }
  },
});
