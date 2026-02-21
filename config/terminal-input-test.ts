#!/usr/bin/env bun
/**
 * Interactive keyboard shortcut trainer — detects actual keypresses
 * in raw terminal mode to help build muscle memory for tmux, terminal
 * copy/paste, and other shortcuts. Tests are shuffled randomly each run.
 */

import pc from "picocolors";

const PASS = pc.green("✓ PASS");
const FAIL = pc.red("✗ FAIL");
const SKIP = pc.yellow("⊘ SKIP");

interface TestResult {
  name: string;
  status: "pass" | "fail" | "skip";
}

const results: TestResult[] = [];

// ─── Test definitions ────────────────────────────────────────────────

interface KeyTest {
  type: "key";
  name: string;
  tip: string;
  expectedByte: number;
  expectedName: string;
}

interface SequenceTest {
  type: "sequence";
  name: string;
  tip: string;
  first: { byte: number; name: string };
  second: { byte: number; name: string };
}

interface PasteTest {
  type: "paste";
  name: string;
  tip: string;
  /** Text to show the user to copy, then they paste it back */
  phrase: string;
}

interface ManualTest {
  type: "manual";
  name: string;
  tip: string;
  /** Steps the user should perform before confirming */
  steps: string[];
}

type DrillTest = KeyTest | SequenceTest | PasteTest | ManualTest;

const ALL_TESTS: DrillTest[] = [
  // Copy & paste
  {
    type: "paste",
    name: "Copy & paste text",
    tip: "Select the text, copy with Ctrl+Shift+C (Linux) or Cmd+C (macOS), then paste below",
    phrase: "hello dotfiles 1234!@#$",
  },
  {
    type: "paste",
    name: "Copy & paste — path",
    tip: "Copy the path, paste it back with Ctrl+Shift+V (Linux) or Cmd+V (macOS)",
    phrase: "~/code/p/dotfiles/config/tmux/tmux.conf",
  },
  // Screenshot & paste image
  {
    type: "manual",
    name: "Ctrl+4 — area screenshot (Pop!_OS)",
    tip: "Capture a region of the screen to clipboard",
    steps: [
      "Press Ctrl+4 (COSMIC shortcut set up by dotfiles)",
      "Click and drag to select an area",
      "The screenshot is copied to your clipboard",
    ],
  },
  {
    type: "manual",
    name: "Paste image from clipboard",
    tip: "Test that image copy/paste works with your clipboard",
    steps: [
      "Take a screenshot first (Ctrl+4 or Print Screen)",
      "Open a browser, chat app, or editor that accepts images",
      "Paste with Ctrl+Shift+V (Linux) or Cmd+V (macOS)",
      "Verify the image appeared",
    ],
  },
  // Single key shortcuts
  {
    type: "key",
    name: "Ctrl+R — reverse history search",
    tip: "Opens reverse search in your shell",
    expectedByte: 0x12,
    expectedName: "Ctrl+R",
  },
  {
    type: "key",
    name: "Ctrl+A — tmux prefix",
    tip: "Tmux prefix key (remapped from default Ctrl+B)",
    expectedByte: 0x01,
    expectedName: "Ctrl+A",
  },
  // VS Code shortcuts (Ctrl+Shift sends same byte as Ctrl in terminal)
  {
    type: "key",
    name: "VS Code — find in file (Ctrl+F)",
    tip: "Opens find within the current file",
    expectedByte: 0x06,
    expectedName: "Ctrl+F",
  },
  {
    type: "key",
    name: "VS Code — find all files (Ctrl+Shift+F)",
    tip: "Opens search across all files in the workspace",
    expectedByte: 0x06,
    expectedName: "Ctrl+Shift+F",
  },
  {
    type: "key",
    name: "VS Code — go to definition (Ctrl+B)",
    tip: "Jump to the definition of a symbol under cursor",
    expectedByte: 0x02,
    expectedName: "Ctrl+B",
  },
  {
    type: "key",
    name: "VS Code — command palette (Ctrl+Shift+P)",
    tip: "Opens the command palette to run any VS Code command",
    expectedByte: 0x10,
    expectedName: "Ctrl+Shift+P",
  },
  // Tmux splits
  {
    type: "sequence",
    name: "Tmux — horizontal split",
    tip: "Splits the current pane top/bottom",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x2d, name: "'-'" },
  },
  {
    type: "sequence",
    name: "Tmux — vertical split (|)",
    tip: "Splits the current pane left/right",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x7c, name: "'|'" },
  },
  {
    type: "sequence",
    name: "Tmux — vertical split (\\)",
    tip: "Alternate binding — also splits left/right",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x5c, name: "'\\'" },
  },
  // Tmux pane navigation
  {
    type: "sequence",
    name: "Tmux — navigate left",
    tip: "Move to the pane on the left",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x68, name: "'h'" },
  },
  {
    type: "sequence",
    name: "Tmux — navigate down",
    tip: "Move to the pane below",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x6a, name: "'j'" },
  },
  {
    type: "sequence",
    name: "Tmux — navigate up",
    tip: "Move to the pane above",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x6b, name: "'k'" },
  },
  {
    type: "sequence",
    name: "Tmux — navigate right",
    tip: "Move to the pane on the right",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x6c, name: "'l'" },
  },
  // Tmux other
  {
    type: "sequence",
    name: "Tmux — enter copy mode",
    tip: "Enters scroll/copy mode — use vim keys to move, q to exit",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x5b, name: "'['" },
  },
  {
    type: "sequence",
    name: "Tmux — new window",
    tip: "Creates a new tmux window",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x63, name: "'c'" },
  },
  {
    type: "sequence",
    name: "Tmux — kill pane",
    tip: "Closes the current pane (with confirmation)",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x78, name: "'x'" },
  },
  {
    type: "sequence",
    name: "Tmux — kill window",
    tip: "Closes the current window (with confirmation)",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x26, name: "'&'" },
  },
  {
    type: "sequence",
    name: "Tmux — toggle zoom",
    tip: "Zooms current pane to fill window (or unzooms)",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x7a, name: "'z'" },
  },
  {
    type: "sequence",
    name: "Tmux — rename window",
    tip: "Rename the current window",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x2c, name: "','" },
  },
  {
    type: "sequence",
    name: "Tmux — next window",
    tip: "Switch to the next window",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x6e, name: "'n'" },
  },
  {
    type: "sequence",
    name: "Tmux — previous window",
    tip: "Switch to the previous window",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x70, name: "'p'" },
  },
  {
    type: "sequence",
    name: "Tmux — detach session",
    tip: "Detach from the current tmux session",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x64, name: "'d'" },
  },
  {
    type: "sequence",
    name: "Tmux — list sessions",
    tip: "Show all tmux sessions",
    first: { byte: 0x01, name: "Ctrl+A" },
    second: { byte: 0x73, name: "'s'" },
  },
];

