import { createBranchNameFromIssue } from './branchCommand'

describe('gh-cli-wrapper', () => {
  it('get issues', async () => {
    const branchName = await createBranchNameFromIssue({
      number: 4,
      title: 'Long Issue Title - with a lot of words     and stuff ',
      state: 'open',
      labels: [],
    })
    expect(branchName).toBe('feature/4-long-issue-title-with-a-lot-of-words-and-stuff')
  })
})
