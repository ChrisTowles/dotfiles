# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a personal dotfiles repository containing:
- **CLI tool** (`/cli/`) - A TypeScript CLI application called "towles-tool" with commands for branch management, AWS console login, and daily utilities
- **Dotfiles** (root) - Shell configuration files (`.zshrc`) and setup scripts
- **Documentation** (`/docs/`) - Setup guides for various applications and tools

## Development Commands

### Dotfiles Setup Commands

```bash
# Complete setup process (recommended)
zsh-setup

# Install dependencies
zsh-install

# Check which dependencies are missing
zsh-check-deps
```

### Dotfiles Architecture
- **Modular Design**: Configuration split into focused modules in `additional_scripts/`
- **Smart Loading**: Only loads modules for installed tools using `command -v` checks
- **Auto-Installation**: Built-in dependency installer with interactive menu
- **Cross-Platform**: Works on Linux and macOS with OS-specific handling
- **Debug Support**: Timing debug with `ZSH_DEBUG_TIMING` environment variable

### Key Zsh Files
- `.zsh_plugins.txt` - Antidote plugin manifest (plugins loaded by Antidote)
- `zsh-00-init.zsh` - Initialization and utility functions
- `zsh-02-basic-aliases.zsh` - System aliases and modern CLI tool replacements
- `zsh-git.zsh` - Git aliases and helper functions
- `zsh-node.zsh` - Node.js, NVM, and pnpm configuration
- `zsh-claude.zsh` - Claude CLI integration
- `zsh-fzf.zsh` - FZF fuzzy finder configuration

### Plugin Manager
Uses [Antidote](https://github.com/mattmc3/antidote) for plugin management. Plugins are defined in `.zsh_plugins.txt` and bundled into a static `.zsh_plugins.zsh` file for fast loading.

### Modern CLI Tool Support
- Conditional aliases for ripgrep (rg), eza, jq, jid, and bat
- Automatic fallback to traditional tools if modern ones aren't installed
- Platform-specific configurations (Linux vs macOS)


