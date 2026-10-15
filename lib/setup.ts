import { chmodSync } from "node:fs";
import { join } from "node:path";
import pc from "picocolors";
import { makeCtx } from "./ctx";
import { generate, initFile, isInstalled, pwshCompletionFile } from "./emit";
import { order } from "./graph";
import { describe, install } from "./install";
import { HOME, REPO, pickOS } from "./platform";
import type { Completion, Ctx, Module, OS, Shell } from "./types";

/** The interactive shell this repo configures on each OS. */
export const shellFor = (os: OS): Shell => (os === "win32" ? "pwsh" : "zsh");

/** `help` completions are parsed from the CLI's --help by config/generate-completions.ts. */
const completionArgv = (c: Completion): string[] =>
  "help" in c ? [process.execPath, "run", join(REPO, "config", "generate-completions.ts"), c.help] : c.argv;

async function setupModule(m: Module, ctx: Ctx): Promise<void> {
  const shell = shellFor(ctx.os);
  const specs = [(m.install && pickOS(m.install, ctx.os)) || []].flat();
  let installed = await isInstalled(m, ctx);
  if (specs.length && !installed) {
    for (const spec of specs) {
      ctx.log(`${pc.yellow("+")} installing via ${describe(spec)}`);
      const code = await install(ctx, spec);
      if (code !== 0) throw new Error(`${describe(spec)} exited ${code}`);
    }
    installed = ctx.dryRun || (await isInstalled(m, ctx));
  }
  for (const l of m.links ?? []) {
    const to = pickOS(l.to, ctx.os);
    if (to) ctx.link(l.from, to);
  }
  await m.setup?.(ctx);
  if (!installed) return;
  for (const c of m.completions ?? []) {
    if (c.shell !== shell) continue;
    const file = shell === "zsh" ? join(HOME, ".zsh", "completions", c.name) : pwshCompletionFile(c.name);
    const r = await ctx.read(completionArgv(c));
    if (r.code === 0 && r.stdout.trim()) await ctx.write(file, r.stdout);
    else ctx.log(pc.dim(`completion ${c.name} skipped (exit ${r.code})`));
  }
}

/** Put `ttd` on PATH: ~/.bun/bin is on PATH wherever Bun is installed. */
async function installShim(ctx: Ctx): Promise<void> {
  const binDir = join(HOME, ".bun", "bin");
  const entry = join(REPO, "bin", "ttd.ts");
  if (ctx.os === "win32") return ctx.write(join(binDir, "ttd.cmd"), `@bun "${entry}" %*\r\n`);
  if (!ctx.dryRun) chmodSync(entry, 0o755);
  ctx.link(entry, join(binDir, "ttd"));
}

export interface SetupOptions {
  os?: OS;
  dryRun?: boolean;
  only?: string[];
}

export async function setup(mods: Module[], { os, dryRun, only = [] }: SetupOptions): Promise<number> {
  const notices: string[] = [];
  const mk = (dir?: string) => makeCtx({ os, dryRun, notices, dir });
  const base = mk();
  const live = order(mods, base.os);
  const plan = only.length ? live.filter((m) => only.includes(m.id)) : live;
  console.log(pc.bold(`${base.os} · ${plan.length} of ${mods.length} modules${dryRun ? " · dry run" : ""}`));
  if (!only.length && live.length < mods.length)
    console.log(pc.dim(`not on ${base.os}: ${mods.filter((m) => !live.includes(m)).map((m) => m.id).join(" ")}`));

  const failed: string[] = [];
  for (const m of plan) {
    console.log(`${pc.dim("──")} ${pc.cyan(m.id)} ${pc.dim("──")}`);
    try {
      await setupModule(m, mk(m.dir));
    } catch (e) {
      failed.push(m.id);
      console.error(pc.red(` ✗ ${m.id}: ${e instanceof Error ? e.message : e}`));
    }
  }

  await installShim(base);
  const shell = shellFor(base.os);
  await base.write(initFile(shell), await generate(mods, shell, base));
  console.log(`${pc.dim("──")} ${pc.cyan("gen")} ${initFile(shell)}`);

  if (failed.length) notices.push(`⚠️  failed: ${failed.join(", ")} — re-run: ttd setup ${failed.join(" ")}`);
  if (notices.length) {
    console.log(`\n${pc.bold(pc.yellow("--- Post-setup actions ---"))}`);
    for (const n of notices) console.log(`  ${n}`);
  }
  return failed.length ? 1 : 0;
}
