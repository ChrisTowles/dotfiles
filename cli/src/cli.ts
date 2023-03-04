import { Command } from 'commander'
import { SetupBranchCommand } from './commands/branchCommand'
import { SetupTodayCommand } from './commands/todayCommand'

const program = new Command()

program.name('t')
  .description('a common scripts i use')

SetupBranchCommand(program)
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

