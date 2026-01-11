#!/usr/bin/env bun
// StatusLine script for Claude Code
// Features: progress bar, cache efficiency, cost estimate, git status, thinking indicator

import { appendFile } from 'fs/promises'
import { createColors } from 'picocolors'

// Force colors on - statusline always needs colors regardless of TTY detection
const pc = createColors(true)

// Updated from Claude vCode 2.0.76
interface StatusLineInput {
    session_id: string
    transcript_path: string
    cwd: string
    model: {
        id: string
        display_name?: string
    }
    workspace: {
        current_dir: string
        project_dir: string
    }
    version: string
    output_style: {
        name: string
    }
    cost: {
        total_cost_usd: number
        total_duration_ms: number
        total_api_duration_ms: number
        total_lines_added: number
        total_lines_removed: number
    }
    context_window: {
        total_input_tokens: number
        total_output_tokens: number
        context_window_size: number
        current_usage: {
            input_tokens: number
            output_tokens: number
            cache_creation_input_tokens: number
            cache_read_input_tokens: number
        }
    }
    exceeds_200k_tokens: boolean
}


// Color helper using picocolors
type ColorName = 'red' | 'green' | 'yellow' | 'blue' | 'magenta' | 'cyan' | 'dim' | 'bold' | 'brightCyan' | 'orange'

export function c(color: ColorName, text: string): string {
    switch (color) {
        case 'red': return pc.red(text)
        case 'green': return pc.green(text)
        case 'yellow': return pc.yellow(text)
        case 'blue': return pc.blue(text)
        case 'magenta': return pc.magenta(text)
        case 'cyan': return pc.cyan(text)
        case 'dim': return pc.dim(text)
        case 'bold': return pc.bold(text)
        case 'brightCyan': return pc.cyanBright(text)
        case 'orange': return pc.yellow(text) // picocolors doesn't have orange, use yellow
        default: return text
    }
}

// Progress bar with smooth Unicode blocks
export function progressBar(percent: number, width = 15): string {
    const clamped = Math.max(0, Math.min(100, percent))
    const filled = Math.round((clamped / 100) * width)
    const empty = width - filled
    return '▰'.repeat(filled) + '▱'.repeat(empty)
}

// Color based on percentage thresholds
export function contextColor(pct: number): ColorName {
    if (pct < 40) return 'green'
    if (pct < 60) return 'yellow'
    if (pct < 80) return 'orange'
    return 'red'
}

// Short model name
export function shortModel(model: string): string {
    return model
        .replace('Claude ', '')
        .replace(' (Preview)', '')
        .replace(' (Latest)', '')
}

// Calculate cache ratio from usage data
export function calcCacheRatio(usage: { input_tokens?: number; cache_creation_input_tokens?: number; cache_read_input_tokens?: number } | null): number {
    if (!usage || typeof usage.cache_read_input_tokens !== 'number') return 0
    const totalInput = (usage.input_tokens || 0) + (usage.cache_creation_input_tokens || 0) + (usage.cache_read_input_tokens || 0)
    if (totalInput <= 0) return 0
    return Math.round((usage.cache_read_input_tokens / totalInput) * 100)
}

// Shorten directory path
export function shortDir(dir: string, maxLen = 25): string {
    const shortened = dir.replace(/^\/home\/[^/]+/, '~')
    return shortened.length > maxLen ? '...' + shortened.slice(-(maxLen - 3)) : shortened
}

// Format subscription usage display
function formatSubUsage(usage: { percent: number; remainingMins: number }, showRemaining = true): string {
    const color = usage.percent < 50 ? 'green' : usage.percent < 80 ? 'yellow' : 'red'
    if (!showRemaining) return c(color, `sub used ${usage.percent}%`)
    const hrs = Math.floor(usage.remainingMins / 60)
    const mins = usage.remainingMins % 60
    const timeStr = hrs > 0 ? `${hrs}h${mins}m` : `${mins}m`
    return c(color, `sub used ${usage.percent}% rem ${timeStr}`)
}

// Cache config for ccusage
const CACHE_FILE = '/tmp/claude-statusline-ccusage.json'
const CACHE_TTL_MS = 2 * 60 * 1000 // 2 minutes

interface CachedUsage {
    percent: number
    remainingMins: number
    timestamp: number
}

