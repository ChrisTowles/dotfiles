# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for Linux (Pop!_OS, x86_64), macOS and Windows. All setup logic is TypeScript on Bun, driven by one CLI: **`ttd`** (towles tool dotfiles, `bin/ttd.ts`). Shell code is limited to small per-module snippets (functions that must change the shell's own state: `cd`, `print -z`, zle widgets).

## Setup & Installation

**Fresh machine** — the installers only install Bun, then run `bootstrap.ts` (git, clone to `~/code/p/dotfiles`, `bun install`, `ttd setup`):

```bash
curl -fsSL https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.sh | bash      # Linux / macOS
irm https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.ps1 | iex             # Windows (pwsh 7, Developer Mode on)
```

**Re-run / update** on a configured machine: `ttd setup` (alias `ez-setup` = `ttd setup && exec zsh`). `ttd setup <module…>` runs only those modules. `ttd setup --dry-run [--os=linux|darwin|win32]` prints what it would do without changing anything — use it to test; never run a real `ttd setup` from a Claude session (it runs sudo and installs).

## Architecture

### ttd

`bin/ttd.ts` — builtins `setup`, `gen`, `graph`, `doctor`, `help`, `claude`, plus every command a module declares (`ttd gmain`, `ttd cbk-now`, …). Bare `ttd` opens an fzf picker over all commands (preview: `ttd help {1}`); a picked command that takes args is pushed onto the prompt (zsh `print -z` via `~/.cache/dotfiles/push`; pwsh: into history). `~/.bun/bin/ttd` is a symlink to `bin/ttd.ts` (Windows: `ttd.cmd`), created by `ttd setup`.

`ttd claude <opus|sonnet|fable|architect|resume> [args]` (modules/claude/variants.ts) runs claude with preset flags and restores the terminal afterward; it takes a fast path that does not load the modules. `c`, `cr`, `cf`, `cfa`, … are aliases to it.

### Modules

One folder per tool: `modules/<id>/module.ts` (a `defineModule({...})` default export; the id must equal the folder name), plus optional `init.zsh` / `init.ps1` (or `init.<os>.zsh`) snippets and the tool's config files. A `ModuleDef` (lib/types.ts) declares:

- `install` per OS (`unix` = linux + darwin) — `apt` (third-party `repo`: key + line, or `ppa`), `brew` (`cask`, `tap`, `app`), `winget`, `cargo`, `gh-release` (`tag: "prefix*"` = newest matching), `deb` (URL, resolver or release asset), `script`, `flatpak`, `pnpm-global`. `os` defaults to the keys of `install`. Installed = `bin` (default: the id) on PATH, or every spec for this OS confirms it (dpkg, brew, /Applications, winget, flatpak); `installed()` overrides that for things like fonts or an SDK dir.
- `needs: [...]` — order comes from a topo sort (lib/graph.ts), not file names. Unknown needs and cycles are errors (`ttd graph --check`).
- `links` — `{ from, to }`, `from` relative to the module folder, `to` a logical path: `config:` (native config dir), `xdg:` (~/.config on macOS too), `data:`, `~/`, or per-OS. Windows uses real symlinks (junctions for dirs) and needs Developer Mode. `ttd doctor` lists links that are missing or that an app replaced with a regular file.
- `env`, `path`, `aliases` (string, or `{ zsh, pwsh }`), `commands` (TS functions run by `ttd <name>`; each also gets a shell alias unless `alias: false`), `capture` (static init output such as `fzf --zsh` / `starship init`, run once at gen time), `completions` (`argv` whose stdout is the completion script, or `help: cli` to parse its `--help` via config/generate-completions.ts), `setup(ctx)` hook.
- Use `ctx` (lib/ctx.ts) for side effects: `ctx.exec` / `ctx.sudo` / `ctx.write` / `ctx.link` all honor dry run; `ctx.read` always runs (reads only); `ctx.notice` queues a post-setup message.

Shared helpers are in `lib/helpers.ts` (`appInstalled`, `gitCloneOrPull`, `sudoCopyIfChanged`, `out`, `fzf`, `confirm`).

### Shell loading

- **zsh:** `~/.zshrc` → `modules/zsh/zshrc`. It sources `modules/zsh/base.zsh` (plugins from `~/.zsh/`, keybindings, zle widgets, completion styles, history, `compinit`), then `~/.cache/dotfiles/init.zsh`, then `~/.zshrc_local.sh` (untracked). If any `modules/**` or `lib/**` `.ts`/`.zsh` file is newer than the init, the zshrc runs `ttd gen zsh` first; otherwise a shell start runs no Bun.
- **pwsh:** `$PROFILE` → `modules/pwsh/profile.ps1` — same pattern with `init.ps1` and `~/.pwsh_local.ps1`.
- The generated init (lib/emit.ts) contains, per module in graph order and only if installed: env, PATH, captured init, the snippet, aliases, command aliases; then the `ttd` wrapper and its completion. Edit modules, never the generated file.

### config/

Shared scripts that are not one tool's: `help.ts` (the `ttd help` cheat sheet, hand-curated — update it when adding aliases), `generate-completions.ts` (zsh completions from `--help` for claude / tt), `terminal-input-test.ts`.

