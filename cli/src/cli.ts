import { Command } from 'commander'
import { SetupBranchCommand } from './commands/branchCommand'

const program = new Command()

program.name('t')
  .description('a common scripts i use')

SetupBranchCommand(program)

program.parse(process.argv)

