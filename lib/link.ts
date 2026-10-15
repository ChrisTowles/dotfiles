import { lstatSync, mkdirSync, readlinkSync, renameSync, rmSync, statSync, symlinkSync } from "node:fs";
import { dirname, resolve } from "node:path";

export type LinkState = "ok" | "missing" | "elsewhere" | "file";

export function linkState(src: string, dest: string): LinkState {
  let st;
  try {
    st = lstatSync(dest);
  } catch {
    return "missing";
  }
  if (!st.isSymbolicLink()) return "file";
  return resolve(dirname(dest), readlinkSync(dest)) === resolve(src) ? "ok" : "elsewhere";
}

/**
 * Point `dest` at `src`. A real file or directory at `dest` is moved to a dated
 * `.bak` first; a symlink pointing elsewhere is replaced. Returns what it did.
 */
export function ensureSymlink(src: string, dest: string, dryRun = false): string | undefined {
  const state = linkState(src, dest);
  if (state === "ok") return;
  if (dryRun) return `link ${dest} → ${src}${state === "file" ? " (back up existing)" : ""}`;
  mkdirSync(dirname(dest), { recursive: true });
  if (state === "file") renameSync(dest, `${dest}.${new Date().toISOString().slice(0, 10)}.bak`);
  if (state === "elsewhere") rmSync(dest, { force: true });
  const isDir = statSync(src).isDirectory();
  // Windows: a junction needs no privilege for directories; file symlinks need Developer Mode.
  symlinkSync(src, dest, process.platform === "win32" ? (isDir ? "junction" : "file") : undefined);
  return `linked ${dest} → ${src}`;
}