// ─── Key detection helpers ───────────────────────────────────────────

function describeKey(bytes: number[]): string {
  if (bytes.length === 0) return "<nothing>";
  if (bytes.length === 1) {
    const b = bytes[0];
    if (b <= 26 && b !== 9 && b !== 13) {
      return `Ctrl+${String.fromCharCode(b + 64)}`;
    }
    if (b === 27) return "Escape";
    if (b === 127) return "Backspace";
    if (b >= 32 && b <= 126) return `'${String.fromCharCode(b)}'`;
    return `0x${b.toString(16).padStart(2, "0")}`;
  }
  if (bytes[0] === 27) {
    const rest = bytes
      .slice(1)
      .map((b) => String.fromCharCode(b))
      .join("");
    return `Esc+${rest}`;
  }
  return bytes.map((b) => `0x${b.toString(16).padStart(2, "0")}`).join(" ");
}

function enableRaw() {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.ref();
}

function disableRaw() {
  process.stdin.setRawMode(false);
  process.stdin.pause();
}

function readKey(): Promise<number[]> {
  return new Promise((resolve) => {
    process.stdin.once("data", (data: Buffer) => {
      resolve(Array.from(data));
    });
  });
}

function readKeyWithTimeout(ms: number): Promise<number[] | null> {
  return new Promise((resolve) => {
    const timer = setTimeout(() => {
      process.stdin.removeAllListeners("data");
      resolve(null);
    }, ms);
    process.stdin.once("data", (data: Buffer) => {
      clearTimeout(timer);
      resolve(Array.from(data));
    });
  });
}

// ─── Display helpers ─────────────────────────────────────────────────

