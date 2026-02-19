# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managing Zsh shell configuration, tool setup, and app configs for Linux and macOS development environments.

## Setup & Installation

**Fresh machine** — install script handles git, zsh, repo cloning, `.zshrc` symlink, and default shell:

```bash
curl -fsSL https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.sh | bash
```

**Re-run / update** — on an already-configured machine, reinstall tools and update plugins:

```bash
DOTFILES_SETUP=1 exec zsh
# or use the alias: zsh-dotfiles-setup
```

Both paths trigger auto-installation of Zsh plugins (into `~/.zsh/`), generate shell completions, install tools (fnm, pnpm, bun, starship, fzf, tmux+TPM), and create config symlinks.

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
- **17-rust.sh** - Rust toolchain via rustup, generates zsh completions
- **20-fzf.sh** - Fuzzy finder setup with `fd` integration, `fh()` for home search
- **21-bat.sh** - Cat clone with syntax highlighting, installed via cargo
- **22-zoxide.sh** - Smarter cd replacement, installed via cargo
- **25-git.sh** - `git-ai-commit()` for AI-powered commits, `gmain()`, common git aliases
- **26-git-delta.sh** - Syntax-highlighted git diffs, installed via cargo
- **30-lazygit.sh** - Terminal git UI, config symlink, `c` key mapped to `git-ai-commit`
- **35-gh.sh** - GitHub CLI aliases, `pr()` push+PR, `gib()` issue browsing, `gh-git-config()` git user from GitHub API
- **40-tmux.sh** - Session management (`ts`, `tsn`, `tss`, `ta`), TPM installation
- **45-nerd-fonts.sh** - Nerd Font install + VS Code font config
- **50-vscode.sh** - VS Code Insiders install, keybindings symlink
- **55-starship.sh** - Prompt init with git metrics display
- **60-claude-code.sh** - Claude Code install, statusline/notification hooks
- **65-aws-cli.sh** - AWS CLI completions (manual install warning)
- **70-i.sh** - Quick `cd` to project directories under `~/code/{p,w,f}`
- **75-docker.sh** - Docker Engine install with completions
- **76-chrome.sh** - Google Chrome install via apt repo / brew cask
- **77-slack.sh** - Slack Desktop install
- **78-cliphist.sh** - Wayland clipboard manager with wofi picker, COSMIC hotkey setup
- **99-help.sh** - `zsh-dotfiles-help` command displaying all aliases/functions

### config/ Directory

- **help.ts** - Colored help output for all shell aliases and functions
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
gca   → git add . && git-ai-commit
ga    → git add .
gp    → git push
gs    → git status
c     → claude --dangerously-skip-permissions
cr    → claude --dangerously-skip-permissions --resume
code  → code-insiders
ls    → ls -al
ez    → exec zsh
dif   → delta (syntax-highlighted diff)
gw    → gh browse
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
- macOS supports both x86_64 and arm64 (Apple Silicon) — all macOS installs use `brew` which handles architecture automatically
- Linux only needs x86_64 support — no ARM/aarch64 on Linux at this time
- `${0:a:h}` resolves the sourced file's directory — but ONLY at the top level of a file, not inside functions. Inside a function, `$0` becomes the shell name (e.g. `zsh`). If a function needs the file's directory, capture it in a variable at the top level first:
  ```bash
  _MY_DIR="${0:a:h}"        # top-level: correct
  my_func() {
    echo "$_MY_DIR"          # function: uses captured value
  }
  ```
- Complex logic (JSON merging, interactive UIs) should be extracted into TypeScript files under `config/` and called with `bun run`, rather than inlined in shell scripts
- Functions files are numbered by 5s (05, 10, 15...) to allow inserting new files without renaming
- TypeScript files use `bun run` (not `npx tsx`) — Bun is the primary TS runtime
- One `package.json` at repo root — all `config/**/*.ts` files share dependencies
- Type-check with `bunx tsc --noEmit` — `tsconfig.json` covers `config/**/*.ts` with `@types/bun`
- lazygit custom commands need `zsh -ic '...'` to access shell functions (lazygit uses a plain shell by default)
- `install.sh` is **bash** (not zsh) since it runs before zsh is installed — avoid zsh-isms in that file
- Linux installs for GitHub-hosted CLIs use `gh release download` (not curl+grep):
  ```bash
  gh release download --repo owner/repo --pattern "tool_*_Linux_x86_64.tar.gz" -D /tmp --clobber
  sudo install /tmp/tool /usr/local/bin/tool
  ```
- Rust ecosystem tools (bat, fd, zoxide, delta, starship) install via `cargo install`
- Private/internal shell functions use underscore prefix (e.g. `_nerd_fonts_install`)
