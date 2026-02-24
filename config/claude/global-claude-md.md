# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
- Use a hard cutover approach and never implement backward compatibility.

# Rules
- Additional rules are symlinked to ~/.claude/rules/ from config/claude/rules/
