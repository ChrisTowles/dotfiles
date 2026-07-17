#!/usr/bin/env bun
/**
 * Generates a zsh completion script for a CLI that has no built-in completion
 * generator, by recursively parsing its commander/clap-style --help output
 * (subcommands included) and emitting a completion function tree.
 *
 * Run during DOTFILES_SETUP, e.g.:
 *
 *   bun run generate-completions.ts claude > ~/.zsh/completions/_claude
 *   bun run generate-completions.ts tt > ~/.zsh/completions/_tt
 */

interface CliOption {
  flags: string[]
  takesValue: boolean
  valueName: string
  desc: string
}

interface CliCommand {
  name: string
  aliases: string[]
  desc: string
  options: CliOption[]
  children: CliCommand[]
}

const MAX_DEPTH = 3

const CLI = process.argv[2]
if (!CLI) throw new Error('usage: generate-completions.ts <cli-name>')

// `bun run` prepends node_modules/.bin, where packages can ship shebang-less
// shims that posix_spawn can't exec (e.g. @anthropic-ai/claude-code) — resolve
// the real install instead.
import { existsSync } from 'node:fs'
function resolveBin(cli: string): string {
  const home = process.env.HOME
  const candidates = [Bun.which(cli), `${home}/.local/bin/${cli}`, `${home}/.cargo/bin/${cli}`]
  const found = candidates.find((p) => p != null && !p.includes('node_modules') && existsSync(p))
  if (found == null) throw new Error(`${cli} binary not found`)
  return found
}
const CLI_BIN = resolveBin(CLI)

async function helpText(path: string[]): Promise<string> {
  const proc = Bun.spawn([CLI_BIN, ...path, '--help'], { stdout: 'pipe', stderr: 'pipe' })
  const out = await new Response(proc.stdout).text()
  await proc.exited
  return out
}

// Lines belonging to a "Options:" / "Commands:" section (until next unindented line)
function sectionLines(text: string, header: string): string[] {
  const lines = text.split('\n')
  const start = lines.findIndex((l) => l.trim() === header)
  if (start === -1) return []
  const out: string[] = []
  for (const line of lines.slice(start + 1)) {
    if (/^\S/.test(line)) break
    out.push(line)
  }
  return out
}

function parseOptions(lines: string[]): CliOption[] {
  const entries: string[][] = []
  for (const line of lines) {
    // Options sit at indent 2 (commander, clap with a short flag) or up to 6
    // (clap long-only flags, e.g. "      --config-dir <DIR>")
    if (/^ {2,6}-/.test(line)) entries.push([line])
    else if (entries.length > 0 && line.trim()) entries[entries.length - 1]!.push(line)
  }
  const options: CliOption[] = []
  for (const entry of entries) {
    const joined = entry.map((l) => l.trim()).join(' ')
    const m = joined.match(/^((?:--?[\w-]+(?:, )?)+)(?: (<[^>]+>|\[[^\]]+\]))?\s*(.*)$/)
    if (!m) continue
    const flags = m[1]!.split(',').map((f) => f.trim()).filter(Boolean)
    // Only <required> args force a value; [optional] ones are treated as boolean
    const takesValue = (m[2] ?? '').startsWith('<')
    options.push({
      flags,
      takesValue,
      valueName: (m[2] ?? '').replace(/[<>[\].]/g, ''),
      desc: m[3] ?? '',
    })
  }
  return options
}

function parseCommands(lines: string[]): Array<{ name: string; aliases: string[]; desc: string }> {
  const cmds: Array<{ name: string; aliases: string[]; desc: string }> = []
  let prevWasEntry = false
  for (const line of lines) {
    const m = line.match(/^ {2}([a-z][\w-]*(?:\|[\w-]+)?)( .*|)$/)
    if (m && !m[1]!.includes(':')) {
      const [name = '', ...aliases] = m[1]!.split('|')
      if (name === 'help') {
        prevWasEntry = false
        continue
      }
      // Description = rest of line minus arg placeholders like [options] <name>
      const desc = (m[2] ?? '')
        .trim()
        .split(/\s+/)
        .filter((w) => !/^[<[]/.test(w) && !/[\]>]\.{0,3}$/.test(w))
        .join(' ')
      cmds.push({ name, aliases, desc })
      prevWasEntry = true
    } else if (prevWasEntry && /^ {6,}\S/.test(line)) {
      cmds[cmds.length - 1]!.desc += ' ' + line.trim()
    } else {
      prevWasEntry = false
    }
  }
  return cmds
}

