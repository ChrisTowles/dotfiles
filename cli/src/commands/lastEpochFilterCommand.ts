import { type Command } from 'commander'
import { readFileSync } from 'fs'
import c from 'picocolors'

interface StatCondition {
  stat: string
  range: [number, number]
  suffix?: string
  operator?: 'AND' | 'OR'
}

interface TierConfig {
  conditions: StatCondition[]
  lp?: string
  fp?: string
  sealed?: string
  prefixes?: string
  suffixes?: string
  exalted?: boolean
}

interface FilterConfig {
  item: string
  tiers: Record<string, TierConfig>
}

const generateRangePattern = (range: [number, number], suffix: string = ''): string => {
  const [min, max] = range

  // Handle same value
  if (min === max) {
    return `${min}${suffix}`
  }

  const minStr = min.toString()
  const maxStr = max.toString()

  // Same number of digits
  if (minStr.length === maxStr.length) {
    const len = minStr.length

    if (len === 2) {
      const minTens = Math.floor(min / 10)
      const maxTens = Math.floor(max / 10)
      const minOnes = min % 10
      const maxOnes = max % 10

      if (minTens === maxTens) {
        // Same tens digit: e.g., 25-29 -> 2[5-9]
        return `${minTens}[${minOnes}-${maxOnes}]${suffix}`
      } else {
        // Different tens: e.g., 25-30 -> 2[5-9]|30
        const parts: string[] = []

        // First partial range
        if (minOnes > 0) {
          parts.push(`${minTens}[${minOnes}-9]${suffix}`)
        }

        // Middle full ranges
        for (let t = minTens + 1; t < maxTens; t++) {
          parts.push(`${t}[0-9]${suffix}`)
        }

        // Last partial range
        if (maxOnes === 9) {
          parts.push(`${maxTens}[0-9]${suffix}`)
        } else {
          parts.push(`${maxTens}[0-${maxOnes}]${suffix}`)
        }

        return parts.join('|')
      }
    } else if (len === 3) {
      // Three digits: e.g., 340-400
      const minHundreds = Math.floor(min / 100)
      const maxHundreds = Math.floor(max / 100)

      if (minHundreds === maxHundreds) {
        const minTens = Math.floor((min % 100) / 10)
        const maxTens = Math.floor((max % 100) / 10)

        if (minTens === maxTens) {
          const minOnes = min % 10
          const maxOnes = max % 10
          return `${minHundreds}${minTens}[${minOnes}-${maxOnes}]${suffix}`
        } else {
          return `${minHundreds}[${minTens}-${maxTens}][0-9]${suffix}`
        }
      } else {
        return `[${minHundreds}-${maxHundreds}][0-9][0-9]${suffix}`
      }
    }
  }

  // Fallback: explicit list for small ranges
  if (max - min <= 10) {
    const values: string[] = []
    for (let i = min; i <= max; i++) {
      values.push(`${i}${suffix}`)
    }
    return values.join('|')
  }

  // Default fallback
  return `[${min}-${max}]${suffix}`
}

const convertFilterToSearch = (config: FilterConfig): Record<string, string> => {
  const results: Record<string, string> = {}

  for (const [tierName, tierConfig] of Object.entries(config.tiers)) {
    const parts: string[] = []

    // Add item name
    parts.push(`/${config.item}/`)

    // Process conditions
    const andGroups: string[][] = []
    let currentGroup: string[] = []

    for (const condition of tierConfig.conditions) {
      const pattern = generateRangePattern(condition.range, condition.suffix || '')
      const conditionStr = `/${pattern} ${condition.stat}/`

      if (condition.operator === 'AND') {
        if (currentGroup.length > 0) {
          andGroups.push([...currentGroup])
          currentGroup = []
        }
        currentGroup.push(conditionStr)
      } else {
        currentGroup.push(conditionStr)
      }
    }

    if (currentGroup.length > 0) {
      andGroups.push(currentGroup)
    }

    // Build condition string
    for (const group of andGroups) {
      if (group.length === 1) {
        parts.push(group[0])
      } else {
        parts.push(`/${group.map(g => g.slice(1, -1)).join('|')}/`)
      }
    }

    // Add modifiers
    if (tierConfig.fp) parts.push(`FP${tierConfig.fp}`)
    if (tierConfig.sealed !== undefined) parts.push(`sealed${tierConfig.sealed}`)
    if (tierConfig.exalted) parts.push('exalted')
    if (tierConfig.prefixes) parts.push(`prefixes${tierConfig.prefixes}`)
    if (tierConfig.suffixes) parts.push(`suffixes${tierConfig.suffixes}`)
    if (tierConfig.lp) parts.push(`LP${tierConfig.lp}`)

    results[tierName] = parts.join('&')
  }

  return results
}

const parseJsonBlocks = (content: string): FilterConfig[] => {
  const jsonBlockRegex = /```json\n([\s\S]*?)\n```/g
  const configs: FilterConfig[] = []

  let match
  while ((match = jsonBlockRegex.exec(content)) !== null) {
    try {
      const config = JSON.parse(match[1]) as FilterConfig
      configs.push(config)
    } catch (error) {
      console.error(c.red(`Failed to parse JSON block: ${error}`))
    }
  }

  return configs
}

export const SetupLastEpochFilterCommand = (program: Command): void => {
  program.command('le-filter')
    .description('Convert JSON filter configs to Last Epoch search syntax')
    .argument('[file]', 'Markdown file with JSON blocks', 'docs/apps/last-epoch.md')
    .action(async (file: string) => {
      try {
        const content = readFileSync(file, 'utf-8')
        const configs = parseJsonBlocks(content)

        if (configs.length === 0) {
          console.log(c.yellow('No JSON filter blocks found in file'))
          return
        }

        console.log(c.green(`Found ${configs.length} filter config(s)\n`))

        for (const config of configs) {
          console.log(c.blue(`## ${config.item}`))
          const searches = convertFilterToSearch(config)

          for (const [tier, search] of Object.entries(searches)) {
            console.log(c.yellow(`\n### ${tier}`))
            console.log('```')
            console.log(search)
            console.log('```')
          }
          console.log('')
        }
      } catch (error) {
        console.error(c.red(`Error: ${error}`))
        process.exit(1)
      }
    })
}
