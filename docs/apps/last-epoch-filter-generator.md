# Last Epoch Filter Generator

CLI tool to convert JSON configs to Last Epoch search syntax.

## Usage

```bash
t le-filter [file]
```

Default file: `docs/apps/last-epoch.md`

## JSON Schema

```typescript
interface FilterConfig {
  item: string                    // Item name
  tiers: {
    [tierName: string]: {
      conditions: Array<{
        stat: string              // Stat text (e.g., "increased health")
        range: [number, number]   // Min/max values
        suffix?: string           // Optional suffix (e.g., "%")
        operator?: "AND" | "OR"   // How to combine with next condition
      }>
      lp?: string                 // Legendary potential (e.g., "1+", "2-")
      fp?: string                 // Forging potential (e.g., "40+")
      sealed?: string             // Sealed affixes (e.g., "0", "1")
      prefixes?: string           // Prefix count (e.g., "1-")
      suffixes?: string           // Suffix count (e.g., "1-")
      exalted?: boolean           // Require exalted rarity
    }
  }
}
```

## Examples

### Simple Unique Filter

```json
{
  "item": "titan heart",
  "tiers": {
    "godlike": {
      "conditions": [
        {"stat": "increased health", "range": [36, 40], "suffix": "%", "operator": "AND"},
        {"stat": "increased melee damage", "range": [36, 40], "suffix": "%"}
      ],
      "lp": "1+"
    },
    "turtle": {
      "conditions": [],
      "lp": "2+"
    }
  }
}
```

**Output:**
```
## titan heart

### godlike
/titan heart/&/3[6-9]% increased health|40% increased health/&/3[6-9]% increased melee damage|40% increased melee damage/&LP1+

### turtle
/titan heart/&LP2+
```

### Exalted Craft Base

```json
{
  "item": "boots",
  "tiers": {
    "perfect": {
      "conditions": [],
      "fp": "40+",
      "sealed": "0",
      "exalted": true,
      "prefixes": "1-"
    }
  }
}
```

**Output:**
```
## boots

### perfect
/boots/&FP40+&sealed0&exalted&prefixes1-
```

### Complex Multi-Stat

```json
{
  "item": "unstable core",
  "tiers": {
    "godlike": {
      "conditions": [
        {"stat": "6th cast gains", "range": [340, 400], "operator": "AND"},
        {"stat": "increased elemental damage", "range": [140, 160], "suffix": "%"}
      ],
      "lp": "1+"
    }
  }
}
```

**Output:**
```
## unstable core

### godlike
/unstable core/&/3[4-9][0-9] 6th cast gains|400 6th cast gains/&/1[4-5][0-9]% increased elemental damage|160% increased elemental damage/&LP1+
```

## How It Works

1. **Range Pattern Generation:**
   - Converts `[25, 30]` → `2[5-9]|30`
   - Handles 2-3 digit numbers intelligently
   - Falls back to explicit list for small ranges

2. **Operator Logic:**
   - `operator: "AND"` → Separate regex patterns joined with `&`
   - Default (OR) → Patterns combined with `|` inside single regex

3. **Modifier Order:**
   - Item name → Conditions → FP → Sealed → Exalted → Prefixes/Suffixes → LP

## Integration

Place JSON blocks in markdown files:

\`\`\`json
{
  "item": "siphon of anguish",
  "tiers": {
    "godlike": {
      "conditions": [
        {"stat": "void penetration with doom", "range": [25, 30], "suffix": "%", "operator": "AND"},
        {"stat": "chance to apply doom", "range": [25, 30], "suffix": "%"}
      ],
      "lp": "1+"
    }
  }
}
\`\`\`

Run `t le-filter docs/apps/last-epoch.md` to generate all filters.