// Get subscription usage from ccusage with file caching
async function getSubscriptionUsage(): Promise<{ percent: number; remainingMins: number } | null> {
    try {
        // Check cache first
        const cacheFile = Bun.file(CACHE_FILE)
        if (await cacheFile.exists()) {
            const cached: CachedUsage = await cacheFile.json()
            if (Date.now() - cached.timestamp < CACHE_TTL_MS) {
                return { percent: cached.percent, remainingMins: cached.remainingMins }
            }
        }

        // Fetch fresh data
        const proc = Bun.spawn(['ccusage', 'blocks', '--active', '--json', '--token-limit', 'max'], {
            stdout: 'pipe',
            stderr: 'ignore',
        })
        const text = await new Response(proc.stdout).text()
        const data = JSON.parse(text)
        const block = data.blocks?.[0]
        if (block?.tokenLimitStatus) {
            const result = {
                percent: Math.round(block.tokenLimitStatus.percentUsed),
                remainingMins: block.projection?.remainingMinutes || 0,
            }
            // Write to cache
            await Bun.write(CACHE_FILE, JSON.stringify({ ...result, timestamp: Date.now() }))
            return result
        }
        return null
    } catch {
        return null
    }
}

// Get git info using Bun.spawn
async function getGitInfo(dir: string): Promise<string> {
    try {
        // Get branch name
        const branchProc = Bun.spawn(['git', '-C', dir, '--no-optional-locks', 'branch', '--show-current'], {
            stdout: 'pipe',
            stderr: 'ignore',
        })
        const branchText = await new Response(branchProc.stdout).text()
        const branch = branchText.trim()
        if (!branch) return ''

        // Check status in parallel
        const [statusProc, aheadProc, behindProc] = await Promise.all([
            Bun.spawn(['git', '-C', dir, '--no-optional-locks', 'status', '--porcelain'], { stdout: 'pipe', stderr: 'ignore' }),
            Bun.spawn(['git', '-C', dir, '--no-optional-locks', 'rev-list', '@{u}..', '--count'], { stdout: 'pipe', stderr: 'ignore' }),
            Bun.spawn(['git', '-C', dir, '--no-optional-locks', 'rev-list', '..@{u}', '--count'], { stdout: 'pipe', stderr: 'ignore' }),
        ])

        // Count changed files from porcelain output
        const statusText = await new Response(statusProc.stdout).text()
        const changedFiles = statusText.trim().split('\n').filter(l => l.length > 0).length

        const ahead = parseInt((await new Response(aheadProc.stdout).text()).trim()) || 0
        const behind = parseInt((await new Response(behindProc.stdout).text()).trim()) || 0

        let status = ''
        if (changedFiles > 0) status += `*${changedFiles}`
        if (ahead > 0) status += `↑${ahead}`
        if (behind > 0) status += `↓${behind}`

        return c('yellow', `[${branch}${status}]`)
    } catch {
        return ''
    }
}


async function main() {
    const logPath = `${process.env.HOME}/.claude/statusline-input.log`
    let inputText = ''

    try {
        // Read JSON from stdin
        inputText = await Bun.stdin.text()
        const input: StatusLineInput = JSON.parse(inputText)



        // Directory (shortened)
        const dir = input.workspace.current_dir
        const displayDir = shortDir(dir)

        // Model
        const model = shortModel(input.model.display_name || input.model.id)

        // Context percentage
        const totalTokens = input.context_window.total_input_tokens + input.context_window.total_output_tokens
        const contextSize = input.context_window.context_window_size
        const contextPct = contextSize > 0 ? Math.round((totalTokens / contextSize) * 100) : 0

        // Cache efficiency
        const cacheRatio = calcCacheRatio(input.context_window.current_usage)

        // Git info and subscription usage in parallel
        const [gitInfo, subUsage] = await Promise.all([
            getGitInfo(dir),
            getSubscriptionUsage(),
        ])
        const gitPart = gitInfo ? ` ${gitInfo}` : ''
        const showRemaining = process.env.STATUSLINE_HIDE_REMAINING !== '1'
        const subPart = subUsage ? formatSubUsage(subUsage, showRemaining) : ''

        // Progress bar
        const bar = progressBar(contextPct)
        const pctColor = contextColor(contextPct)

        // Version
        const version = input.version ? c('dim', `v${input.version}`) : ''

        // Build output
        const parts = [
            c('blue', displayDir),
            gitPart,
            model.includes('Opus') ? c('brightCyan', `[${model}]`) : c('red', `[!${model}]`),
            version,
            c(pctColor, `${bar} ${contextPct}%`),
            cacheRatio > 0 ? c('green', `cr ${cacheRatio}%`) : '',
            subPart,
        ].filter(Boolean)

        console.log(parts.join(' '))
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err)
        console.log(c('red', `[statusline err: ${msg.slice(0, 250)}]`))
        console.log(c('dim', `[see ${logPath} for details]`))
             
        await appendFile(logPath, inputText + '\n')

    }
}

// Only run main when executed directly
if (import.meta.main) {
    main()
}
