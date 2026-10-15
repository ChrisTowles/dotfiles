#!/usr/bin/env bun

import pc from "picocolors";

const MESSAGE_COUNT = 5;

// Terminal control sequences (not colors — picocolors doesn't cover these)
const esc = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  yellow: "\x1b[33m",
  hide: "\x1b[?25l",
  show: "\x1b[?25h",
  clearLine: "\x1b[2K",
  up: (n: number) => `\x1b[${n}A`,
};

const c = {
  cyan: (s: string) => pc.bold(pc.cyan(s)),
  red: (s: string) => pc.red(s),
  dim: (s: string) => pc.dim(s),
  green: (s: string) => pc.green(s),
  yellow: (s: string) => pc.yellow(s),
  highlight: (s: string) => pc.inverse(pc.bold(` ${s} `)),
};

async function run(cmd: string[]): Promise<string> {
  const proc = Bun.spawn(cmd, { stdout: "pipe", stderr: "pipe" });
  const text = await new Response(proc.stdout).text();
  await proc.exited;
  return text.trim();
}

// Simple fuzzy match - returns score (higher = better), -1 = no match
export function fuzzyScore(query: string, target: string): number {
  const q = query.toLowerCase();
  const t = target.toLowerCase();
  let qi = 0;
  let score = 0;
  let lastMatch = -1;

  for (let ti = 0; ti < t.length && qi < q.length; ti++) {
    if (t[ti] === q[qi]) {
      score += 1;
      // Bonus for consecutive matches
      if (lastMatch === ti - 1) score += 2;
      // Bonus for match at word boundary
      if (ti === 0 || t[ti - 1] === " " || t[ti - 1] === ":") score += 3;
      lastMatch = ti;
      qi++;
    }
  }

  return qi === q.length ? score : -1;
}

// Highlight matching characters in the string
export function highlightMatch(query: string, target: string): string {
  if (!query) return target;
  const q = query.toLowerCase();
  const t = target.toLowerCase();
  let qi = 0;
  let result = "";

  for (let ti = 0; ti < target.length; ti++) {
    if (qi < q.length && t[ti] === q[qi]) {
      result += pc.bold(pc.yellow(target[ti]));
      qi++;
    } else {
      result += target[ti];
    }
  }
  return result;
}

// Interactive fuzzy selector
async function select(items: string[]): Promise<string | null> {
  let query = "";
  let cursor = 0;
  let filtered = [...items];

  const render = () => {
    // Move up to clear previous render
    const totalLines = filtered.length + 2;
    process.stdout.write(esc.up(totalLines) + "\r");

    // Search prompt
    process.stdout.write(`${esc.clearLine}  ${c.cyan("›")} ${query}${c.dim("│")}\n`);

    // Divider
    process.stdout.write(`${esc.clearLine}  ${c.dim("─".repeat(40))}\n`);

    // Items
    for (let i = 0; i < filtered.length; i++) {
      process.stdout.write(esc.clearLine);
      const label = highlightMatch(query, filtered[i]);
      if (i === cursor) {
        process.stdout.write(`  ${c.green("▸")} ${label}\n`);
      } else {
        process.stdout.write(`    ${c.dim(filtered[i])}\n`);
      }
    }
  };

  const updateFilter = () => {
    if (!query) {
      filtered = [...items];
    } else {
      filtered = items
        .map((item) => ({ item, score: fuzzyScore(query, item) }))
        .filter((x) => x.score >= 0)
        .sort((a, b) => b.score - a.score)
        .map((x) => x.item);
    }
    cursor = Math.min(cursor, Math.max(0, filtered.length - 1));
  };

  // Print initial blank lines to reserve space
  process.stdout.write(esc.hide);
  process.stdout.write(`  ${c.cyan("›")} ${c.dim("type to filter...")}\n`);
  process.stdout.write(`  ${c.dim("─".repeat(40))}\n`);
  for (const item of items) {
    process.stdout.write(`    ${c.dim(item)}\n`);
  }

  // Set raw mode for keypress reading
  process.stdin.setRawMode(true);
  process.stdin.resume();

  return new Promise((resolve) => {
    const cleanup = (result: string | null) => {
      process.stdin.setRawMode(false);
      process.stdin.pause();
      process.stdin.removeAllListeners("data");
      process.stdout.write(esc.show);
      resolve(result);
    };

    process.stdin.on("data", (data: Buffer) => {
      const key = data.toString();

      // Escape or Ctrl+C = cancel
      if (key === "\x1b" || key === "\x03") {
        cleanup(null);
        return;
      }

      // Enter = select
      if (key === "\r" || key === "\n") {
        cleanup(filtered[cursor] ?? null);
        return;
      }

      // Arrow up or Ctrl+K
      if (key === "\x1b[A" || key === "\x0b") {
        cursor = Math.max(0, cursor - 1);
        render();
        return;
      }

      // Arrow down or Ctrl+J
      if (key === "\x1b[B" || key === "\x0a") {
        cursor = Math.min(filtered.length - 1, cursor + 1);
        render();
        return;
      }

      // Backspace
      if (key === "\x7f" || key === "\b") {
        query = query.slice(0, -1);
        updateFilter();
        render();
        return;
      }

      // Printable characters
      if (key.length === 1 && key >= " ") {
        query += key;
        updateFilter();
        render();
        return;
      }
    });

    // Initial render with cursor on first item
    render();
  });
}

