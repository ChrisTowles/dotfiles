import type { Command } from 'commander'
import { Option } from 'commander'

export interface BranchCommandOptions {
  cwd: string
}

export const SetupBranchCommand = (program: Command): void => {
  program.command('branch')
    .description('create branch from github ticket')
    .addOption(new Option('-C, --cwd <cwd>', 'specify the current working directory'))
    .action((args: BranchCommandOptions) => {
      // eslint-disable-next-line no-console
      console.log('branch', args)
    })
}
