import { $ } from 'zx'
import stripAnsi from 'strip-ansi'

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

export interface Issue {
  labels: {
    name: string
    color: string
  }[]
  number: number
  title: string
  state: string
}

export const getIssues = async ({ assignedToMe = false }: { assignedToMe: boolean }): Promise<Issue[]> => {
  let issues: Issue[] = []

  $.verbose = false
  const flags = [
    '--json', 'labels,number,title,state',
  ]

  if (assignedToMe) {
    flags.push('--assignee')
    flags.push('@me')
  }

  const result = await $`gh issue list ${flags}`
  // Setting NO_COLOR=1 didn't remove colors so had to use stripAnsi
  const striped = stripAnsi(result.stdout)
  issues = JSON.parse(striped)

  return issues
}
