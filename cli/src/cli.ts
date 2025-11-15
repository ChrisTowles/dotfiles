import { Command } from 'commander'
import { SetupAwsConsoleLoginCommand } from './commands/awsConsoleLoginCommand'
import { SetupBranchCleanupCommand } from './commands/branchCleanupCommand'
import { SetupLastEpochFilterCommand } from './commands/lastEpochFilterCommand'


const program = new Command()

program.name('t')
  .description('a common scripts i use')
SetupAwsConsoleLoginCommand(program)
SetupBranchCleanupCommand(program)
SetupLastEpochFilterCommand(program)


program.configureHelp({
  sortSubcommands: true,
})

program.parse(process.argv)
