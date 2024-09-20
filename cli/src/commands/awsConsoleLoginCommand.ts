import { type Command } from 'commander'
import c from 'picocolors'
import { } from '@aws-sdk/credential-provider-ini'


export const SetupAwsConsoleLoginCommand = (program: Command): void => {
  program.command('aws-console')
    .description('use aws cli permissions to open aws console')
    .action(async (args) => {

      console.log(c.blue('Setting up AWS Console Login...' + client))
      // const mainBranchName = await getDefaultMainBranchName()
      // console.log(`Main Branch Name: ${mainBranchName}`)
      // const alreadyMergedBranches = await getMergedBranches(mainBranchName)

      // if (alreadyMergedBranches.length === 0) {
      //   console.log(c.yellow('No branches found to cleanup'))
      //   process.exit(0)
      // }

      // console.log(`Found ${c.green(alreadyMergedBranches.length)} branches that have already been merged to ${mainBranchName}.`)
      // console.log('')
      // console.log(c.yellow('Run the following commands to delete these branches:'))
      // console.log('')
      // // TODO: add a flag to actually delete the branches
      // alreadyMergedBranches.forEach((branch) => {
      //   console.log(`git branch -d ${branch}`)
      // })

      console.log('')
      console.log(c.green('Done!'))
    })
}