async function main() {
  // Check for staged changes
  let diff = await run(["git", "diff", "--cached"]);
  if (!diff) {
    console.log(c.yellow("No staged changes found."));
    console.log(c.dim("  l = open lazygit to stage files  q = quit"));

    process.stdin.setRawMode(true);
    process.stdin.resume();
    const answer = await new Promise<string>((resolve) => {
      process.stdin.once("data", (data: Buffer) => {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        resolve(data.toString().trim().toLowerCase());
      });
    });

    if (answer !== "l") {
      console.log("Aborted");
      process.exit(1);
    }

    // Launch lazygit for staging
    const lg = Bun.spawn(["lazygit"], {
      stdin: "inherit",
      stdout: "inherit",
      stderr: "inherit",
    });
    await lg.exited;

    // Re-check for staged changes after lazygit
    diff = await run(["git", "diff", "--cached"]);
    if (!diff) {
      console.log("No staged changes found");
      process.exit(1);
    }
  }

  const files = await run(["git", "diff", "--cached", "--stat", "--color=always"]);

  console.log(c.cyan("Staged files:"));
  console.log(files);
  console.log();
  console.log(`Generating ${MESSAGE_COUNT} commit messages with Claude...`);

  // Generate suggestions via Claude CLI
  const prompt = `Generate ${MESSAGE_COUNT} concise git commit messages for these changes. One per line, no numbering, no quotes. Use conventional commits (feat:, fix:, refactor:, docs:, chore:).

Files changed:
${files}

Diff:
${diff}`;

  const suggestions = await run(["claude", "--print", prompt]);
  if (!suggestions) {
    console.log(c.red("Failed to get suggestions from Claude"));
    process.exit(1);
  }

  const items = suggestions
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);

  console.log();
  console.log(c.dim("  ↑↓ navigate  ⏎ select  esc cancel  type to filter"));
  console.log();

  const selected = await select(items);

  if (!selected) {
    console.log("\nCancelled");
    process.exit(1);
  }

  console.log(`\n${c.green("✓")} ${selected}\n`);

  // Commit with selected message, showing hook output
  const commit = Bun.spawn(["git", "commit", "-m", selected], {
    stdout: "inherit",
    stderr: "inherit",
  });
  const commitExit = await commit.exited;

  if (commitExit === 0) {
    process.exit(0);
  }

  // Hooks failed — offer to retry with --no-verify
  console.log();
  console.log(c.yellow("Commit failed (likely a git hook). Retry with --no-verify?"));
  console.log(c.dim("  y = skip hooks  n = abort"));
  console.log();

  process.stdin.setRawMode(true);
  process.stdin.resume();

  const answer = await new Promise<string>((resolve) => {
    process.stdin.once("data", (data: Buffer) => {
      process.stdin.setRawMode(false);
      process.stdin.pause();
      resolve(data.toString().trim().toLowerCase());
    });
  });

  if (answer === "y") {
    console.log(c.yellow("Retrying with --no-verify..."));
    const retry = Bun.spawn(["git", "commit", "-m", selected, "--no-verify"], {
      stdout: "inherit",
      stderr: "inherit",
    });
    process.exit(await retry.exited);
  }

  console.log("Aborted");
  process.exit(1);
}

if (import.meta.main) {
  main();
}
