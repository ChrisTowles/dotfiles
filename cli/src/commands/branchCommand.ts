import { type Command, Option } from 'commander'
import prompts, { type Choice } from 'prompts'
import c from 'picocolors'
import { Fzf } from 'fzf'

export interface BranchCommandOptions {
  cwd: string
}

export const SetupBranchCommand = (program: Command): void => {
  program.command('branch')
    .description('create branch from github ticket')
    .addOption(new Option('-C, --cwd <cwd>', 'specify the current working directory'))
    .action(async (args: BranchCommandOptions) => {
      const raw = [
        { key: 'value1', description: 'description1' },
        { key: 'value2', description: 'description2' },
      ]

      const terminalColumns = process.stdout?.columns || 80

      function limitText(text: string, maxWidth: number) {
        if (text.length <= maxWidth)
          return text
        return `${text.slice(0, maxWidth)}${c.dim('…')}`
      }
      const choices: Choice[] = raw
        .map(({ key, description }) => ({
          title: key,
          value: key,
          description: limitText(description, terminalColumns - 15),
        }))

      const fzf = new Fzf(raw, {
        selector: item => `${item.key} ${item.description}`,
        casing: 'case-insensitive',
      })

      try {
        const { fn } = await prompts({
          name: 'fn',
          message: 'script to run',
          type: 'autocomplete',
          choices,
          async suggest(input: string, choices: Choice[]) {
            const results = fzf.find(input)
            return results.map(r => choices.find(c => c.value === r.item.key))
          },
        })
        if (!fn)
          return

        console.log('branch', args)
        console.log('fn', fn)
        // args.push(fn)
      }
      catch (e) {
        process.exit(1)
      }
    })
}
