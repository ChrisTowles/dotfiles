import { isGithubCliInstalled } from './gh-cli-wrapper'

describe('gh-cli-wrapper', () => {
  it('should return true if gh is installed', async () => {
    const result = await isGithubCliInstalled()
    expect(result).toBe(true)
  })
})
