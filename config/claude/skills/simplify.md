---
name: simplify
description: Simplify and refine recently modified code for clarity and maintainability
disable-model-invocation: true
---

Run the code-simplifier:code-simplifier agent. $ARGUMENTS

Determine scope from arguments:
- No args: files changed in the last commit (`git diff --name-only HEAD~1`)
- A file or directory path: only that path
- "branch": all files changed on the current branch vs main (`git diff --name-only main...HEAD`)
- "staged": only staged files (`git diff --name-only --cached`)

Steps:
1. Identify the files to simplify based on the scope above
2. Review each file for opportunities to simplify
3. Apply refinements that preserve exact functionality:
   - Reduce unnecessary complexity and nesting
   - Eliminate redundant code and abstractions
   - Improve variable and function names for clarity
   - Consolidate related logic
   - Remove obvious comments
   - Prefer switch/if-else over nested ternaries
   - Choose clarity over brevity
4. Verify all functionality remains unchanged
5. Summarize what was simplified
