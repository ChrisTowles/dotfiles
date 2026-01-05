import { describe, it, expect } from 'vitest'
import { spawn } from 'child_process'
import { join } from 'path'
import { progressBar, contextColor, shortModel, calcCacheRatio, shortDir } from './statusline'

// Helper to run statusline script with input
function runStatusline(input: string): Promise<{ stdout: string; stderr: string; code: number }> {
    return new Promise((resolve) => {
        const proc = spawn('bun', [join(__dirname, 'statusline.ts')], {
            stdio: ['pipe', 'pipe', 'pipe'],
        })

        let stdout = ''
        let stderr = ''

        proc.stdout.on('data', (data) => { stdout += data.toString() })
        proc.stderr.on('data', (data) => { stderr += data.toString() })

        proc.on('close', (code) => {
            resolve({ stdout, stderr, code: code ?? 1 })
        })

        proc.stdin.write(input)
        proc.stdin.end()
    })
}

describe('progressBar', () => {
    it('returns empty bar at 0%', () => {
        expect(progressBar(0)).toBe('▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱')
    })

    it('returns full bar at 100%', () => {
        expect(progressBar(100)).toBe('▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰')
    })

    it('returns half bar at 50%', () => {
        const bar = progressBar(50)
        expect(bar.length).toBe(15)
        expect(bar.match(/▰/g)?.length).toBe(8) // rounds 7.5 to 8
    })

    it('clamps negative values to 0%', () => {
        expect(progressBar(-50)).toBe('▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱')
    })

    it('clamps values over 100% to full bar', () => {
        // This was the bug - 151% caused negative repeat
        expect(progressBar(151)).toBe('▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰')
    })

    it('handles custom width', () => {
        expect(progressBar(100, 5)).toBe('▰▰▰▰▰')
        expect(progressBar(0, 5)).toBe('▱▱▱▱▱')
    })
})

describe('contextColor', () => {
    it('returns green below 40%', () => {
        expect(contextColor(0)).toBe('green')
        expect(contextColor(39)).toBe('green')
    })

    it('returns yellow at 40-59%', () => {
        expect(contextColor(40)).toBe('yellow')
        expect(contextColor(59)).toBe('yellow')
    })

    it('returns orange at 60-79%', () => {
        expect(contextColor(60)).toBe('orange')
        expect(contextColor(79)).toBe('orange')
    })

    it('returns red at 80%+', () => {
        expect(contextColor(80)).toBe('red')
        expect(contextColor(100)).toBe('red')
        expect(contextColor(151)).toBe('red')
    })
})

describe('shortModel', () => {
    it('removes Claude prefix', () => {
        expect(shortModel('Claude Opus 4.5')).toBe('Opus 4.5')
    })

    it('removes (Preview) suffix', () => {
        expect(shortModel('Sonnet 3.5 (Preview)')).toBe('Sonnet 3.5')
    })

    it('removes (Latest) suffix', () => {
        expect(shortModel('Claude Sonnet 4 (Latest)')).toBe('Sonnet 4')
    })

    it('handles plain model names', () => {
        expect(shortModel('Opus 4.5')).toBe('Opus 4.5')
    })
})

describe('calcCacheRatio', () => {
    it('returns 0 for null usage', () => {
        expect(calcCacheRatio(null)).toBe(0)
    })

    it('returns 0 when cache_read_input_tokens is missing', () => {
        expect(calcCacheRatio({ input_tokens: 100 })).toBe(0)
    })

    it('returns 0 when total input is 0', () => {
        expect(calcCacheRatio({ cache_read_input_tokens: 0 })).toBe(0)
    })

    it('calculates correct ratio', () => {
        expect(calcCacheRatio({
            input_tokens: 5000,
            cache_creation_input_tokens: 2000,
            cache_read_input_tokens: 8000,
        })).toBe(53) // 8000 / 15000 = 53%
    })

    it('handles real-world input from log', () => {
        // From actual statusline-input.log that caused errors
        const usage = {
            input_tokens: 0,
            output_tokens: 109,
            cache_creation_input_tokens: 1099,
            cache_read_input_tokens: 139701,
        }
        expect(calcCacheRatio(usage)).toBe(99) // 139701 / 140800 = 99%
    })
})

