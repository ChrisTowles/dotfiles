import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, isAbsolute, join } from "node:path";
import pc from "picocolors";
import { ensureSymlink } from "./link";
import { HOME, REPO, currentOS, resolveTarget } from "./platform";
import type { Ctx, OS, RunResult } from "./types";

export interface CtxOptions {
  os?: OS;
  dryRun?: boolean;
  dir?: string;
  notices?: string[];
}

function show(argv: string[]): string {
  return argv.map((a) => (/[\s'"$]/.test(a) ? JSON.stringify(a) : a)).join(" ");
}

export function makeCtx(opts: CtxOptions = {}): Ctx {
  const os = opts.os ?? currentOS();
  const dryRun = opts.dryRun ?? false;
  const notices = opts.notices ?? [];
  const dir = opts.dir ?? REPO;

  const ctx: Ctx = {
    os,
    home: HOME,
    repo: REPO,
    dryRun,
    dir,
    resolve: (t) => resolveTarget(t, os),

    async read(argv, o = {}): Promise<RunResult> {
      try {
        const p = Bun.spawn(argv, {
          cwd: o.cwd,
          env: { ...process.env, ...o.env },
          stdin: o.stdin !== undefined ? new Blob([o.stdin]) : "ignore",
          stdout: "pipe",
          stderr: "pipe",
        });
        const [stdout, stderr, code] = await Promise.all([new Response(p.stdout).text(), new Response(p.stderr).text(), p.exited]);
        return { code, stdout, stderr };
      } catch (e) {
        return { code: 127, stdout: "", stderr: String(e) };
      }
    },

    async exec(argv, o = {}) {
      if (dryRun) {
        console.log(pc.dim(`  would run: ${show(argv)}`));
        return 0;
      }
      try {
        const p = Bun.spawn(argv, {
          cwd: o.cwd,
          env: { ...process.env, ...o.env },
          stdio: ["inherit", "inherit", "inherit"],
        });
        return await p.exited;
      } catch (e) {
        console.error(pc.red(`  failed to start ${argv[0]}: ${e}`));
        return 127;
      }
    },

    sudo(argv) {
      return ctx.exec(os === "win32" ? argv : ["sudo", ...argv]);
    },

    // Bun.which and Bun.spawn use the PATH Bun started with unless handed the
    // current one, which addModulePaths may have extended.
    has: (bin) => Bun.which(bin, { PATH: process.env.PATH }) !== null,

    log: (msg) => console.log(` ${msg}`),

    notice: (msg) => void notices.push(msg),

    async write(path, text) {
      if (dryRun) return console.log(pc.dim(`  would write: ${path}`));
      mkdirSync(dirname(path), { recursive: true });
      writeFileSync(path, text);
    },

    link(from, to) {
      const src = isAbsolute(from) ? from : join(dir, from);
      const msg = ensureSymlink(src, ctx.resolve(to), dryRun);
      if (msg) console.log(dryRun ? pc.dim(`  would ${msg}`) : `  ${msg}`);
    },
  };
  return ctx;
}
