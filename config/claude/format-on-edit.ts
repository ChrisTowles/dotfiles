#!/usr/bin/env bun

// PostToolUse hook (matcher: Edit|Write): formats the file Claude just edited.
//
// - .rs                     → rustfmt, with the edition read from the nearest
//                             Cargo.toml that declares one (crate first, then
//                             workspace root for `edition.workspace = true`)
// - TS/JS/JSON/CSS/MD/YAML  → the project's own prettier, only when it is
//                             installed locally (node_modules/.bin/prettier
//                             found walking up from the file)
//
// Never blocks: missing formatters and formatter errors are ignored, and the
// hook always exits 0 so a formatting hiccup can't fail an edit.

import { existsSync, readFileSync } from "fs";
import { dirname, extname, join } from "path";

const PRETTIER_EXTS = new Set([".ts", ".tsx", ".js", ".jsx", ".json", ".css", ".md", ".yaml", ".yml"]);

// Walk from startDir toward the filesystem root, returning the first existing
// `dir/relative` path, or null if none is found.
export function findUp(startDir: string, relative: string): string | null {
  let dir = startDir;
  while (true) {
    const candidate = join(dir, relative);
    if (existsSync(candidate)) return candidate;
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

// First literal `edition = "NNNN"` in a Cargo.toml, or null. Matches both a
// crate's `edition = "2024"` and a workspace's `[workspace.package]` edition;
// a crate inheriting via `edition.workspace = true` has no literal match.
export function parseEdition(cargoToml: string): string | null {
  return cargoToml.match(/^\s*edition\s*=\s*"(\d{4})"/m)?.[1] ?? null;
}

// Edition for a .rs file: nearest Cargo.toml with a literal edition wins
// (crate manifest, else workspace root). Falls back to 2021.
export function rustEdition(startDir: string): string {
  let dir = startDir;
  while (true) {
    const manifest = join(dir, "Cargo.toml");
    if (existsSync(manifest)) {
      const edition = parseEdition(readFileSync(manifest, "utf8"));
      if (edition) return edition;
    }
    const parent = dirname(dir);
    if (parent === dir) return "2021";
    dir = parent;
  }
}

// The formatter argv for a file, or null when there is nothing sensible to run.
export function formatterFor(filePath: string): string[] | null {
  const ext = extname(filePath);
  if (ext === ".rs") {
    return ["rustfmt", "--edition", rustEdition(dirname(filePath)), filePath];
  }
  if (PRETTIER_EXTS.has(ext)) {
    const prettier = findUp(dirname(filePath), join("node_modules", ".bin", "prettier"));
    return prettier ? [prettier, "--write", filePath] : null;
  }
  return null;
}

if (import.meta.main) {
  const input = await Bun.stdin.json().catch(() => null);
  const filePath: unknown = input?.tool_input?.file_path;
  if (typeof filePath === "string" && existsSync(filePath)) {
    const argv = formatterFor(filePath);
    if (argv) Bun.spawnSync(argv, { stdout: "ignore", stderr: "ignore" });
  }
}
