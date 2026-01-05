import { describe, it, expect } from 'vitest'
import { getDefaultMainBranchName, getLocalBranchNames, getMergedBranches, isGitDirectory } from './git-wrapper'

describe('git-wrapper', () => {
  it('isGitDirectory', async () => {
    const result = await isGitDirectory()
    expect(result).toBe(true)
  })

  it('getMergedBranches', async () => {
    const result = await getMergedBranches()

    if (result.length > 0) // may not have branches to cleanup so just check for no errors
      expect(result[0].trim()).toBe(result[0])
  })

  it('getLocalBranchNames', async () => {
    const result = await getLocalBranchNames()
    expect(result.includes('main')).toBeDefined()
  })

  it('getDefaultMainBranchName', async () => {
    const result = await getDefaultMainBranchName()
    expect(result).toBe('main')
  })
})
