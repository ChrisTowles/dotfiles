# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managing Zsh shell configuration, tool setup, and app configs for Linux and macOS development environments.

## Setup & Installation

Bootstrap a fresh machine by setting the env var and reloading:

```bash
DOTFILES_SETUP=1 exec zsh
```

This triggers auto-installation of Zsh plugins (into `~/.zsh/`), generates shell completions, installs tools (fnm, pnpm, bun, starship, fzf, tmux+TPM), and creates config symlinks.

## Architecture

### Shell Loading Order (.zshrc)

1. Zsh plugins loaded from `~/.zsh/` (autosuggestions, completions, history-substring-search, z, fast-syntax-highlighting)
2. Keybindings and completion styles
3. History configuration
4. All files in `functions/*.sh` sourced alphabetically
5. Local overrides from `~/.zshrc_local.sh` (not tracked)
6. `compinit` runs last

### functions/ Directory

Each file in `functions/` is a self-contained module for one tool. Files follow a pattern: PATH setup, environment initialization (via `eval`), aliases, and helper functions. Key modules:

- **git.sh** - Lazygit, `git-ai-commit()` for AI-powered commits, `gmain()`, common git aliases
- **gh.sh** - GitHub CLI aliases, `pr()` for push+PR creation, `gib()` for issue browsing, `gh-alias-setup()`
- **tmux.sh** - Session management (`ts`, `tsn`, `tss`, `ta`), keybinding setup, TPM installation
- **starship.sh** - Prompt init with git metrics display
- **fnm.sh** - Node.js version manager setup with shell init and completions
- **fzf.sh** - Fuzzy finder setup with `fd` integration, `fh()` for home search
- **i.sh** - Quick `cd` to project directories under `~/code/`

### config/ Directory

- **tmux/tmux.conf** - Symlinked to `~/.config/tmux/tmux.conf` during setup
- **claude/** - TypeScript scripts for Claude Code hooks (notifications, statusline)
- **karabiner/** - macOS keyboard remapping (home/end keys)
- **vscode/** and **vscode-mac/** - Platform-specific VS Code keybindings

## Key Aliases

```
g     → lazygit
gc    → git-ai-commit (AI-powered commit messages via Claude API + fzf selection)
c     → claude --dangerously-skip-permissions
code  → code-insiders
ls    → ls -al
```

## Debugging Shell Load Time

```bash
ZSH_DEBUG_TIMING=1 exec zsh
```

Prints millisecond timestamps at each loading stage.

## Conventions

- Shell functions use POSIX-compatible syntax where possible
- PATH additions are idempotent (guarded by `case` checks against existing `$PATH`)
- Setup/install logic is gated behind `DOTFILES_SETUP=1` to avoid running on every shell start
- Platform detection uses `uname` checks for Linux vs macOS differences
- Only two package managers need support: `brew` (macOS) and `apt` (Linux)
- Only x86_64 architecture needs support — no ARM/aarch64 at this time
