import { chmodSync, existsSync } from "node:fs";
import { join } from "node:path";
import pc from "picocolors";
import { makeCtx } from "./ctx";
import { generate, initFile, isInstalled, pwshCompletionFile } from "./emit";
import { order } from "./graph";
import { describe, install } from "./install";
import { ensureSymlink } from "./link";
import { HOME, REPO, pickOS } from "./platform";
import type { Ctx, Module, OS, Shell } from "./types";

/** The interactive shell this repo configures on each OS. */
export const shellFor = (os: OS): Shell => (os === "win32" ? "pwsh" : "zsh");

/** Completion argv "ttd-gen-completions <cli>" runs config/generate-completions.ts (clap/commander --help parser). */
function completionArgv(argv: string[]): string[] {
  if (argv[0] === "ttd-gen-completions") return [process.execPath, "run", join(REPO, "config", "generate-completions.ts"), ...argv.slice(1)];
  return argv;
}

async function setupModule(m: Module, ctx: Ctx): Promise<void> {
  const shell = shellFor(ctx.os);
  const specs = [m.install?.[ctx.os] ?? []].flat();
  if (specs.length && !(await isInstalled(m, ctx))) {
    for (const spec of specs) {
      ctx.log(`${pc.yellow("+")} installing via ${describe(spec)}`);
      const code = await install(ctx, spec);
      if (code !== 0) throw new Error(`${describe(spec)} exited ${code}`);
    }
  }
  for (const l of m.links ?? []) {
    const to = pickOS(l.to, ctx.os);
    if (to) ctx.link(l.from, to);
  }
  await m.setup?.(ctx);
  if (await isInstalled(m, ctx))
    for (const c of m.completions ?? []) {
      if (c.shell !== shell) continue;
      const file = shell === "zsh" ? join(HOME, ".zsh", "completions", c.name) : pwshCompletionFile(c.name);
      const r = await ctx.read(completionArgv(c.argv));
      if (r.code === 0 && r.stdout.trim()) await ctx.write(file, r.stdout);
      else ctx.log(pc.dim(`completion ${c.name} skipped (${c.argv[0]} exited ${r.code})`));
    }
}

/** Put `ttd` on PATH: ~/.bun/bin is on PATH wherever Bun is installed. */
function installShim(ctx: Ctx): void {
  const binDir = join(HOME, ".bun", "bin");
  const entry = join(REPO, "bin", "ttd.ts");
  if (ctx.os === "win32") {
    void ctx.write(join(binDir, "ttd.cmd"), `@bun "${entry}" %*\r\n`);
    return;
  }
  if (!ctx.dryRun) chmodSync(entry, 0o755);
  const msg = ensureSymlink(entry, join(binDir, "ttd"), ctx.dryRun);
  if (msg) ctx.log(ctx.dryRun ? pc.dim(`would ${msg}`) : msg);
}

export interface SetupOptions {
  os?: OS;
  dryRun?: boolean;
  only?: string[];
}

export async function setup(mods: Module[], opts: SetupOptions): Promise<number> {
  const notices: string[] = [];
  const base = makeCtx({ os: opts.os, dryRun: opts.dryRun, notices });
  const plan = order(mods, base.os).filter((m) => !opts.only?.length || opts.only.includes(m.id));
  const skipped = mods.filter((m) => !plan.includes(m) && !opts.only?.length).map((m) => m.id);
  console.log(pc.bold(`${base.os} · ${plan.length} of ${mods.length} modules${opts.dryRun ? " · dry run" : ""}`));
  if (skipped.length) console.log(pc.dim(`not on ${base.os}: ${skipped.join(" ")}`));

  const failed: string[] = [];
  for (const m of plan) {
    console.log(`${pc.dim("──")} ${pc.cyan(m.id)} ${pc.dim("──")}`);
    try {
      await setupModule(m, makeCtx({ os: opts.os, dryRun: opts.dryRun, notices, dir: m.dir }));
    } catch (e) {
      failed.push(m.id);
      console.error(pc.red(` ✗ ${m.id}: ${e instanceof Error ? e.message : e}`));
    }
  }

  installShim(base);
  const shell = shellFor(base.os);
  await base.write(initFile(shell), await generate(mods, shell, base));
  console.log(`${pc.dim("──")} ${pc.cyan("gen")} ${initFile(shell)}`);

  if (failed.length) notices.push(`⚠️  failed: ${failed.join(", ")} — re-run: ttd setup ${failed.join(" ")}`);
  if (notices.length) {
    console.log(`\n${pc.bold(pc.yellow("--- Post-setup actions ---"))}`);
    for (const n of notices) console.log(`  ${n}`);
  }
  if (!existsSync(initFile(shellFor(base.os))) && !opts.dryRun) return 1;
  return failed.length ? 1 : 0;
}
