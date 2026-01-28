# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Software Installation

- **Never use Flatpak** - always prefer native installation methods
- Priority: APT/deb packages → official tarballs/binaries → PPAs → Snap (last resort)

## Repository Structure

This is a personal dotfiles repository following the [mattmc3/zdotdir](https://github.com/mattmc3/zdotdir) pattern:

```
~/code/p/dotfiles/              # ZDOTDIR - repository root
├── .zshenv                     # XDG setup, environment variables
├── .zshrc                      # Minimal orchestrator
├── .zstyles                    # Centralized zstyle configuration
├── .zsh_plugins.txt            # Antidote plugin manifest
├── conf.d/                     # Modular configuration (loaded alphabetically)
│   ├── 00-init.zsh            # Core init, colors, debug timing
│   ├── 10-aliases.zsh         # System aliases
│   ├── 20-git.zsh             # Git aliases
│   ├── 30-fzf.zsh             # FZF configuration
│   ├── 40-node.zsh            # Node.js/NVM/pnpm
│   ├── 50-*.zsh               # Tool-specific modules
│   └── 80-gcloud.zsh          # Google Cloud SDK
├── functions/                  # Autoloaded functions
├── lib/                        # Core libraries
│   └── antidote.zsh           # Plugin manager bootstrap
├── install/                    # Installation scripts
├── completions/                # Custom completions
├── cli/                        # TypeScript CLI tool (@towles/tool)
└── docs/                       # Setup guides
```

## Development Commands

```bash
# Setup (creates ~/.zshenv bootstrap pointing to ZDOTDIR)
zsh-setup

# Install dependencies
zsh-install

# Check missing dependencies
zsh-check-deps

# Profile startup time
zprofrc

# Reload with timing debug
zsh-load
```

## Architecture

### ZDOTDIR Pattern
- `~/.zshenv` is a minimal bootstrap that sets `ZDOTDIR` to this repo
- All configuration lives in the repo, not scattered in `$HOME`
- XDG Base Directory compliant (`~/.config`, `~/.cache`, `~/.local/share`)

### conf.d/ Modules
- Loaded alphabetically by `.zshrc`
- Prefix with `~` to disable (e.g., `~50-docker.zsh`)
- Each module checks if its tool exists before loading (`command -v` or `return 0`)

### functions/ Directory
- Functions are sourced at startup (files use .sh extension)
- Each file = one function (e.g., `gmain.sh` defines `gmain`)
- Key functions: `gmain`, `gcmc`, `pr`, `git-ignored`, `serve`, `i`

### Plugin Manager
Uses [Antidote](https://github.com/mattmc3/antidote) with static bundling for fast loading.

**Plugins:**
- `zsh-users/zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-users/zsh-completions` - Additional completions
- `kutsan/zsh-system-clipboard` - System clipboard integration
- `agkozak/zsh-z` - Jump to frequent directories

### Modern CLI Tools
Conditional aliases for: ripgrep (rg), eza, bat, jq, jid, fd
