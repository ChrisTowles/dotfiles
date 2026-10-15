import { existsSync } from "node:fs";
import type { Ctx } from "./types";

/**
 * Installed check for apps that are not (only) a binary on PATH:
 * any of `bins` on PATH, a macOS .app bundle, or a winget package id.
 */
export function appInstalled(spec: { bins?: string[]; mac?: string; winget?: string }) {
  return async (ctx: Ctx): Promise<boolean> => {
    if (spec.bins?.some((b) => ctx.has(b))) return true;
    if (ctx.os === "darwin" && spec.mac) return existsSync(`/Applications/${spec.mac}.app`);
    if (ctx.os === "win32" && spec.winget) return (await ctx.read(["winget", "list", "--id", spec.winget, "--exact"])).code === 0;
    return false;
  };
}

export async function gitCloneOrPull(ctx: Ctx, url: string, dir: string): Promise<number> {
  const name = dir.split(/[\\/]/).pop();
  if (existsSync(dir)) {
    ctx.log(`updating ${name}`);
    return ctx.exec(["git", "-C", dir, "pull", "--ff-only", "-q"]);
  }
  ctx.log(`cloning ${name} from ${url}`);
  return ctx.exec(["git", "clone", "-q", url, dir]);
}

/** Ask y/N on the terminal. */
export function confirm(question: string): boolean {
  const answer = prompt(`${question} [y/N]`);
  return /^y(es)?$/i.test(answer?.trim() ?? "");
}

/** Run, capture stdout trimmed; empty string on failure. */
export async function out(ctx: Ctx, argv: string[], cwd?: string): Promise<string> {
  const r = await ctx.read(argv, { cwd });
  return r.code === 0 ? r.stdout.trim() : "";
}

/** fzf over lines; returns the picked line or "" if cancelled. */
export async function fzf(lines: string[], args: string[] = []): Promise<string> {
  const p = Bun.spawn(["fzf", ...args], { stdin: new Blob([lines.join("\n")]), stdout: "pipe", stderr: "inherit" });
  const picked = (await new Response(p.stdout).text()).trim();
  await p.exited;
  return picked;
}

/**
 * Copy a repo file to a root-owned path (where a symlink would not do) when it
 * differs. A file edited in place is kept as <dest>.<date>.bak. True if it copied.
 */
export async function sudoCopyIfChanged(ctx: Ctx, src: string, dest: string): Promise<boolean> {
  const current = await Bun.file(dest).text().catch(() => undefined);
  if (current === (await Bun.file(src).text())) return false;
  ctx.log(`updating ${dest}`);
  if (current !== undefined) {
    const backup = `${dest}.${new Date().toISOString().slice(0, 10).replaceAll("-", "")}.bak`;
    await ctx.sudo(["cp", dest, backup]);
    ctx.notice(`${dest} differed from the repo — the old file is at ${backup}`);
  }
  // install unlinks the destination first, so a stale symlink there is replaced, not written through
  await ctx.sudo(["install", "-D", "-m", "0644", src, dest]);
  return true;
}
