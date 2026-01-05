#!/usr/bin/env bun
// StatusLine script for Claude Code
// Features: progress bar, cache efficiency, cost estimate, git status, thinking indicator

import { appendFile } from 'fs/promises'


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


// ANSI color codes
const colors = {
    reset: '\x1b[0m',
    bold: '\x1b[1m',
    dim: '\x1b[2m',
    // Foreground
    black: '\x1b[30m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m',
    // Bright foreground
    brightRed: '\x1b[91m',
    brightGreen: '\x1b[92m',
    brightYellow: '\x1b[93m',
    brightBlue: '\x1b[94m',
    brightMagenta: '\x1b[95m',
    brightCyan: '\x1b[96m',
    // 256-color
    orange: '\x1b[38;5;208m',
}

function c(color: keyof typeof colors, text: string): string {
    return `${colors[color]}${text}${colors.reset}`
}

// Progress bar with smooth Unicode blocks
function progressBar(percent: number, width = 15): string {
    const filled = Math.round((percent / 100) * width)
    const empty = width - filled
    return '▰'.repeat(filled) + '▱'.repeat(empty)
}

// Color based on percentage thresholds
function contextColor(pct: number): keyof typeof colors {
    if (pct < 40) return 'green'
    if (pct < 60) return 'yellow'
    if (pct < 80) return 'orange'
    return 'red'
}

// Short model name
function shortModel(model: string): string {
    return model
        .replace('Claude ', '')
        .replace(' (Preview)', '')
        .replace(' (Latest)', '')
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

    // Log input to file for debugging
    const logPath = `${process.env.HOME}/.claude/statusline-input.log`

    // Read JSON from stdin
    const inputText = await Bun.stdin.text()
    const input: StatusLineInput = JSON.parse(inputText)
    
    try {



        // Directory (shortened)
        const dir = input.workspace.current_dir
        const shortDir = dir.replace(/^\/home\/[^/]+/, '~')
        const displayDir = shortDir.length > 25 ? '...' + shortDir.slice(-22) : shortDir

        // Model
        const model = shortModel(input.model.display_name || input.model.id)

        // Context percentage
        const totalTokens = input.context_window.total_input_tokens + input.context_window.total_output_tokens
        const contextSize = input.context_window.context_window_size
        const contextPct = contextSize > 0 ? Math.round((totalTokens / contextSize) * 100) : 0

        // Cache efficiency
        const usage = input.context_window.current_usage
        let cacheRatio = 0
        if (usage) {
            const totalInput = usage.input_tokens + usage.cache_creation_input_tokens + usage.cache_read_input_tokens
            if (totalInput > 0) {
                cacheRatio = Math.round((usage.cache_read_input_tokens / totalInput) * 100)
            }
        }

        // Git info
        const gitInfo = await getGitInfo(dir)
        const gitPart = gitInfo ? ` ${gitInfo}` : ''

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
        ].filter(Boolean)

        console.log(parts.join(' '))
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err)
        console.log(c('red', `[statusline err: ${msg.slice(0, 250)}]`))
        console.log(c('dim', `[see ${logPath} for details]`))
             
        await appendFile(logPath, inputText + '\n')

    }
}

main()
