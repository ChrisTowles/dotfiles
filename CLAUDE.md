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

- **05-fnm.sh** - Node.js version manager setup with shell init and completions
- **10-pnpm.sh** - Package manager, global tools (tsx, ni, @towles/tool)
- **15-bun.sh** - JavaScript runtime
- **16-uv.sh** - Python package manager
- **20-fzf.sh** - Fuzzy finder setup with `fd` integration, `fh()` for home search
- **25-git.sh** - `git-ai-commit()` for AI-powered commits, `gmain()`, common git aliases
- **30-lazygit.sh** - Terminal git UI, config symlink, `c` key mapped to `git-ai-commit`
- **35-gh.sh** - GitHub CLI aliases, `pr()` for push+PR creation, `gib()` for issue browsing, `gh-alias-setup()`
- **40-tmux.sh** - Session management (`ts`, `tsn`, `tss`, `ta`), TPM installation
- **45-nerd-fonts.sh** - Nerd Font install + VS Code font config
- **50-vscode.sh** - VS Code Insiders install, keybindings symlink
- **55-starship.sh** - Prompt init with git metrics display
- **60-claude-code.sh** - Claude Code install, statusline/notification hooks
- **65-aws-cli.sh** - AWS CLI completions (manual install warning)
- **70-i.sh** - Quick `cd` to project directories under `~/code/{p,w,f}`

### config/ Directory

- **claude/** - TypeScript scripts for Claude Code hooks (statusline, notifications, settings setup)
- **git/** - `ai-commit.ts` — interactive AI commit message generator with built-in fuzzy selector
- **lazygit/** - `config.yml` — custom keybindings (`c` → `git-ai-commit`)
- **tmux/tmux.conf** - Symlinked to `~/.config/tmux/tmux.conf` during setup
- **vscode/** - `setup-settings.ts`, plus `linux/` and `mac/` keybindings
- **karabiner/** - macOS keyboard remapping (home/end keys)

## Key Aliases

```
g     → lazygit
gc/gcm → git-ai-commit (AI-powered commit messages via Claude + interactive selector)
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
- `${0:a:h}` resolves the sourced file's directory — but ONLY at the top level of a file, not inside functions. Inside a function, `$0` becomes the shell name (e.g. `zsh`). If a function needs the file's directory, capture it in a variable at the top level first:
  ```bash
  _MY_DIR="${0:a:h}"        # top-level: correct
  my_func() {
    echo "$_MY_DIR"          # function: uses captured value
  }
  ```
- Complex logic (JSON merging, interactive UIs) should be extracted into TypeScript files under `config/` and called with `bun run`, rather than inlined in shell scripts
- Functions files are numbered by 5s (05, 10, 15...) to allow inserting new files without renaming
