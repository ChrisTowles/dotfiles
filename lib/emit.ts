import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { order } from "./graph";
import { withTmp } from "./helpers";
import { installedBy } from "./install";
import { snippetPath } from "./module";
import { CACHE, REPO, expandValue, pickOS } from "./platform";
import type { Ctx, Module, Shell } from "./types";

export const PUSH_FILE = join(CACHE, "push");
export const initFile = (shell: Shell) => join(CACHE, shell === "zsh" ? "init.zsh" : "init.ps1");
export const pwshCompletionFile = (name: string) => join(CACHE, "completions", `${name}.ps1`);

/** PowerShell 7's built-in aliases: a function with one of these names needs the alias removed first. */
const PWSH_ALIASES = new Set(
  ("ac cat cd chdir clc clear clhy cli clp cls clv cnsn compare copy cp cpi cpp cvpa dbp del diff dir dnsn ebp echo epal " +
    "epcsv erase etsn exsn fc fhx fl foreach ft fw gal gbp gc gcb gci gcm gcs gdr ghy gi gin gjb gl gm gmo gp gps gpv group " +
    "gsn gsv gtz gu gv h history icm iex ihy ii ipal ipcsv ipmo irm ise iwmi iwr kill lp ls man md measure mi mount move mp " +
    "mv nal ndr ni nmo nsn nv ogv oh popd ps pushd pwd r rbp rcjb rcsn rd rdr ren ri rjb rm rmdir rmo rni rnp rp rsn rv rvpa " +
    "sajb sal saps sasv sbp sc scb select set shcm si sl sleep sls sort sp spjb spps spsv start stz sv tee type where wjb write").split(" "),
);

const zq = (s: string) => `'${s.replaceAll("'", `'\\''`)}'`;
const pq = (s: string) => `'${s.replaceAll("'", "''")}'`;

/**
 * `installed()` if the module overrides it; otherwise `bin` on PATH, or every
 * install spec for this OS confirms it (casks, GUI apps, .debs, flatpaks).
 */
export async function isInstalled(m: Module, ctx: Ctx): Promise<boolean> {
  if (m.installed) return m.installed(ctx);
  if (!m.install) return true;
  if (ctx.has(m.bin ?? m.id)) return true;
  const specs = [pickOS(m.install, ctx.os) ?? []].flat();
  if (!specs.length) return false;
  for (const s of specs) if (!(await installedBy(ctx, s))) return false;
  return true;
}

export interface CommandEntry {
  name: string;
  module: string;
  desc: string;
  args?: string;
}

export function commandList(mods: Module[]): CommandEntry[] {
  return mods
    .flatMap((m) => Object.entries(m.commands ?? {}).map(([name, c]) => ({ name, module: m.id, desc: c.desc, args: c.args })))
    .sort((a, b) => a.name.localeCompare(b.name));
}

function emitAlias(shell: Shell, name: string, value: string): string {
  if (shell === "zsh") return `alias ${name}=${zq(value)}`;
  // pwsh aliases cannot carry arguments, so every alias is a function. An alias
  // wins over a function, so a built-in alias of the same name goes first.
  const fn = `function global:${name} { ${value} @args }`;
  return PWSH_ALIASES.has(name) ? `Remove-Item -Force -ErrorAction SilentlyContinue Alias:${name}\n${fn}` : fn;
}

function emitModule(m: Module, shell: Shell, os: Ctx["os"], captured: string | undefined): string {
  const lines: string[] = [];
  for (const [k, raw] of Object.entries(m.env ?? {})) {
    const v = pickOS(raw, os);
    if (v === undefined) continue;
    const val = expandValue(v);
    lines.push(shell === "zsh" ? `export ${k}=${zq(val)}` : `$env:${k} = ${pq(val)}`);
  }
  for (const raw of m.path ?? []) {
    const v = pickOS(raw, os);
    if (v === undefined) continue;
    const p = expandValue(v);
    lines.push(
      shell === "zsh"
        ? `path=(${zq(p)} $path)`
        : `if (-not (($env:PATH -split [IO.Path]::PathSeparator) -contains ${pq(p)})) { $env:PATH = ${pq(p)} + [IO.Path]::PathSeparator + $env:PATH }`,
    );
  }
  if (captured) lines.push(captured.trimEnd());
  const snip = snippetPath(m, shell === "zsh" ? "zsh" : "ps1", os);
  if (snip) lines.push(readFileSync(snip, "utf8").trimEnd());
  for (const [name, raw] of Object.entries(m.aliases ?? {})) {
    const v = typeof raw === "string" ? raw : raw[shell];
    if (v !== undefined) lines.push(emitAlias(shell, name, v));
  }
  for (const [name, c] of Object.entries(m.commands ?? {})) if (c.alias !== false) lines.push(emitAlias(shell, name, `ttd ${name}`));
  if (shell === "pwsh")
    for (const c of m.completions ?? [])
      if (c.shell === "pwsh" && existsSync(pwshCompletionFile(c.name))) lines.push(`. ${pq(pwshCompletionFile(c.name))}`);
  return lines.length ? `# ── ${m.id} ──\n${lines.join("\n")}\n` : "";
}

