import { $ } from 'zx'

export const isGithubCliInstalled = async (): Promise<boolean> => {
  try {
    $.verbose = false
    const result = await $`gh --version`
    return result.stdout.indexOf('https://github.com/cli/cli') > 0
  }
  catch (e) {
    return false
  }
}