function header(index: number, total: number, title: string) {
  console.log();
  console.log(
    pc.bold(pc.cyan(`━━━ [${index}/${total}] ${title} ━━━`))
  );
}

function hint(msg: string) {
  console.log(pc.dim(`  ${msg}`));
}

function record(name: string, status: "pass" | "fail" | "skip") {
  const icon = status === "pass" ? PASS : status === "fail" ? FAIL : SKIP;
  console.log(`  ${icon} ${name}`);
  results.push({ name, status });
}

// ─── Handle special keys (escape/ctrl-c) ─────────────────────────────

/** Returns true if the key should abort the current test */
function handleSpecialKey(key: number[], name: string): "skip" | "quit" | null {
  if (key.length === 1 && key[0] === 0x1b) return "skip";
  if (key.length === 1 && key[0] === 0x03) return "quit";
  return null;
}

// ─── Test runners ────────────────────────────────────────────────────

async function runKeyTest(
  test: KeyTest,
  index: number,
  total: number,
  maxAttempts = 3
) {
  header(index, total, test.name);
  console.log(pc.white(`  → ${test.tip}`));
  hint(`Press ${pc.bold(test.expectedName)}  (Escape = skip, Ctrl+C = quit)`);
  console.log();

  enableRaw();
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    process.stdout.write(
      pc.yellow(`  [${attempt}/${maxAttempts}] Waiting... `)
    );
    const key = await readKey();

    const special = handleSpecialKey(key, test.name);
    if (special === "skip") {
      process.stdout.write("\n");
      record(test.name, "skip");
      disableRaw();
      return;
    }
    if (special === "quit") {
      process.stdout.write("\n");
      disableRaw();
      printSummary();
      process.exit(0);
    }
    if (key.length === 1 && key[0] === test.expectedByte) {
      process.stdout.write(pc.green(`${test.expectedName} ✓\n`));
      record(test.name, "pass");
      disableRaw();
      return;
    }
    process.stdout.write(
      pc.red(`Got ${describeKey(key)}, expected ${test.expectedName}\n`)
    );
  }
  record(test.name, "fail");
  disableRaw();
}

async function runSequenceTest(
  test: SequenceTest,
  index: number,
  total: number,
  maxAttempts = 3
) {
  const seqLabel = `${test.first.name} then ${test.second.name}`;
  header(index, total, test.name);
  console.log(pc.white(`  → ${test.tip}`));
  hint(`Press ${pc.bold(seqLabel)}  (Escape = skip, Ctrl+C = quit)`);
  console.log();

  enableRaw();
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    process.stdout.write(
      pc.yellow(`  [${attempt}/${maxAttempts}] Press ${test.first.name}... `)
    );
    const k1 = await readKey();

    const s1 = handleSpecialKey(k1, test.name);
    if (s1 === "skip") {
      process.stdout.write("\n");
      record(test.name, "skip");
      disableRaw();
      return;
    }
    if (s1 === "quit") {
      process.stdout.write("\n");
      disableRaw();
      printSummary();
      process.exit(0);
    }
    if (!(k1.length === 1 && k1[0] === test.first.byte)) {
      process.stdout.write(
        pc.red(`Got ${describeKey(k1)}, expected ${test.first.name}\n`)
      );
      continue;
    }
    process.stdout.write(pc.green("✓ "));

    // Second key with 2s timeout
    process.stdout.write(pc.yellow(`now ${test.second.name}... `));
    const k2 = await readKeyWithTimeout(2000);

    if (k2 === null) {
      process.stdout.write(pc.red("timed out\n"));
      continue;
    }
    const s2 = handleSpecialKey(k2, test.name);
    if (s2 === "skip") {
      process.stdout.write("\n");
      record(test.name, "skip");
      disableRaw();
      return;
    }
    if (s2 === "quit") {
      process.stdout.write("\n");
      disableRaw();
      printSummary();
      process.exit(0);
    }
    if (k2.length === 1 && k2[0] === test.second.byte) {
      process.stdout.write(pc.green("✓\n"));
      record(test.name, "pass");
      disableRaw();
      return;
    }
    process.stdout.write(
      pc.red(`Got ${describeKey(k2)}, expected ${test.second.name}\n`)
    );
  }
  record(test.name, "fail");
  disableRaw();
}

