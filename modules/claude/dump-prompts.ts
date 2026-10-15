#!/usr/bin/env bun
// Dump the prompt-like content baked into the Claude Code CLI binary.
//
// Claude Code ships as a single compiled executable with its JS bundle embedded.
// The built-in *skills* are stored verbatim as backtick template literals that
// open with a Markdown frontmatter block (`---\nname: <slug>\n...`), which makes
// them cleanly carve-able. The larger instruction blocks (system prompt, tool and
// agent guidance, the model-migration guide, ...) are ordinary string literals
// with no delimiter, so those are recovered heuristically as "prose blocks" and
// are necessarily best-effort.
//
// Not in here: most slash commands, hooks, and agents are user-space files rather
// than compiled into the binary, so there is little of them to dump.
//
// Output: ~/.cache/claude-prompts/<version>/ with a stable `latest` symlink.
// The dump is content-identical for a given version, so an existing one is reused
// unless --force is passed.

import { mkdirSync, readdirSync, realpathSync, rmSync, statSync, symlinkSync, unlinkSync } from 'node:fs'
import { homedir } from 'node:os'
import { basename, join } from 'node:path'
import { createColors } from 'picocolors'

// stdout is the fzf menu; status goes to stderr, colored regardless of TTY
const pc = createColors(true)
const err = (s: string) => process.stderr.write(s + '\n')

interface Entry {
    kind: 'skill' | 'prompt'
    slug: string
    /** path relative to the dump dir */
    path: string
    chars: number
    summary: string
}

interface Manifest {
    version: string
    source: string
    dumped: string
    entries: Entry[]
}

// --- locating the binary ---------------------------------------------------

const resolveBinary = (explicit?: string): string => {
    const candidates = explicit
        ? [explicit.replace(/^~/, homedir())]
        : [join(homedir(), '.local/bin/claude'), Bun.which('claude') ?? '']
    for (const c of candidates) {
        if (!c) continue
        try {
            // follow the symlink chain to the real versioned executable
            const real = realpathSync(c)
            if (statSync(real).isFile()) return real
        } catch {
            // not there — try the next candidate
        }
    }
    err(pc.red(explicit ? `binary not found: ${explicit}` : 'could not locate the claude binary (pass --binary PATH)'))
    process.exit(1)
}

// versioned installs live at .../versions/<version>; fall back to the filename
const binaryVersion = (path: string) => /versions\/([^/]+)$/.exec(path)?.[1] ?? basename(path)

// --- unescaping ------------------------------------------------------------

// A lone surrogate (half of a pair) can't be encoded as UTF-8; swap in U+FFFD so
// the file is writable. Real pairs survive — JS strings are already UTF-16.
const LONE_SURROGATE = /[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?<![\uD800-\uDBFF])[\uDC00-\uDFFF]/g

const decodeUnicode = (s: string): string => {
    if (!s.includes('\\u')) return s
    s = s.replace(/\\u([0-9a-fA-F]{4})/g, (_, hex) => String.fromCharCode(parseInt(hex, 16)))
    return s.replace(LONE_SURROGATE, '�')
}

