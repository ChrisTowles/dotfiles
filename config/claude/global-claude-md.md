## Workflow

- Use a hard cutover approach and never implement backward compatibility.
- Always verify changes work — run tests, typecheck, or build after implementation. Don't claim something is fixed without evidence.

## Personal Repos

Repos live under `~/code/` in three directories: `p/` (personal), `w/` (work), `f/` (forks of open source).

- `~/code/p/dotfiles` — Zsh shell config, tool setup, app configs (Linux + macOS)
- `~/code/p/toolbox` — Personal utilities and scripts
- `~/code/p/blog` — Personal blog
- `~/code/p/towles-tool` — Personal tools and claude code plugin, cli named `tt`

## Code style

- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

## Git
  
**Always rebase merge** — always use rebase merge (`gh pr merge --rebase`) when merging PRs.
**Preserve commit authorship** — when rebasing, keep the original author intact (don't use `--reset-author`). Use `--committer-date-is-author-date` to keep dates aligned. Prefer `gh pr merge --rebase` (GitHub-side rebase) over local rebase+push — GitHub sets the committer to its bot, not the merger, which preserves fair credit attribution. Never squash-merge other people's commits — it replaces the author entirely.
