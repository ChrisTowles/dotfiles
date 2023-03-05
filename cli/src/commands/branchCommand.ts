import { type Command, Option } from 'commander'
import prompts, { type Choice } from 'prompts'
import c from 'picocolors'
import { Fzf } from 'fzf'
import { getIssues, isGithubCliInstalled } from '../utils/gh-cli-wrapper'
import { limitText } from '../render'

export interface BranchCommandOptions {
  cwd: string
}

const checkPreqrequisites = async () => {
  // todo, cache this like nr does
  const cliInstalled = await isGithubCliInstalled()
  if (!cliInstalled) {
    console.log('Github CLI not installed')
    process.exit(1)
  }
}

export const SetupBranchCommand = (program: Command): void => {
  program.command('branch')
    .description('create branch from github ticket')
    .addOption(new Option('-C, --cwd <cwd>', 'specify the current working directory'))
    .action(async (args: BranchCommandOptions) => {
      await checkPreqrequisites()

      const currentIssues = await getIssues({ assignedToMe: true })
      if (currentIssues.length === 0) {
        console.log(c.yellow('No issues found'))
        process.exit(1)
      }
      else {
        console.log(c.green(`${currentIssues.length} Issues found assigned to you`))
      }

      const choices: Choice[] = currentIssues.map(i =>
        ({
          title: i.number.toString(),
          value: i.number,
          description: limitText(i.title, 15),
        } as Choice),
      )

      const fzf = new Fzf(currentIssues, {
        selector: item => `${item.number} ${item.title}`,
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
            return results.map(r => choices.find(c => c.value === r.item.number))
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
