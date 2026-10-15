#!/usr/bin/env bun
// ttd — towles tool dotfiles. `ttd` alone opens a picker over every command.

import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import pc from "picocolors";
import { runClaude } from "../modules/claude/variants";

const BUILTINS: Record<string, { desc: string; args?: string }> = {
  setup: { desc: "Install, link and configure every module, then regenerate the shell init", args: "[--dry-run] [--os=linux|darwin|win32] [module…]" },
  gen: { desc: "Regenerate the shell init file", args: "[zsh|pwsh] [--check] [--stdout]" },
  graph: { desc: "Print the module order for this OS (--check: fail on a bad graph)", args: "[--os=…] [--check]" },
  doctor: { desc: "Show config links that are missing or replaced by a regular file" },
  help: { desc: "Show the alias/keybinding cheat sheet, or help for one command", args: "[command]" },
  claude: { desc: "Run claude with a preset model/effort (c, cr, cf, cfa, …)", args: "<opus|sonnet|fable|architect|resume> [args]" },
};

const [cmd, ...rest] = process.argv.slice(2);

// Fast path: claude starts often, so it skips loading the modules.
if (cmd === "claude") process.exit(await runClaude(rest[0] ?? "opus", rest.slice(1)));

const { loadModules } = await import("../lib/module");
const { makeCtx } = await import("../lib/ctx");
const { commandList, generate, initFile, checkSyntax } = await import("../lib/emit");
const { order } = await import("../lib/graph");
const { setup, shellFor } = await import("../lib/setup");
const { linkState } = await import("../lib/link");
const { pickOS, REPO } = await import("../lib/platform");
const { pick } = await import("../lib/picker");
type OS = import("../lib/types").OS;
type Shell = import("../lib/types").Shell;

const mods = await loadModules();
const flag = (name: string) => rest.includes(`--${name}`);
const opt = (name: string) => rest.find((a) => a.startsWith(`--${name}=`))?.split("=")[1];
const positional = rest.filter((a) => !a.startsWith("--"));

async function runCommand(name: string, argv: string[]): Promise<number> {
  const owner = mods.find((m) => m.commands?.[name]);
  if (!owner) {
    console.error(`ttd: unknown command "${name}" — run \`ttd\` to pick one`);
    return 2;
  }
  return (await owner.commands![name].run(makeCtx({ dir: owner.dir }), argv)) ?? 0;
}

async function gen(): Promise<number> {
  const ctx = makeCtx({ os: opt("os") as OS | undefined });
  const shells: Shell[] = positional.length ? (positional as Shell[]) : [shellFor(ctx.os)];
  let ok = true;
  for (const shell of shells) {
    const text = await generate(mods, shell, ctx);
    if (flag("stdout")) {
      process.stdout.write(text);
      continue;
    }
    if (flag("check")) {
      const dir = mkdtempSync(join(tmpdir(), "ttd-gen-"));
      const file = join(dir, shell === "zsh" ? "init.zsh" : "init.ps1");
      writeFileSync(file, text);
      const r = await checkSyntax(shell, file, ctx);
      rmSync(dir, { recursive: true, force: true });
      console.log(`${r.ok ? pc.green("✓") : pc.red("✗")} ${shell}${r.skipped ? pc.dim(` (skipped: ${r.skipped})`) : ""}`);
      if (!r.ok) console.log(r.out);
      ok &&= r.ok;
      continue;
    }
    await ctx.write(initFile(shell), text);
    console.log(`wrote ${initFile(shell)}`);
  }
  return ok ? 0 : 1;
}

function graph(): number {
  const oses: OS[] = opt("os") ? [opt("os") as OS] : flag("check") ? ["linux", "darwin", "win32"] : [makeCtx().os];
  for (const os of oses) {
    const ids = order(mods, os).map((m) => m.id);
    if (!flag("check")) console.log(ids.join("\n"));
    else console.log(`${pc.green("✓")} ${os}: ${ids.length} modules`);
  }
  return 0;
}

function doctor(): number {
  const ctx = makeCtx();
  let bad = 0;
  for (const m of order(mods, ctx.os))
    for (const l of m.links ?? []) {
      const to = pickOS(l.to, ctx.os);
      if (!to) continue;
      const dest = ctx.resolve(to);
      const state = linkState(join(m.dir, l.from), dest);
      if (state === "ok") continue;
      bad++;
      console.log(`${pc.yellow(state.padEnd(9))} ${m.id}: ${dest}`);
    }
  console.log(bad ? `${bad} link(s) need \`ttd setup\`` : pc.green("all links ok"));
  return bad ? 1 : 0;
}

async function help(): Promise<number> {
  const name = positional[0];
  if (!name) return Bun.spawn([process.execPath, "run", join(REPO, "config", "help.ts")], { stdio: ["inherit", "inherit", "inherit"] }).exited;
  const b = BUILTINS[name];
  const owner = mods.find((m) => m.commands?.[name]);
  const c = b ?? owner?.commands?.[name];
  if (!c) return console.error(`no command "${name}"`), 1;
  console.log(pc.bold(`ttd ${name}${c.args ? ` ${c.args}` : ""}`));
  console.log(c.desc);
  console.log(pc.dim(owner ? `module: ${owner.id}` : "built in"));
  return 0;
}

function entries() {
  const builtins = Object.entries(BUILTINS).map(([name, b]) => ({ name, module: "ttd", ...b }));
  return [...builtins, ...commandList(mods)].sort((a, b) => a.name.localeCompare(b.name));
}

let code: number;
switch (cmd) {
  case undefined:
    code = await pick(entries(), (name) => (name in BUILTINS ? dispatch(name, []) : runCommand(name, [])));
    break;
  default:
    code = await dispatch(cmd, rest);
}
process.exit(code);

async function dispatch(name: string, argv: string[]): Promise<number> {
  switch (name) {
    case "setup":
      return setup(mods, { dryRun: argv.includes("--dry-run"), os: opt("os") as OS | undefined, only: argv.filter((a) => !a.startsWith("--")) });
    case "gen":
      return gen();
    case "graph":
      return graph();
    case "doctor":
      return doctor();
    case "help":
    case "--help":
    case "-h":
      return help();
    case "claude":
      return runClaude(argv[0] ?? "opus", argv.slice(1));
    default:
      return runCommand(name, argv);
  }
}
