# Chris's Dotfiles

Personal setup notes and documentation for my development environment.

## Quick Start

Bootstrap a fresh machine (Linux x86_64 or macOS Intel/Apple Silicon):

```bash
curl -fsSL https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.sh | bash
```

This installs git and zsh if missing, clones the repo to `~/code/p/dotfiles`, symlinks `~/.zshrc`, sets zsh as the default shell, and runs the full dotfiles setup.

To re-run setup on an existing machine (install new tools, update plugins):

```bash
zsh-dotfiles-setup
# or: DOTFILES_SETUP=1 exec zsh
```

## Post-Install

If authenticated with `gh auth login`, git user config is set automatically from your GitHub profile during setup. Otherwise, configure manually:

```bash
gh-git-config                # auto-configure from GitHub
# or manually:
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Key Aliases

| Alias | Command |
|-------|---------|
| `g` | `lazygit` |
| `gc` / `gcm` | `git-ai-commit` (AI-powered commit via Claude) |
| `gca` | `git add . && git-ai-commit` |
| `ga` | `git add .` |
| `gp` | `git push` |
| `gs` | `git status` |
| `gw` | `gh browse` |
| `c` | `claude --dangerously-skip-permissions` |
| `cr` | `claude --dangerously-skip-permissions --resume` |
| `code` | `code-insiders` |
| `ls` | `ls -al` |
| `ez` | `exec zsh` |
| `dif` | `delta` (syntax-highlighted diff) |

## Documentation

- [Linux Setup Notes](./docs/linux-setup-notes.md)
- [Mac Setup Notes](./docs/mac-setup-notes.md)
- App-specific guides in [`docs/apps/`](./docs/apps/)

## Nerd Font

FiraCode Nerd Font is installed automatically during setup, or manually with `nerd-fonts-setup`. Supports macOS (Homebrew cask) and Linux (`~/.local/share/fonts`).

VSCode terminal font (`settings.json`):

```json
"terminal.integrated.fontFamily": "FiraCode Nerd Font"
```

## Zsh Plugins

- [zsh-completions](https://github.com/zsh-users/zsh-completions) -- tab-complete command arguments
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -- history-based inline suggestions
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) -- search history by substring
- [zsh-z](https://github.com/agkozak/zsh-z) -- directory jumping
- [zoxide](https://github.com/ajeetdsouza/zoxide) -- smarter cd replacement (installed via cargo)
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)

## Debugging Shell Load Time

```bash
ZSH_DEBUG_TIMING=1 exec zsh
```

Prints millisecond timestamps at each loading stage.
