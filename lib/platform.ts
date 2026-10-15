import { homedir } from "node:os";
import { join, resolve as resolvePath } from "node:path";
import type { OS, PerOS } from "./types";

export const REPO = resolvePath(import.meta.dir, "..");
export const HOME = homedir();
export const CACHE = join(HOME, ".cache", "dotfiles");

export function currentOS(): OS {
  const p = process.platform;
  if (p === "linux" || p === "darwin" || p === "win32") return p;
  throw new Error(`unsupported platform: ${p}`);
}

function winEnv(name: "APPDATA" | "LOCALAPPDATA"): string {
  const fallback = name === "APPDATA" ? join(HOME, "AppData", "Roaming") : join(HOME, "AppData", "Local");
  return process.env[name] ?? fallback;
}

const ROOTS: Record<string, Record<OS, () => string>> = {
  config: {
    linux: () => join(HOME, ".config"),
    darwin: () => join(HOME, "Library", "Application Support"),
    win32: () => winEnv("APPDATA"),
  },
  xdg: {
    linux: () => join(HOME, ".config"),
    darwin: () => join(HOME, ".config"),
    win32: () => winEnv("APPDATA"),
  },
  data: {
    linux: () => join(HOME, ".local", "share"),
    darwin: () => join(HOME, "Library", "Application Support"),
    win32: () => winEnv("LOCALAPPDATA"),
  },
};

/** Resolve a logical path ("config:x", "xdg:x", "data:x", "~/x", "{repo}/x", or absolute) for `os`. */
export function resolveTarget(target: string, os: OS): string {
  const m = /^(config|xdg|data):(.*)$/.exec(target);
  if (m) return join(ROOTS[m[1]][os](), ...m[2].split("/"));
  return expandValue(target);
}

/** Expand "~/" and "{repo}" in an env or PATH value. */
export function expandValue(v: string): string {
  if (v === "~") return HOME;
  if (v.startsWith("~/")) v = join(HOME, ...v.slice(2).split("/"));
  return v.replaceAll("{repo}", REPO);
}

export function pickOS<T>(v: T | PerOS<T>, os: OS): T | undefined {
  if (v !== null && typeof v === "object" && !Array.isArray(v) && ["linux", "darwin", "win32"].some((k) => k in (v as object)))
    return (v as PerOS<T>)[os];
  return v as T;
}
