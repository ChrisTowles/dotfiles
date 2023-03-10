import { $, os } from 'zx'

export const isGitDirectory = async (): Promise<boolean> => {
  try {
    $.verbose = false
    const result = await $`git status`
    return result.stdout.includes('On branch')
  }
  catch (e) {
    return false
  }
}

const filterBranchNames = (branchNames: string[]): string[] => {
  const result = branchNames.map((branchName) => {
    if (branchName.startsWith('* ')) { // mac has a `* ` in front of the current branch
      branchName = branchName.slice(2)
    }
    return branchName.trim()
  })
    .filter(branchName => branchName !== '')

  return result
}

export const createBranch = async ({ branchName }: { branchName: string }): Promise<string> => {
  const result = await $`git checkout -b "${branchName}"`
  const test = result.stdout
  return test
}

export const getMergedBranches = async (mainBranchName = 'main'): Promise<string[]> => {
  // Note: git branch --merged returns the current branch name as well
  // also won't branches that were squashed
  const result = await $`git branch --merged "${mainBranchName}"`
  let branchNames = result.stdout.split(os.EOL)
  branchNames = filterBranchNames(branchNames)

  return branchNames.filter(branchName => branchName !== mainBranchName)
}

export const getLocalBranchNames = async (): Promise<string[]> => {
  // Note: git branch --merged returns the current branch name as well
  // also won't branches that were squashed
  const result = await $`PAGER= git branch` // PAGER= to disable paging on mac
  let branchNames = result.stdout.split(os.EOL)
  branchNames = filterBranchNames(branchNames)
  return branchNames
}

export const getDefaultMainBranchName = async (): Promise<string> => {
  const result = await getLocalBranchNames()
  const list = result.filter(branchName => branchName.toLowerCase() === 'main' || branchName.toLowerCase() === 'master')
  if (list.length > 0)
    return list[0]
  throw new Error('Unable to find default main branch name')
}
