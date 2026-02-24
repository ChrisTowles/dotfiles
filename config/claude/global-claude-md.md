## Workflow

- Use a hard cutover approach and never implement backward compatibility.
- Use Plan Mode for non-trivial tasks — explore first, then plan, then implement.
- Use the task system (TaskCreate/TaskUpdate) to track multi-step work. Create tasks before starting, then start, and mark them completed when done.
- Always verify changes work — run tests, typecheck, or build after implementation. Don't claim something is fixed without evidence.


## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Code style

- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')
