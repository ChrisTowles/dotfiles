import { type Command } from 'commander'
import c from 'picocolors'
import { getDefaultMainBranchName, getMergedBranches, isGitDirectory } from '../utils/git-wrapper'

const checkPreqrequisites = async () => {
  // todo, cache this like nr does
  const isGitDir = await isGitDirectory()
  if (!isGitDir) {
    console.log('Not a Git Directory.')
    process.exit(1)
  }
}

export const SetupBranchCleanupCommand = (program: Command): void => {
  program.command('branch-cleanup')
    .description('Show branches that can be deleted because already deleted.')
    .action(async (args) => {
      await checkPreqrequisites()

      const mainBranchName = await getDefaultMainBranchName()
      console.log(`Main Branch Name: ${mainBranchName}`)
      const alreadyMergedBranches = await getMergedBranches(mainBranchName)

      if (alreadyMergedBranches.length === 0) {
        console.log(c.yellow('No branches found to cleanup'))
        process.exit(1)
      }

      console.log(`Found ${c.green(alreadyMergedBranches.length)} branches that have already been merged to ${mainBranchName}.`)
      console.log('')
      console.log(c.yellow('Run the following commands to delete these branches:'))
      console.log('')
      // TODO: add a flag to actually delete the branches
      alreadyMergedBranches.forEach((branch) => {
        console.log(`git branch -d ${branch}`)
      })

      console.log('')
      console.log(c.green('Done!'))
    })
}