// ─── Paste test runner ───────────────────────────────────────────────

async function runPasteTest(
  test: PasteTest,
  index: number,
  total: number
) {
  header(index, total, test.name);
  console.log(pc.white(`  → ${test.tip}`));
  console.log();
  console.log(`  Copy this: ${pc.bold(pc.green(test.phrase))}`);
  hint("Paste it below and press Enter  (type 's' + Enter to skip)");
  console.log();

  process.stdout.write(pc.yellow("  > "));
  process.stdin.resume();
  const pasted = await new Promise<string>((resolve) => {
    process.stdin.once("data", (data: Buffer) => {
      resolve(data.toString().trim());
    });
  });
  process.stdin.pause();

  if (pasted.toLowerCase() === "s") {
    record(test.name, "skip");
    return;
  }
  if (pasted === test.phrase) {
    record(test.name, "pass");
  } else {
    console.log(pc.red(`  Expected: "${test.phrase}"`));
    console.log(pc.red(`  Got:      "${pasted}"`));
    record(test.name, "fail");
  }
}

// ─── Manual confirm test runner ──────────────────────────────────────

async function runManualTest(
  test: ManualTest,
  index: number,
  total: number
) {
  header(index, total, test.name);
  console.log(pc.white(`  → ${test.tip}`));
  console.log();
  for (const step of test.steps) {
    console.log(pc.white(`  ${pc.dim("•")} ${step}`));
  }
  hint("Press 'y' if it worked, 'n' if not, Escape to skip");
  console.log();

  enableRaw();
  process.stdout.write(pc.yellow("  Waiting (y/n)... "));
  const key = await readKey();
  process.stdout.write("\n");

  const special = handleSpecialKey(key, test.name);
  if (special === "skip") {
    record(test.name, "skip");
  } else if (special === "quit") {
    disableRaw();
    printSummary();
    process.exit(0);
  } else if (key.length === 1 && key[0] === 0x79) {
    // 'y'
    record(test.name, "pass");
  } else if (key.length === 1 && key[0] === 0x6e) {
    // 'n'
    record(test.name, "fail");
  } else {
    console.log(pc.dim(`  Got ${describeKey(key)}, treating as 'no'`));
    record(test.name, "fail");
  }
  disableRaw();
}

// ─── Summary ─────────────────────────────────────────────────────────

function printSummary() {
  console.log();
  console.log(pc.bold(pc.cyan("━━━ Results ━━━")));
  console.log();
  for (const r of results) {
    const icon =
      r.status === "pass" ? PASS : r.status === "fail" ? FAIL : SKIP;
    console.log(`  ${icon}  ${r.name}`);
  }
  const passed = results.filter((r) => r.status === "pass").length;
  const failed = results.filter((r) => r.status === "fail").length;
  const skipped = results.filter((r) => r.status === "skip").length;
  console.log();
  console.log(
    `  ${pc.bold("Total:")} ${results.length}  ` +
      `${pc.green(`Passed: ${passed}`)}  ` +
      `${pc.red(`Failed: ${failed}`)}  ` +
      `${pc.yellow(`Skipped: ${skipped}`)}`
  );
  console.log();
  if (failed > 0) process.exit(1);
}

// ─── Shuffle ─────────────────────────────────────────────────────────

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// ─── Main ────────────────────────────────────────────────────────────

async function main() {
  console.log();
  console.log(pc.bold(pc.magenta("  ⌨  Terminal Shortcut Trainer")));
  console.log(
    pc.dim("  Practice keybindings — tests are shuffled each run.")
  );
  console.log(pc.dim("  Escape = skip, Ctrl+C = quit early."));

  const tests = shuffle(ALL_TESTS);
  const total = tests.length;

  console.log(pc.dim(`  ${total} shortcuts to practice — let's go!\n`));

  for (let i = 0; i < tests.length; i++) {
    const test = tests[i];
    switch (test.type) {
      case "key":
        await runKeyTest(test, i + 1, total);
        break;
      case "sequence":
        await runSequenceTest(test, i + 1, total);
        break;
      case "paste":
        await runPasteTest(test, i + 1, total);
        break;
      case "manual":
        await runManualTest(test, i + 1, total);
        break;
    }
  }

  printSummary();
}

main();
