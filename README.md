# Chris's Dotfiles

Personal setup notes and documentation for my development environment.

## Quick Start

Bootstrap a fresh machine. Linux (x86_64) or macOS (Intel/Apple Silicon):

```bash
curl -fsSL https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.sh | bash
```

Windows (PowerShell 7, with Developer Mode on — see [Windows Setup Notes](./docs/windows-setup-notes.md)):

```powershell
irm https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.ps1 | iex
```

Both install Bun, the only prerequisite, then run `bootstrap.ts`: it installs git if missing, clones the repo to `~/code/p/dotfiles`, and runs `ttd setup`, which installs every tool, links the configs (including `~/.zshrc` / `$PROFILE`) and generates the shell init.

Everything else goes through `ttd` (towles tool dotfiles). Run it bare for an fzf picker over every command:

```bash
ttd                 # pick a command
ttd setup           # install, link, configure; ez-setup = ttd setup && exec zsh
ttd setup tmux fzf  # just these modules
ttd doctor          # config links that are missing or were replaced by a regular file
ttd help <command>
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
| `gc` / `gcm` | `ttd git-ai-commit` (AI-powered commit via Claude) |
| `gca` | `git add . && git-ai-commit` |
| `ga` | `git add .` |
| `gp` | `git push` |
| `gs` | `git status` |
| `gw` | `gh browse` |
| `c` / `cr` | `ttd claude opus`: `claude --permission-mode auto --model opus --effort high` (`--chrome` on Linux); `cr` resumes |
| `co` / `cor` | same as `c`, explicit Opus name; `cor` resumes, overriding model/effort (unlike `cr`) |
| `cs` / `csr` | same, Sonnet model at high effort; `csr` resumes, overriding model/effort |
| `cf` / `cfr` | same, Fable model at medium effort ("fast draft"); `cfr` resumes |
| `cfa` / `cfar` | same, Fable model at xhigh effort ("architect"); `cfar` resumes |
| `code` | `code-insiders` |
| `ls` | `eza -la` (dirs first, git status, icons; falls back to `ls -al`) |
| `lt` | `eza --tree` (tree view, `lt [depth]`) |
| `lsf` | fuzzy-filter files under cwd and open the pick in `$EDITOR` |
| `jf` | `just-fzf` — fuzzy-pick a justfile recipe and run it (preview via `just --show`) |
| `jn` | `just-new` — append a recipe to the justfile (`jn [-d doc] <name> [cmd...]`) |
| `ez` | `exec zsh` |
| `dif` | `delta` (syntax-highlighted diff) |

## Documentation

- [Linux Setup Notes](./docs/linux-setup-notes.md)
- [Mac Setup Notes](./docs/mac-setup-notes.md)
- [Windows Setup Notes](./docs/windows-setup-notes.md)
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
- [zoxide](https://github.com/ajeetdsouza/zoxide) -- `z` for PowerShell on Windows (zsh uses zsh-z)
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
