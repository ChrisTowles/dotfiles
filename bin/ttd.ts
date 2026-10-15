#!/usr/bin/env bun
// ttd — towles tool dotfiles. `ttd` alone opens a picker over every command.

import { join } from "node:path";
import { parseArgs } from "node:util";
import pc from "picocolors";
import { makeCtx } from "../lib/ctx";
import { addModulePaths, checkSyntax, commandList, generate, initFile } from "../lib/emit";
import { order } from "../lib/graph";
import { linkState } from "../lib/link";
import { loadModules } from "../lib/module";
import { pick } from "../lib/picker";
import { REPO, pickOS } from "../lib/platform";
import { setup, shellFor } from "../lib/setup";
import { ALL_OS, type OS, type Shell } from "../lib/types";
import { runClaude } from "../modules/claude/variants";

const BUILTINS: Record<string, { desc: string; args?: string }> = {
  setup: { desc: "Install, link and configure every module, then regenerate the shell init", args: "[--dry-run] [--os=linux|darwin|win32] [module…]" },
  gen: { desc: "Regenerate the shell init file", args: "[zsh|pwsh] [--check] [--stdout] [--os=…]" },
  graph: { desc: "Print the module order for this OS (--check: fail on a bad graph)", args: "[--os=…] [--check]" },
  doctor: { desc: "Show config links that are missing or replaced by a regular file" },
  help: { desc: "Show the alias/keybinding cheat sheet, or help for one command", args: "[command]" },
  claude: { desc: "Run claude with a preset model/effort (c, cr, cf, cfa, …)", args: "<opus|sonnet|fable|architect|resume> [args]" },
};

let [cmd, ...rest] = process.argv.slice(2);
if (cmd === "-h" || cmd === "--help") cmd = "help";

// Fast path: claude starts often, so it skips loading the modules.
if (cmd === "claude") process.exit(await runClaude(rest[0] ?? "opus", rest.slice(1)));

const mods = await loadModules();
addModulePaths(mods);

/** Flags of the builtins. Module commands get their argv untouched. */
function flags(argv: string[]) {
  const { values, positionals } = parseArgs({
    args: argv,
    allowPositionals: true,
    options: { "dry-run": { type: "boolean" }, check: { type: "boolean" }, stdout: { type: "boolean" }, os: { type: "string" } },
  });
  return { ...values, os: values.os as OS | undefined, positionals };
}
type Flags = ReturnType<typeof flags>;

async function runCommand(name: string, argv: string[]): Promise<number> {
  const owner = mods.find((m) => m.commands?.[name]);
  if (!owner) {
    console.error(`ttd: unknown command "${name}" — run \`ttd\` to pick one`);
    return 2;
  }
  return (await owner.commands![name].run(makeCtx({ dir: owner.dir }), argv)) ?? 0;
}

async function gen(f: Flags): Promise<number> {
  const ctx = makeCtx({ os: f.os });
  const shells = f.positionals.length ? (f.positionals as Shell[]) : [shellFor(ctx.os)];
  let ok = true;
  for (const shell of shells) {
    const text = await generate(mods, shell, ctx);
    if (f.stdout) process.stdout.write(text);
    else if (f.check) {
      const r = await checkSyntax(shell, text, ctx);
      console.log(`${r.ok ? pc.green("✓") : pc.red("✗")} ${shell}${r.skipped ? pc.dim(` (skipped: ${r.skipped})`) : ""}`);
      if (!r.ok) console.log(r.out);
      ok &&= r.ok;
    } else {
      await ctx.write(initFile(shell), text);
      console.log(`wrote ${initFile(shell)}`);
    }
  }
  return ok ? 0 : 1;
}

function graph(f: Flags): number {
  const oses = f.os ? [f.os] : f.check ? ALL_OS : [makeCtx().os];
  for (const os of oses) {
    const ids = order(mods, os).map((m) => m.id);
    console.log(f.check ? `${pc.green("✓")} ${os}: ${ids.length} modules` : ids.join("\n"));
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

async function help([name]: string[]): Promise<number> {
  if (!name) return Bun.spawn([process.execPath, "run", join(REPO, "config", "help.ts")], { stdio: ["inherit", "inherit", "inherit"] }).exited;
  const owner = mods.find((m) => m.commands?.[name]);
  const c = BUILTINS[name] ?? owner?.commands?.[name];
  if (!c) return console.error(`no command "${name}"`), 1;
  console.log(pc.bold(`ttd ${name}${c.args ? ` ${c.args}` : ""}`));
  console.log(c.desc);
  console.log(pc.dim(owner ? `module: ${owner.id}` : "built in"));
  return 0;
}

async function dispatch(name: string, argv: string[]): Promise<number> {
  switch (name) {
    case "setup": {
      const f = flags(argv);
      return setup(mods, { dryRun: f["dry-run"], os: f.os, only: f.positionals });
    }
    case "gen":
      return gen(flags(argv));
    case "graph":
      return graph(flags(argv));
    case "doctor":
      return doctor();
    case "help":
      return help(argv);
    case "claude":
      return runClaude(argv[0] ?? "opus", argv.slice(1));
    default:
      return runCommand(name, argv);
  }
}

const entries = () =>
  [...Object.entries(BUILTINS).map(([name, b]) => ({ name, module: "ttd", ...b })), ...commandList(mods)].sort((a, b) =>
    a.name.localeCompare(b.name),
  );

process.exit(cmd === undefined ? await pick(entries(), (name) => dispatch(name, [])) : await dispatch(cmd, rest));
