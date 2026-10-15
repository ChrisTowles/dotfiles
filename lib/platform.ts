import { homedir } from "node:os";
import { join, resolve as resolvePath } from "node:path";
import { ALL_OS, type OS, type PerOS } from "./types";

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

const PER_OS_KEYS = [...ALL_OS, "unix"];

function isPerOS<T>(v: T | PerOS<T>): v is PerOS<T> {
  return v !== null && typeof v === "object" && !Array.isArray(v) && PER_OS_KEYS.some((k) => k in (v as object));
}

/** The value for `os`: a per-OS map's own key, then `unix` for linux/darwin. A plain value applies everywhere. */
export function pickOS<T>(v: T | PerOS<T>, os: OS): T | undefined {
  if (!isPerOS(v)) return v as T;
  return v[os] ?? (os === "win32" ? undefined : v.unix);
}
