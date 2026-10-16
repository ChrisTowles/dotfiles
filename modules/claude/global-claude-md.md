## Workflow

- Use a hard cutover approach and never implement backward compatibility.
- I run a clipboard manager, so the clipboard keeps a history rather than a single slot. Copy several values in a row without pausing to ask — I can pick any of them out of the history. Just say what was copied and in what order.

## Personal Repos

Repos live under `~/code/` in three directories: `p/` (personal), `w/` (work), `f/` (forks of open source).

- `~/code/p/dotfiles` — Zsh shell config, tool setup, app configs (Linux + macOS)
- `~/code/p/toolbox` — Personal utilities and scripts
- `~/code/p/blog` — Personal blog
- `~/code/p/towles-tool` — Personal tools and claude code plugin, cli named `tt`

## Artifacts

- Every published page themes its own background. Set `body { background: <token>; color: <token> }` from the page's tokens, and redefine those tokens, with `color-scheme: dark`, under `@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { … } }` and again under `:root[data-theme="dark"]`. A page that themes only `html`, or only its components, shows a white body behind dark cards in dark mode.
- For an `/html-plan` page, add this after the runtime CSS: `body { background: var(--paper); color: var(--ink); }`, and `color-scheme: dark` in both dark blocks.
