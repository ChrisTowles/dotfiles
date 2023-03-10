import { getIssues, isGithubCliInstalled } from './gh-cli-wrapper'

describe('gh-cli-wrapper', () => {
  it('should return true if gh is installed', async () => {
    const result = await isGithubCliInstalled()
    expect(result).toBe(true)
  })

  it('get issues', async () => {
    const issues = await getIssues({ assignedToMe: false })
    expect(issues.length).toBeGreaterThan(0)
  })
})
