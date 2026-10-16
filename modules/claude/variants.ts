// `ttd claude <variant> [args]` — the c/cr/cf/… aliases. Kept out of module.ts
// so bin/ttd.ts can launch claude without loading every module.

const base = ["--permission-mode", "auto", ...(process.platform === "linux" ? ["--chrome"] : [])];

export const VARIANTS: Record<string, { desc: string; flags: string[] }> = {
  opus: { desc: "Opus, high effort", flags: [...base, "--model", "opus", "--effort", "high"] },
  sonnet: { desc: "Sonnet, high effort", flags: [...base, "--model", "sonnet", "--effort", "high"] },
  fable: { desc: "Fable, medium effort", flags: [...base, "--model", "fable", "--effort", "medium"] },
  architect: { desc: "Fable, xhigh effort", flags: [...base, "--model", "fable", "--effort", "xhigh"] },
  // resume without a model/effort override keeps the resumed session's own settings
  resume: { desc: "resume, keeping the session's model", flags: [...base, "--resume"] },
};

type GitPaths = { top: string; gitDir: string; commonDir: string };

function gitPaths(cwd: string): GitPaths | null {
  const r = Bun.spawnSync(
    ["git", "rev-parse", "--path-format=absolute", "--show-toplevel", "--git-dir", "--git-common-dir"],
    { cwd, stdout: "pipe", stderr: "ignore" },
  );
  if (r.exitCode !== 0) return null;
  const [top, gitDir, commonDir] = r.stdout.toString().trim().split("\n");
  return { top, gitDir, commonDir };
}

/** True when cwd is the top of a repo's main checkout (not a linked worktree, not a subdir). */
export function inRootSlot(cwd = process.cwd()): boolean {
  const g = gitPaths(cwd);
  return !!g && g.top === cwd && g.gitDir === g.commonDir;
}

/**
 * The folder `claude agents` is scoped to: the repo's main checkout, from any
 * of its worktrees (claude puts them under <repo>/.claude/worktrees); outside
 * a repo, cwd.
 */
export function agentsScope(cwd = process.cwd()): string {
  const g = gitPaths(cwd);
  return g?.commonDir.endsWith("/.git") ? g.commonDir.slice(0, -"/.git".length) : cwd;
}

/** `agents` → `agents --cwd <scope>`, unless a --cwd is already given. */
export function scopeAgents(args: string[], scope: string): string[] {
  if (args[0] !== "agents" || args.some((a) => /^--cwd(=|$)/.test(a))) return args;
  return ["agents", "--cwd", scope, ...args.slice(1)];
}

/** Linux, from a repo's root slot: enable Remote Control. Subcommands (`agents`, `mcp`, …) take no flags. */
export function rootSlotFlags(args: string[], rootSlot: boolean): string[] {
  return rootSlot && !(args[0] && !args[0].startsWith("-")) ? ["--remote-control"] : [];
}

/**
 * Run claude in the foreground. Claude Code leaves theme-change reporting
 * (DECSET 2031) on when it exits, and the terminal's queued `ESC[?997;1n`
 * replies then echo into the shell as junk — turn the mode off and drain them.
 */
export async function runClaude(variant: string, args: string[]): Promise<number> {
  const v = VARIANTS[variant];
  if (!v) {
    console.error(`ttd claude: unknown variant "${variant}" (${Object.keys(VARIANTS).join(", ")})`);
    return 2;
  }
  // Ctrl+C belongs to claude; this process must outlive it to restore the terminal.
  process.on("SIGINT", () => {});
  const extra = process.platform === "linux" ? rootSlotFlags(args, inRootSlot()) : [];
  const argv = args[0] === "agents" ? scopeAgents(args, agentsScope()) : args;
  const p = Bun.spawn(["claude", ...v.flags, ...extra, ...argv], { stdio: ["inherit", "inherit", "inherit"] });
  const code = await p.exited;
  process.stdout.write("\x1b[?2031l");
  if (process.stdin.isTTY) {
    process.stdin.setRawMode(true);
    process.stdin.resume();
    const sink = () => {};
    process.stdin.on("data", sink);
    await Bun.sleep(50);
    process.stdin.off("data", sink);
    process.stdin.setRawMode(false);
    process.stdin.pause();
  }
  return code;
}
