import { type Command } from 'commander'
import { readFileSync, readdirSync, statSync, writeFileSync } from 'fs'
import { join } from 'path'
import c from 'picocolors'
import { z } from 'zod'

// Zod schemas
const StatConditionSchema = z.object({
  stat: z.string().describe('Stat text with {value} placeholder'),
  range: z.tuple([z.number(), z.number()]),
  operator: z.enum(['AND', 'OR']).optional(),
})

const TierConfigSchema = z.object({
  lp: z.string().optional(),
  fp: z.string().optional(),
  sealed: z.string().optional(),
  prefixes: z.string().optional(),
  suffixes: z.string().optional(),
  exalted: z.boolean().optional(),
  tierFilter: z.string().optional(),
})

const FilterConfigSchema = z.object({
  item: z.string(),
  conditions: z.array(StatConditionSchema),
  tiers: z.record(z.string(), TierConfigSchema),
})

// TypeScript types from Zod schemas
type StatCondition = z.infer<typeof StatConditionSchema>
type TierConfig = z.infer<typeof TierConfigSchema>
type FilterConfig = z.infer<typeof FilterConfigSchema>

const generateRangePattern = (range: [number, number], suffix: string = ''): string => {
  const [min, max] = range

  // Handle same value
  if (min === max) {
    return `${min}${suffix}`
  }

  const minStr = min.toString()
  const maxStr = max.toString()

  // Handle cross-digit-length ranges (e.g., 95-100, 99-101)
  if (minStr.length !== maxStr.length) {
    // Split at the digit boundary
    const parts: string[] = []
    const boundary = Math.pow(10, minStr.length)

    // First part: min to boundary-1 (e.g., 95-99)
    if (min < boundary) {
      parts.push(generateRangePattern([min, boundary - 1], suffix))
    }

    // Second part: boundary to max (e.g., 100-100)
    if (max >= boundary) {
      parts.push(generateRangePattern([boundary, max], suffix))
    }

    return parts.join('|')
  }

  // Same number of digits
  if (minStr.length === maxStr.length) {
    const len = minStr.length

    if (len === 1) {
      // Single digit: e.g., 3-7 -> [3-7]
      return `[${min}-${max}]${suffix}`
    } else if (len === 2) {
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
      // Three digits: e.g., 325-350, 140-160
      const minHundreds = Math.floor(min / 100)
      const maxHundreds = Math.floor(max / 100)

      if (minHundreds === maxHundreds) {
        // Same hundreds digit
        const minRemainder = min % 100
        const maxRemainder = max % 100
        const minTens = Math.floor(minRemainder / 10)
        const maxTens = Math.floor(maxRemainder / 10)

        if (minTens === maxTens) {
          // Same tens: e.g., 325-329 -> 32[5-9]
          const minOnes = minRemainder % 10
          const maxOnes = maxRemainder % 10
          return `${minHundreds}${minTens}[${minOnes}-${maxOnes}]${suffix}`
        } else {
          // Different tens: e.g., 325-350 -> 32[5-9]|3[3-5][0-9]
          const parts: string[] = []
          const minOnes = minRemainder % 10

          // First partial range (if not starting at 0)
          if (minOnes > 0) {
            parts.push(`${minHundreds}${minTens}[${minOnes}-9]${suffix}`)
          }

          // Middle full tens ranges
          const middleStart = minOnes > 0 ? minTens + 1 : minTens
          const maxOnes = maxRemainder % 10

          // When max ends in 0, it completes a full tens range
          // e.g., 325-350 = 32[5-9] + 33[0-9] + 34[0-9] + 35[0-9]
          //                        which compacts to 3[3-5][0-9]
          const middleEnd = maxOnes === 0 ? maxTens : maxTens - 1

          // Check if we can compact multiple full tens ranges
          if (middleStart <= middleEnd) {
            if (middleEnd - middleStart >= 1) {
              // Multiple tens ranges: use compact form
              parts.push(`${minHundreds}[${middleStart}-${middleEnd}][0-9]${suffix}`)
            } else {
              // Single tens range: use explicit form
              parts.push(`${minHundreds}${middleStart}[0-9]${suffix}`)
            }
          }

          // Add last partial range if max doesn't end in 0
          if (maxOnes > 0) {
            parts.push(`${minHundreds}${maxTens}[0-${maxOnes}]${suffix}`)
          }

          return parts.join('|')
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
    for (const condition of config.conditions) {
      const pattern = generateRangePattern(condition.range, '')

      // Replace {value} placeholder in stat text
      // If pattern contains OR (|), split and replace {value} for each part
      const patternParts = pattern.split('|')
      const conditionStr = patternParts.length > 1
        ? `/${patternParts.map(p => condition.stat.replace('{value}', p)).join('|')}/`
        : `/${condition.stat.replace('{value}', pattern)}/`

      parts.push(conditionStr)
    }

    // Add modifiers
    if (tierConfig.fp) parts.push(`FP${tierConfig.fp}`)
    if (tierConfig.sealed !== undefined) parts.push(`sealed${tierConfig.sealed}`)
    if (tierConfig.exalted) parts.push('exalted')
    if (tierConfig.tierFilter) parts.push(tierConfig.tierFilter)
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
      const json = JSON.parse(match[1])

      // Validate with Zod
      const result = FilterConfigSchema.safeParse(json)

      if (!result.success) {
        console.error(c.red('Validation failed for JSON block:'))
        console.error(c.yellow(JSON.stringify(result.error.format(), null, 2)))
        continue
      }

      configs.push(result.data)
    } catch (error) {
      console.error(c.red(`Failed to parse JSON block: ${error}`))
    }
  }

  return configs
}

const generateMarkdownOutput = (configs: FilterConfig[]): string => {
  let output = '# Last Epoch Filters\n\n'
  output += '_Auto-generated from JSON configs_\n\n'

  for (const config of configs) {
    output += `## ${config.item}\n\n`
    const searches = convertFilterToSearch(config)

    for (const [tier, search] of Object.entries(searches)) {
      output += `### ${tier}\n`
      output += '```\n'
      output += `${search}\n`
      output += '```\n\n'
    }
  }

  return output
}

const loadJsonFiles = (dir: string): FilterConfig[] => {
  const configs: FilterConfig[] = []

  const scanDirectory = (directory: string) => {
    const items = readdirSync(directory)

    for (const item of items) {
      const fullPath = join(directory, item)
      const stat = statSync(fullPath)

      if (stat.isDirectory()) {
        scanDirectory(fullPath)
      } else if (item.endsWith('.json')) {
        try {
          const content = readFileSync(fullPath, 'utf-8')
          const json = JSON.parse(content)

          // Validate with Zod
          const result = FilterConfigSchema.safeParse(json)

          if (!result.success) {
            console.error(c.red(`Validation failed for ${fullPath}:`))
            console.error(c.yellow(JSON.stringify(result.error.format(), null, 2)))
            continue
          }

          configs.push(result.data)
        } catch (error) {
          console.error(c.red(`Failed to parse ${fullPath}: ${error}`))
        }
      }
    }
  }

  scanDirectory(dir)
  return configs
}

export const SetupLastEpochFilterCommand = (program: Command): void => {
  program.command('le-filter')
    .description('Convert JSON filter configs to Last Epoch search syntax')
    .option('-d, --dir <directory>', 'Directory with JSON configs', 'docs/apps/last-epoch')
    .option('-o, --output <file>', 'Output markdown file')
    .option('-f, --file <file>', 'Single markdown file with JSON blocks')
    .action(async (options) => {
      try {
        let configs: FilterConfig[] = []

        if (options.file) {
          // Legacy: Parse JSON blocks from markdown
          const content = readFileSync(options.file, 'utf-8')
          configs = parseJsonBlocks(content)
        } else {
          // New: Load JSON files from directory
          configs = loadJsonFiles(options.dir)
        }

        if (configs.length === 0) {
          console.log(c.yellow('No filter configs found'))
          return
        }

        const markdown = generateMarkdownOutput(configs)

        if (options.output) {
          writeFileSync(options.output, markdown)
          console.log(c.green(`✓ Generated filters for ${configs.length} item(s)`))
          console.log(c.blue(`✓ Written to ${options.output}`))
        } else {
          console.log(markdown)
        }
      } catch (error) {
        console.error(c.red(`Error: ${error}`))
        process.exit(1)
      }
    })
}