// backtick literals escape ` \ and $ ; newlines are already literal bytes
const unescapeTemplate = (s: string): string =>
    decodeUnicode(s).replace(/\\`/g, '`').replace(/\\\$/g, '$').replace(/\\\\/g, '\\')

const unescapeDoubleQuoted = (s: string): string =>
    decodeUnicode(s.replace(/\\"/g, '"').replace(/\\n/g, '\n').replace(/\\t/g, '\t')).replace(/\\\\/g, '\\')

// --- skills: frontmatter template literals ---------------------------------

const SKILL_START = /`---\nname:/g
const VALID_SLUG = /^[a-z][a-z0-9-]{1,60}$/

/**
 * Index of the delimiter closing the literal opened at `open`, or -1.
 * A delimiter preceded by an odd number of backslashes is escaped.
 */
const findClose = (data: string, open: number, quote: string): number => {
    for (let i = open + 1; ; ) {
        const j = data.indexOf(quote, i)
        if (j === -1) return -1
        let slashes = 0
        while (data[j - 1 - slashes] === '\\') slashes++
        if (slashes % 2 === 0) return j
        i = j + 1
    }
}

/** Contents of the template literal whose opening backtick is at `openPos`. */
const carveBacktick = (data: string, openPos: number): string | null => {
    const end = findClose(data, openPos, '`')
    return end === -1 ? null : data.slice(openPos + 1, end)
}

const extractSkills = (data: string, out: string): Entry[] => {
    const found: Array<{ name: string; body: string }> = []
    for (const m of data.matchAll(SKILL_START)) {
        const carved = carveBacktick(data, m.index)
        if (carved === null) continue
        const body = unescapeTemplate(carved)
        found.push({ name: /name:\s*([^\n]+)/.exec(body.slice(0, 200))?.[1].trim() ?? 'unnamed', body })
    }

    // write, routing non-slug names (skill-generator templates, examples) aside
    const seen = new Map<string, number>()
    const entries: Entry[] = []
    for (const { name, body } of found) {
        const valid = VALID_SLUG.test(name)
        let slug = valid ? name : name.toLowerCase().replace(/[^a-z0-9-]+/g, '_').replace(/^_+|_+$/g, '') || 'unnamed'
        const n = (seen.get(slug) ?? 0) + 1
        seen.set(slug, n)
        if (n > 1) slug = `${slug}-${n}`

        const rel = valid ? `skills/${slug}.md` : `skills/_templates/${slug}.md`
        Bun.write(join(out, rel), body)
        entries.push({
            kind: 'skill',
            slug,
            path: rel,
            chars: body.length,
            summary: /description:\s*([^\n]+)/.exec(body.slice(0, 400))?.[1].trim() ?? '',
        })
    }
    return entries
}

// --- prose: heuristic recovery of large instruction strings ----------------

const STOPWORDS = [' the ', ' and ', ' you ', ' to ', ' a ', ' is ', ' of ', ' that ', ' for ']
const SYMBOLS = new Set('{}();=></\\|[]_')

const countOf = (s: string, needle: string): number => {
    let n = 0
    for (let i = s.indexOf(needle); i !== -1; i = s.indexOf(needle, i + needle.length)) n++
    return n
}

const looksLikeProse = (s: string): boolean => {
    if (s.length < 400) return false

    // one pass: binary noise, letter density, symbol density
    let ctrl = 0
    let letters = 0
    let spaces = 0
    let symbols = 0
    for (const c of s) {
        const o = c.codePointAt(0)!
        if (o < 9 || (o > 13 && o < 32)) ctrl++
        else if (c === ' ' || c === '\n') spaces++
        if (SYMBOLS.has(c)) symbols++
        // cheap ASCII test first; fall through to Unicode for accented prose
        if ((o | 32) >= 97 && (o | 32) <= 122) letters++
        else if (o > 127 && /\p{L}/u.test(c)) letters++
    }
    if (ctrl > 4) return false
    if ((letters + spaces) / s.length < 0.8) return false
    // minified JS / regex / SQL is symbol-dense; identifiers use _ | []
    if (symbols / s.length > 0.02) return false

    // real prose has sentences and a healthy dose of function words
    const low = ` ${s.toLowerCase()} `
    if (STOPWORDS.filter((w) => low.includes(w)).length < 4) return false
    if (countOf(s, '. ') + countOf(s, '.\n') + countOf(s, '\n') < 3) return false

    // words are space-separated and short-ish; identifier lists are not
    const words = s.match(/[A-Za-z']+/g) ?? []
    if (words.length < 40) return false
    return words.reduce((a, w) => a + w.length, 0) / words.length <= 9
}

/** Slug from the first ~8 words of the leading prose, ignoring markdown prefixes. */
const slugFromText = (s: string, used: Set<string>): string => {
    const head = s.trim().replace(/^[#>*\-\s`]+/, '').slice(0, 200)
    const base = ((head.toLowerCase().match(/[a-z0-9]+/g) ?? []).slice(0, 8).join('-') || 'block').slice(0, 48)
    let slug = base
    for (let i = 2; used.has(slug); i++) slug = `${base}-${i}`
    used.add(slug)
    return slug
}

/**
 * Every backtick / double-quote string literal in the bundle, left to right,
 * non-overlapping. Done as an explicit scan rather than one big regex: JSC hits
 * its backtracking limit on `(?:[^`\\]|\\.)*` and silently skips the longest
 * literals — which are precisely the prompts worth having.
 */
function* scanLiterals(data: string): Generator<{ quote: string; inner: string }> {
    const exhausted = new Set<string>()
    let i = 0
    while (i < data.length) {
        const bt = exhausted.has('`') ? -1 : data.indexOf('`', i)
        const dq = exhausted.has('"') ? -1 : data.indexOf('"', i)
        if (bt === -1 && dq === -1) return
        const open = bt === -1 ? dq : dq === -1 ? bt : Math.min(bt, dq)
        const quote = data[open]

        const end = findClose(data, open, quote)
        if (end === -1) {
            // nothing closes this one, so no later literal of this kind can close either
            exhausted.add(quote)
            i = open + 1
            continue
        }
        yield { quote, inner: data.slice(open + 1, end) }
        i = end + 1
    }
}

const extractProse = (data: string, out: string, minLen: number): Entry[] => {
    const seen = new Set<string>()
    const used = new Set<string>()
    const texts: string[] = []
    for (const { quote, inner } of scanLiterals(data)) {
        if (inner.length < minLen) continue
        const text = quote === '`' ? unescapeTemplate(inner) : unescapeDoubleQuoted(inner)
        if (text.length < minLen || !looksLikeProse(text)) continue
        const h = String(Bun.hash(text))
        if (seen.has(h)) continue
        seen.add(h)
        texts.push(text)
    }

    texts.sort((a, b) => b.length - a.length)
    return texts.map((text) => {
        const slug = slugFromText(text, used)
        const rel = `prompts/${slug}.md`
        Bun.write(join(out, rel), text)
        return {
            kind: 'prompt' as const,
            slug,
            path: rel,
            chars: text.length,
            summary: text.split('\n').find((l) => l.trim())?.trim() ?? '',
        }
    })
}

// --- dump ------------------------------------------------------------------

/** Stable `latest` symlink next to the versioned dir. */
const linkLatest = (out: string) => {
    const latest = join(out, '..', 'latest')
    try {
        unlinkSync(latest)
    } catch {
        // no previous link
    }
    try {
        symlinkSync(basename(out), latest)
    } catch {
        // non-fatal: the versioned dir is still usable
    }
}

const buildDump = async (binary: string, version: string, out: string, minProse: number): Promise<Manifest> => {
    const data = Buffer.from(await Bun.file(binary).arrayBuffer()).toString('latin1')
    rmSync(out, { recursive: true, force: true })
    mkdirSync(out, { recursive: true })

    const skills = extractSkills(data, out)
    const prose = extractProse(data, out, minProse)
    const dumped = new Date().toISOString().replace('T', ' ').slice(0, 19)
    const manifest: Manifest = { version, source: binary, dumped, entries: [...skills, ...prose] }

    Bun.write(join(out, 'manifest.json'), JSON.stringify(manifest, null, 2))
    Bun.write(
        join(out, 'INDEX.md'),
        [
            `# Claude Code embedded prompts — ${version}`,
            '',
            `Source: \`${binary}\`  `,
            `Dumped: ${dumped}  `,
            `Skills: ${skills.length}  ·  Prose blocks: ${prose.length}`,
            '',
            '## Skills',
            ...skills.map((e) => `- [\`${e.slug}\`](${e.path}) — ${e.summary}`),
            '',
            '## Prose blocks (heuristic, largest first)',
            ...prose.map((e) => `- [\`${e.slug}\`](${e.path}) (${e.chars.toLocaleString()} ch) — ${e.summary.slice(0, 80)}`),
        ].join('\n') + '\n',
    )
    linkLatest(out)
    return manifest
}

// --- menu ------------------------------------------------------------------

const human = (n: number) => (n < 1000 ? `${n}` : n < 1_000_000 ? `${(n / 1000).toFixed(1)}k` : `${(n / 1e6).toFixed(1)}m`)

/**
 * fzf feed: a header line, then one `<relpath>\t<display>` line per entry.
 * Colors are baked in for `fzf --ansi`; the shell splits on the tab.
 */
const printMenu = (m: Manifest) => {
    const skills = m.entries.filter((e) => e.kind === 'skill').length
    const width = Math.min(38, Math.max(...m.entries.map((e) => e.slug.length)))

    // no dump path here — the header shares the narrow list pane and would be
    // truncated; ctrl-o opens the folder instead
    const lines = [
        `${pc.bold(`claude ${m.version}`)}  ${pc.cyan(`${skills} skills`)} · ` +
            pc.magenta(`${m.entries.length - skills} prompts`),
        ...m.entries.map((e) => {
            const badge = e.kind === 'skill' ? pc.cyan(' skill') : pc.magenta('prompt')
            const name = e.slug.length > width ? e.slug.slice(0, width - 1) + '…' : e.slug.padEnd(width)
            const summary = e.summary.replace(/\s+/g, ' ').slice(0, 140)
            return `${e.path}\t${badge} ${pc.bold(name)} ${pc.dim(human(e.chars).padStart(6))}  ${pc.dim(summary)}`
        }),
    ]
    try {
        process.stdout.write(lines.join('\n') + '\n')
    } catch {
        // reader went away (fzf quit, piped to head) — nothing to report
    }
}

// --- main ------------------------------------------------------------------

const flag = (name: string) => process.argv.includes(name)
const opt = (name: string) => {
    const i = process.argv.indexOf(name)
    return i === -1 ? undefined : process.argv[i + 1]
}

if (flag('--help') || flag('-h')) {
    err(`claude-prompts — dump the prompts baked into the Claude Code binary

  --binary PATH     claude executable (default: ~/.local/bin/claude, then PATH)
  --out DIR         output dir (default: ~/.cache/claude-prompts/<version>)
  --min-prose N     min length of a recovered prose block (default: 500)
  -f, --force       re-dump even if this version was already extracted
  --list            print the fzf menu to stdout`)
    process.exit(0)
}

const binary = resolveBinary(opt('--binary'))
const version = binaryVersion(binary)
const out = opt('--out')?.replace(/^~/, homedir()) ?? join(homedir(), '.cache/claude-prompts', version)
const force = flag('-f') || flag('--force')

const hasFiles = (p: string) => {
    try {
        return readdirSync(p).length > 0
    } catch {
        return false
    }
}

// a dump is content-identical for a given version, so reuse it unless forced
let manifest: Manifest | undefined
if (!force && hasFiles(out)) {
    manifest = await Bun.file(join(out, 'manifest.json'))
        .json()
        .catch(() => undefined)
    if (manifest) linkLatest(out)
}

if (!manifest) {
    err(pc.dim(`extracting prompts from claude ${version}…`))
    const started = Bun.nanoseconds()
    manifest = await buildDump(binary, version, out, Number(opt('--min-prose') ?? 500))
    const skills = manifest.entries.filter((e) => e.kind === 'skill').length
    err(
        `${pc.green('✓')} ${pc.bold(`claude ${version}`)}  ${pc.cyan(`${skills} skills`)} · ` +
            `${pc.magenta(`${manifest.entries.length - skills} prompts`)} ` +
            pc.dim(`in ${((Bun.nanoseconds() - started) / 1e9).toFixed(1)}s → ${out}`),
    )
}

if (flag('--list')) printMenu(manifest)