/** The `ttd` wrapper: a command the picker sends back goes onto the next prompt. */
function emitTtd(shell: Shell, cmds: CommandEntry[]): string {
  if (shell === "zsh") {
    const entries = cmds.map((c) => zq(`${c.name.replaceAll(":", "\\:")}:${c.desc}`)).join(" \\\n    ");
    return `# ── ttd ──
ttd() {
  command ttd "$@"
  local rc=$?
  if [[ -s ${zq(PUSH_FILE)} ]]; then
    print -z -- "$(<${zq(PUSH_FILE)})"
    rm -f ${zq(PUSH_FILE)}
  fi
  return $rc
}
_ttd() {
  local -a cmds
  cmds=(${entries ? `\n    ${entries}\n  ` : ""})
  if (( CURRENT == 2 )); then _describe -t commands 'ttd command' cmds; else _files; fi
}
compdef _ttd ttd
`;
  }
  const names = cmds.map((c) => pq(c.name)).join(", ");
  return `# ── ttd ──
function global:ttd {
  & (Get-Command ttd -CommandType Application | Select-Object -First 1) @args
  $rc = $LASTEXITCODE
  $push = ${pq(PUSH_FILE)}
  if (Test-Path $push) {
    # pwsh cannot fill the next prompt; the line goes into history instead (press Up).
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory((Get-Content -Raw $push).TrimEnd())
    Remove-Item $push
  }
  $global:LASTEXITCODE = $rc
}
Register-ArgumentCompleter -Native -CommandName ttd -ScriptBlock {
  param($word, $ast, $cursor)
  if ($ast.CommandElements.Count -gt 2) { return }
  @(${names}) | Where-Object { $_ -like "$word*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_) }
}
`;
}

/** Build the init file text for `shell` from every module that runs (and is installed) on this OS. */
export async function generate(mods: Module[], shell: Shell, ctx: Ctx): Promise<string> {
  const live = order(mods, ctx.os);
  const parts: string[] = [];
  parts.push(
    shell === "zsh"
      ? `# Generated by \`ttd gen zsh\` from ${REPO}/modules — do not edit.\nDOTFILES_DIR=${zq(REPO)}\ntypeset -U path\n`
      : `# Generated by \`ttd gen pwsh\` from ${REPO}/modules — do not edit.\n$DOTFILES_DIR = ${pq(REPO)}\n`,
  );
  // The installed probes and captures spawn processes; run them all at once, emit in graph order.
  const blocks = await Promise.all(
    live.map(async (m) => {
      if (!(await isInstalled(m, ctx))) return "";
      const argv = m.capture?.[shell];
      const r = argv ? await ctx.read(argv) : undefined;
      return emitModule(m, shell, ctx.os, r?.code === 0 ? r.stdout : undefined);
    }),
  );
  parts.push(...blocks);
  parts.push(emitTtd(shell, commandList(live)));
  return parts.filter(Boolean).join("\n");
}

/** Syntax-check generated text: zsh -n, or the pwsh parser when pwsh is on PATH. */
export function checkSyntax(shell: Shell, text: string, ctx: Ctx): Promise<{ ok: boolean; skipped?: string; out: string }> {
  return withTmp("ttd-gen-", (dir) => {
    const file = join(dir, shell === "zsh" ? "init.zsh" : "init.ps1");
    writeFileSync(file, text);
    return checkFile(shell, file, ctx);
  });
}

async function checkFile(shell: Shell, file: string, ctx: Ctx): Promise<{ ok: boolean; skipped?: string; out: string }> {
  if (shell === "zsh") {
    if (!ctx.has("zsh")) return { ok: true, skipped: "zsh not installed", out: "" };
    const r = await ctx.read(["zsh", "-n", file]);
    return { ok: r.code === 0, out: r.stderr };
  }
  if (!ctx.has("pwsh")) return { ok: true, skipped: "pwsh not installed", out: "" };
  const cmd = `$e=$null; [void][System.Management.Automation.Language.Parser]::ParseFile(${pq(file)}, [ref]$null, [ref]$e); if ($e) { $e | ForEach-Object { $_.ToString() }; exit 1 }`;
  const r = await ctx.read(["pwsh", "-NoProfile", "-Command", cmd]);
  return { ok: r.code === 0, out: r.stdout + r.stderr };
}