describe('shortDir', () => {
    it('replaces /home/user with ~', () => {
        expect(shortDir('/home/user/code/project')).toBe('~/code/project')
    })

    it('truncates long paths', () => {
        const long = '/home/user/code/very/long/nested/path/here'
        const result = shortDir(long)
        expect(result.length).toBeLessThanOrEqual(25)
        expect(result.startsWith('...')).toBe(true)
    })

    it('keeps short paths unchanged', () => {
        expect(shortDir('/home/user/code')).toBe('~/code')
    })

    it('handles custom max length', () => {
        const result = shortDir('/home/user/code/project', 15)
        expect(result.length).toBeLessThanOrEqual(15)
    })
})

describe('real-world inputs from log', () => {
    it('handles >100% context usage without crashing', () => {
        // Input that caused "repeat argument must be >= 0" error
        const totalTokens = 209156 + 93041 // 302,197
        const contextSize = 200000
        const contextPct = Math.round((totalTokens / contextSize) * 100) // 151%

        // This should not throw
        expect(() => progressBar(contextPct)).not.toThrow()
        expect(progressBar(contextPct)).toBe('▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰')
    })

    it('handles null current_usage without crashing', () => {
        expect(() => calcCacheRatio(null)).not.toThrow()
        expect(calcCacheRatio(null)).toBe(0)
    })

    // Actual problematic inputs from ~/.claude/statusline-input.log
    const invalidInputs = [
        {
            name: 'null current_usage with Sonnet model',
            input: {
                context_window: {
                    total_input_tokens: 8506,
                    total_output_tokens: 3112,
                    context_window_size: 200000,
                    current_usage: null,
                },
                model: { id: 'claude-sonnet-4-5-20250929', display_name: 'Sonnet 4.5' },
                workspace: { current_dir: '/home/user/code/p/dotfiles',
                     project_dir: '/home/user/code/p/dotfiles' 
                },
            },
        },
        {
            name: '>100% context (151%) with Opus model',
            input: {
                context_window: {
                    total_input_tokens: 209156,
                    total_output_tokens: 93041,
                    context_window_size: 200000,
                    current_usage: {
                        input_tokens: 0,
                        output_tokens: 109,
                        cache_creation_input_tokens: 1099,
                        cache_read_input_tokens: 139701,
                    },
                },
                model: { id: 'claude-opus-4-5-20251101', display_name: 'Opus 4.5' },
                workspace: { current_dir: '/home/user/code/p/blog/packages/blog', project_dir: '/home/user/code/p/blog' },
            },
        },
    ]

    invalidInputs.forEach(({ name, input }) => {
        it(`processes "${name}" without throwing`, () => {
            const { context_window, model, workspace } = input

            // Calculate values the same way statusline.ts does
            const totalTokens = context_window.total_input_tokens + context_window.total_output_tokens
            const contextPct = context_window.context_window_size > 0
                ? Math.round((totalTokens / context_window.context_window_size) * 100)
                : 0

            // All these should not throw
            expect(() => progressBar(contextPct)).not.toThrow()
            expect(() => contextColor(contextPct)).not.toThrow()
            expect(() => calcCacheRatio(context_window.current_usage)).not.toThrow()
            expect(() => shortModel(model.display_name || model.id)).not.toThrow()
            expect(() => shortDir(workspace.current_dir)).not.toThrow()
        })
    })
})

describe('statusline script integration', () => {
    it('prints error message for invalid JSON input', async () => {
        const result = await runStatusline('not valid json')

        expect(result.stdout).toContain('[statusline err:')
        expect(result.stdout).toContain('see')
        expect(result.stdout).toContain('statusline-input.log')
    })

    it('prints error message for empty input', async () => {
        const result = await runStatusline('')

        expect(result.stdout).toContain('[statusline err:')
    })

    it('prints error message for missing required fields', async () => {
        const result = await runStatusline('{"foo": "bar"}')

        expect(result.stdout).toContain('[statusline err:')
    })

    it('succeeds with valid input', async () => {
        const validInput = JSON.stringify({
            session_id: 'test',
            transcript_path: '/tmp/test',
            cwd: '/home/user/code',
            model: { id: 'claude-opus-4-5', display_name: 'Opus 4.5' },
            workspace: { current_dir: '/home/user/code', project_dir: '/home/user/code' },
            version: '2.0.76',
            output_style: { name: 'default' },
            cost: {},
            context_window: {
                total_input_tokens: 1000,
                total_output_tokens: 500,
                context_window_size: 200000,
                current_usage: { input_tokens: 100, cache_read_input_tokens: 500, cache_creation_input_tokens: 50 },
            },
            exceeds_200k_tokens: false,
        })

        const result = await runStatusline(validInput)

        expect(result.stdout).not.toContain('[statusline err:')
        expect(result.stdout).toContain('Opus 4.5')
    })
})
