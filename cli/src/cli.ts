import { Command } from 'commander'
import { SetupAwsConsoleLoginCommand } from './commands/awsConsoleLoginCommand'
import { SetupBranchCommand } from './commands/branchCommand'
import { SetupBranchCleanupCommand } from './commands/branchCleanupCommand'
import { SetupTodayCommand } from './commands/todayCommand'

const program = new Command()

program.name('t')
  .description('a common scripts i use')

SetupAwsConsoleLoginCommand(program)
SetupBranchCommand(program)
SetupBranchCleanupCommand(program)
SetupTodayCommand(program)

// program.command('list', { isDefault: true })
//   .description('give option to list commands default command')
//   .action(async () => {
//     console.log('default command')
//   })

program.configureHelp({
  sortSubcommands: true,
})

program.parse(process.argv)