async function buildCommand(path: string[], name: string, aliases: string[], desc: string, depth: number): Promise<CliCommand> {
  const text = await helpText([...path, name].filter(Boolean))
  const options = parseOptions(sectionLines(text, 'Options:'))
  let children: CliCommand[] = []
  if (depth < MAX_DEPTH) {
    const subs = parseCommands(sectionLines(text, 'Commands:'))
    children = await Promise.all(
      subs.map((s) => buildCommand([...path, name].filter(Boolean), s.name, s.aliases, s.desc, depth + 1)),
    )
  }
  return { name, aliases, desc, options, children }
}

// --- zsh emission ---------------------------------------------------------

// Strip characters that break zsh completion spec strings
function esc(s: string): string {
  return s.replace(/['"`\\[\]:()]/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 78)
}

// Everything is inferred from the help text so regeneration tracks CLI changes:
// commander choice lists, bare enum lists, and quoted examples in descriptions.
function valueAction(opt: CliOption): string {
  const choices = opt.desc.match(/\(choices:\s*([^)]+)\)/)
  if (choices) {
    const values = [...choices[1]!.matchAll(/"([^"]+)"/g)].map((c) => c[1])
    if (values.length > 0) return `(${values.join(' ')})`
  }
  // clap enum values, e.g. "[possible values: json, csv, html]"
  const possible = opt.desc.match(/\[possible values:\s*([^\]]+)\]/)
  if (possible) return `(${possible[1]!.split(/,\s*/).join(' ')})`
  // Bare enum list, e.g. "Effort level ... (low, medium, high, xhigh, max)"
  const bareList = opt.desc.match(/\(([a-z][\w-]*(?:,\s+[a-z][\w-]*)+)\)/)
  if (bareList) return `(${bareList[1]!.split(/,\s+/).join(' ')})`
  // Quoted examples, e.g. "Provide an alias ... (e.g. 'fable', 'opus', or 'sonnet')"
  if (/\be\.g\./.test(opt.desc)) {
    const examples = [...opt.desc.matchAll(/'([\w.-]+)'/g)].map((c) => c[1])
    if (examples.length >= 2) return `(${examples.join(' ')})`
  }
  if (/\b(dir|directory|directories)\b/i.test(opt.valueName)) return '_files -/'
  if (/\b(path|file)s?\b/i.test(opt.valueName)) return '_files'
  return ''
}

function optionSpecs(opt: CliOption): string[] {
  const desc = esc(opt.desc)
  const group = opt.flags.length > 1 ? `(${opt.flags.join(' ')})` : ''
  return opt.flags.map((flag) => {
    if (!opt.takesValue) return `'${group}${flag}[${desc}]'`
    const action = valueAction(opt)
    return `'${group}${flag}=[${desc}]:${opt.valueName || 'value'}:${action}'`
  })
}

function funcName(path: string[]): string {
  return [`_${CLI}`, ...path].join('__').replace(/-/g, '_')
}

function emitCommand(cmd: CliCommand, path: string[], out: string[]): void {
  const fn = funcName(path)
  const opts = cmd.options.flatMap(optionSpecs)
  const optLines = opts.map((o) => `    ${o} \\`)

  if (cmd.children.length === 0) {
    out.push(`${fn}() {`)
    out.push('  _arguments -S \\')
    out.push(...optLines)
    out.push("    '*: :_files'")
    out.push('}')
    out.push('')
    return
  }

  const cmdEntries = cmd.children.flatMap((c) =>
    [c.name, ...c.aliases].map((n) => `    '${n}:${esc(c.desc)}'`),
  )
  const dispatch = cmd.children.map((c) => {
    const pattern = [c.name, ...c.aliases].join('|')
    return `        (${pattern}) ${funcName([...path, c.name])} ;;`
  })

  out.push(`${fn}() {`)
  out.push('  local curcontext="$curcontext" state line')
  out.push('  local -a cmds')
  out.push('  cmds=(')
  out.push(...cmdEntries)
  out.push('  )')
  out.push('  _arguments -C \\')
  out.push(...optLines)
  out.push(`    '1:command:->cmd' \\`)
  out.push(`    '*:: :->args' && return`)
  out.push('  case $state in')
  out.push(`    (cmd) _describe -t commands '${[CLI, ...path].join(' ')} command' cmds ;;`)
  out.push('    (args)')
  out.push('      case ${words[1]} in')
  out.push(...dispatch)
  out.push('        (*) _files ;;')
  out.push('      esac ;;')
  out.push('  esac')
  out.push('}')
  out.push('')

  for (const child of cmd.children) emitCommand(child, [...path, child.name], out)
}

const root = await buildCommand([], '', [], '', 0)
const out: string[] = [
  `#compdef ${CLI}`,
  '# Generated by dotfiles config/generate-completions.ts — do not edit.',
  `# Regenerate with: DOTFILES_SETUP=1 exec zsh`,
  '',
]
emitCommand(root, [], out)
out.push(`${funcName([])} "$@"`)
console.log(out.join('\n'))
