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
  const p = Bun.spawn(["claude", ...v.flags, ...args], { stdio: ["inherit", "inherit", "inherit"] });
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