## Key Aliases

```
g     → lazygit
gc/gcm → ttd git-ai-commit (AI commit messages via Claude + interactive selector)
gca   → git add . && ttd git-ai-commit
ga    → git add .
gp    → git push
gs    → git status
c     → ttd claude opus (claude --permission-mode auto --model opus --effort high, --chrome on Linux)
        Linux, run from a repo's main checkout root: also --remote-control
ca    → ttd claude opus agents, scoped with --cwd to the repo's main checkout (covers its .claude/worktrees)
co/cor → same as c, explicit Opus name (cor resumes, overriding model/effort unlike cr)
cs/csr → ttd claude sonnet (csr resumes, overriding model/effort)
cf/cfa → ttd claude fable / architect (--model fable --effort medium/xhigh)
cr/cfr/cfar → resume variants
cloudflare → the Cloudflare CLI (its binary is `cf`, which the claude-fable alias shadows)
code  → code-insiders
ls    → eza -la (dirs first, git status, icons)
ez    → exec zsh
dif   → delta (syntax-highlighted diff)
jf    → just-fzf (fzf picker over justfile recipes)
jn    → ttd just-new (append a recipe to the justfile)
gw    → gh browse
zcd   → fuzzy-cd into a dir under cwd (same job as fzf's Alt+C, callable by name)
ii    → fuzzy-cd into a ~/code/{p,w,f} project
```

## Debugging Shell Load Time

```bash
ZSH_DEBUG_TIMING=1 exec zsh
```

Prints millisecond timestamps at each loading stage.

## Git Identity

This repo uses a **personal** GitHub identity (local git config):
- `user.name` = `Chris Towles`
- `user.email` = `Chris.Towles@gmail.com`
- `credential.helper` = `!gh auth git-credential` (uses the active `gh` account, which should be `ChrisTowles`)

The work profile (`212787373_aero`) is the global default — this repo overrides it locally.

**Pushing to this repo** — use `ttd push` instead of `git push`. On macOS it switches to the `ChrisTowles` gh account, pushes, and switches back. Elsewhere it is plain `git push`.

## Conventions

- **Bun is the only package manager and the only prerequisite.** `bun.lock` is the sole lockfile. Use `bun install`, never `pnpm install`/`npm install` here. (`modules/pnpm` installs pnpm as a *system* tool for other projects.) TypeScript runs with `bun run`, never `npx tsx`.
- Logic goes in TypeScript. Shell snippets (`init.zsh` / `init.ps1`) only for what must run in the shell itself: `cd`, `print -z`, zle widgets, `source`. No Python anywhere.
- Hard cutover, no backward compatibility shims.
- Package managers: `apt` (Linux), `brew` (macOS), `winget` (Windows). Linux is x86_64 only; macOS supports both arches via brew. Linux installs of GitHub-hosted CLIs use the `gh-release` backend.
- Rust ecosystem tools (bat, fd, eza, delta, starship, just, broot) install via `cargo` on Linux/macOS and `winget` on Windows.
- Windows scope: a tool not installed on the Mac is not installed on Windows either; Linux-only stays Linux-only. Mac-only modules are used on the work Mac — never drop them based on Linux shell history.
- Type-check with `bunx tsc --noEmit`; test with `bun test`. Lint with `bun run lint`: shellcheck for `install.sh` and `modules/*/*.sh`; `zsh -n` for the zsh files (shellcheck has no zsh mode — don't point it at them); `ttd gen --check` parses the generated init; `ttd graph --check` validates the module graph on all three OSes.
- CI (`.github/workflows/ci.yml`) runs on ubuntu, macos and windows, and only when code under bin/, lib/, modules/, config/ or the installers changes.
- `install.sh` is **bash** (it runs before zsh exists) — no zsh-isms there.
- macOS `/bin/bash` is 3.2 — the tmux module installs Homebrew bash for tmux plugins; tmux.conf prepends `/opt/homebrew/bin` to PATH.
- zsh snippet functions: Claude Code's shell snapshot drops underscore-prefixed functions, so a public function must not call a top-level `_helper` at runtime — nest it instead.
- `$EDITOR` carries flags (`code-insiders --wait`): call it as `${(z)EDITOR}` in zsh.
- Claude Code MCP servers are registered via `claude mcp add -s user` (in `~/.claude.json`) by the claude module, NOT in `settings.json`, whose `mcpServers` stays empty.
- Chrome DevTools MCP uses `--autoConnect`, which connects to an existing Chrome session. Requires Chrome 144+ with remote debugging enabled at `chrome://inspect/#remote-debugging`.
- lazygit's `c` key runs `ttd git-ai-commit` (modules/lazygit/config.yml).
- Ghostty: `macos-option-as-alt = left` is required for fzf's Alt+C on macOS (Option+C otherwise emits `ç`).
- broot config is read via `BROOT_CONFIG_DIR` → `modules/broot` (no link).
- restic needs `CLAUDE_BACKUP_REPO` set in `~/.zshrc_local.sh` — no default (see docs/linux-setup-notes.md#restic).
- `~/.granted/config` is linked from `~/code/p/toolbox` via that repo's sync manifest, not from here.
