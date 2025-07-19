import { type Command, Option } from 'commander'
import prompts, { type Choice } from 'prompts'
import c from 'picocolors'
import { Fzf } from 'fzf'
import _ from 'lodash'
import type { Issue } from '../utils/gh-cli-wrapper'
import { getIssues, isGithubCliInstalled } from '../utils/gh-cli-wrapper'
import { getTerminalColumns, limitText, printWithHexColor } from '../render'
import { createBranch } from '../utils/git-wrapper'

export interface BranchCommandOptions {
  cwd: string
  unassigned?: boolean
}

const checkPreqrequisites = async () => {
  // todo, cache this like nr does
  const cliInstalled = await isGithubCliInstalled()
  if (!cliInstalled) {
    console.log('Github CLI not installed')
    process.exit(1)
  }
}

export const createBranchNameFromIssue = (selectedIssue: Issue): string => {
  let slug = selectedIssue.title.toLowerCase()
  slug = slug.trim()
  slug = slug.replaceAll(' ', '-')
  slug = slug.replace(/[^0-9a-zA-Z_]/g, '-')
  slug = slug.replaceAll('--', '-')
  slug = slug.replaceAll('--', '-') // in case there are multiple spaces
  slug = slug.replaceAll('--', '-') // in case there are multiple spaces
  slug = _.trimEnd(slug, '-') // take off any extra dashes at the end
  

  const branchName = `feature/${selectedIssue.number}-${slug}`
  return branchName
}

export const SetupBranchCommand = (program: Command): void => {
  program.command('branch')
    .description('create branch from github ticket')
    .addOption(new Option('-C, --cwd <cwd>', 'specify the current working directory'))
    .addOption(new Option('--unassigned', 'only show issues unassigned to me'))
    .action(async (args: BranchCommandOptions) => {
      await checkPreqrequisites()

      const assignedToMe = !args.unassigned ? true : false
      console.log('Assigned to me:', assignedToMe)

      const currentIssues = await getIssues({ assignedToMe })
      if (currentIssues.length === 0) {
        console.log(c.yellow('No issues found, check assignments'))
        process.exit(1)
      }
      else {
        console.log(c.green(`${currentIssues.length} Issues found assigned to you`))
      }

      // Alot of work but the goal is to make the table look nice and the labels colored.
      let lineMaxLength = getTerminalColumns()
      const longestNumber = Math.max(...currentIssues.map(i => i.number.toString().length))
      const longestLabels = Math.max(...currentIssues.map(i => i.labels.map(x => x.name).join(', ').length))

      // limit how big the table can be
      lineMaxLength = lineMaxLength > 130 ? 130 : lineMaxLength
      const descriptionLength = lineMaxLength - longestNumber - longestLabels - 15 // 15 is for padding

      const choices: Choice[] = currentIssues.map((i) => {
        const labelText = i.labels.map(l => printWithHexColor({ msg: l.name, hex: l.color })).join(', ')
        const labelTextNoColor = i.labels.map(l => l.name).join(', ') // due to color adding length to the string
        const labelStartpad = longestLabels - labelTextNoColor.length
        return {
          title: i.number.toString(),
          value: i.number,
          description: `${limitText(i.title, descriptionLength).padEnd(descriptionLength)} ${''.padStart(labelStartpad)}${labelText}`, // pads to make sure the labels are aligned, no diea why padStart doesn't work on labelText
        } as Choice
      },
      )
      choices.push({ title: 'Cancel', value: 'cancel' })

      const fzf = new Fzf(choices, {
        selector: item => `${item.value} ${item.description}`,
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
            return results.map(r => choices.find(c => c.value === r.item.value))
          },
        })
        if (!fn)
          return

        if (fn === 'cancel') {
          console.log(c.yellow('Canceled.'))
          process.exit(0)
        }
        const selectedIssue = currentIssues.find(i => i.number === fn)!
        console.log(`Selected issue ${c.green(selectedIssue.number)} - ${c.green(selectedIssue.title)}`)

        const branchName = createBranchNameFromIssue(selectedIssue)

        createBranch({ branchName })
      }
      catch (e) {
        process.exit(1)
      }
    })
}
