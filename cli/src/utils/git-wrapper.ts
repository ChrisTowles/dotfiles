import { $ } from 'zx'

export const isGitDirectory = async (): Promise<boolean> => {
  try {
    $.verbose = false
    const result = await $`git status`
    return result.stdout.indexOf('On branch') > 0
  }
  catch (e) {
    return false
  }
}

export const createBranch = async ({ branchName }: { branchName: string }): Promise<string> => {
  const result = await $`git checkout -b "${branchName}"`
  const test = result.stdout
  return test
}
