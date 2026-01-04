# Chris's Dotfiles

## Description

Opinionated setup I use on my machine for things like terminal and dotfiles like `.zshrc`.

![](/docs/images/example-for-my-shell.png)


## Prerequisites

- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/)
- [Zsh](https://zsh.sourceforge.io/) as your default shell

## Quick Setup

### Automated Setup (Recommended)

```bash
# Clone dotfiles repo
cd ~
mkdir -p ~/code/p
cd ~/code/p
git clone https://github.com/ChrisTowles/dotfiles.git
cd dotfiles

# Run the setup script (backs up existing files and installs dependencies)
./setup.sh
```

### Available Commands After Setup

Once set up, you'll have these convenient commands:

- `zsh-setup` - Re-run the complete setup process (recommended)
- `zsh-install` - Run the interactive dependency installer only
- `zsh-check-deps` - Check which dependencies are missing


## Local Only Scripts

```bash
# Create a per-machine only file. I also use this to load additional scripts from a private repo.
touch $HOME/.zshrc_local

```

## Git Configuration

After setup, configure Git with your details:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Set VS Code as the default editor
git config --global core.editor "code --wait"

# Push the current branch and set the remote as upstream automatically every time you push
git config --global push.default current
```


## Terminal Shell - ZSH Configuration

Architecture follows the [mattmc3/zdotdir](https://github.com/mattmc3/zdotdir) pattern:

```
~/code/p/dotfiles/              # ZDOTDIR
├── .zshenv                     # XDG setup, environment vars
├── .zshrc                      # Minimal orchestrator
├── conf.d/                     # Modular config (loaded alphabetically)
│   ├── 00-init.zsh            # Core initialization
│   ├── 05-keybindings.zsh     # Keyboard shortcuts
│   ├── 10-aliases.zsh         # System aliases
│   ├── 20-git.zsh             # Git aliases
│   ├── 30-fzf.zsh             # FZF fuzzy finder
│   ├── 40-node.zsh            # Node.js/NVM/pnpm
│   ├── 50-*.zsh               # Tool-specific (claude, docker, github-cli, zellij, etc)
│   └── 80-gcloud.zsh          # Google Cloud SDK
├── functions/                  # Sourced functions (.sh files)
├── bin/                        # Executable scripts (zp)
├── config/                     # App configs (claude, zellij)
├── lib/                        # Core libraries (antidote)
└── install/                    # Installation scripts
```

**Key Features**:
- **ZDOTDIR Pattern**: Only `~/.zshenv` needed in home, everything else in repo
- **XDG Compliant**: Uses `~/.config`, `~/.cache`, `~/.local/share`
- **Smart Loading**: Modules check if tools exist before loading
- **Sourced Functions**: Functions in `functions/*.sh` sourced at startup
- **Fast Startup**: Static plugin bundling via Antidote

**Plugins** (via Antidote):
- [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt) - Theme
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like suggestions
- [zsh-completions](https://github.com/zsh-users/zsh-completions) - Additional completions
- [zsh-z](https://github.com/agkozak/zsh-z) - Jump to frequent directories
- [zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard) - System copy/paste

### Common Tools
- [nvm](https://github.com/nvm-sh/nvm) - Use multiple versions of Node.js
- [pnpm](https://pnpm.io/) - Fast Node.js package manager with monorepo support
- [antfu/ni](https://github.com/antfu/ni) - Use the right package manager
- [zellij](https://zellij.dev/) - Terminal multiplexer (see [docs/apps/zellij.md](docs/apps/zellij.md))
  - Custom `claude-dev.kdl` layout for AI-assisted development
  - `zp` command: Run Claude prompts in stacked panes with auto-focus return
- [Claude Code](https://claude.ai/code) - AI coding assistant (see [docs/apps/claude-code.md](docs/apps/claude-code.md))

## [VS Code](https://code.visualstudio.com/) Extensions

[Full List of Used Extensions](./vscode-extensions.md)

## Documentation

Browse the complete documentation in the `docs/` directory:

<!-- TOC_START -->
- [mattmc3/zdotdir Design Patterns Analysis](docs/mattmc3-zdotdir-patterns.md)
  - **apps/**
    - [Android Studio Install Guide Linux](docs/apps/andriod-studio.md)
    - [Bambu Studio on Linux](docs/apps/bambu-studio.md)
    - [Claude Code](docs/apps/claude-code.md)
    - [Claude Desktop](docs/apps/claude-desktop.md)
    - [Conventional commits](docs/apps/git-conventional-commits.md)
    - [Fusion 360 on Pop!_OS](docs/apps/fusion-360.md)
    - [ghostty install PopOs - Linux](docs/apps/ghostty.md)
    - [Github](docs/apps/github.md)
    - [install](docs/apps/aws-cli-and-sam.md)
    - [Jellyfin  install PopOs - Linux](docs/apps/jellyfin.md)
    - [Last Epoch - Item Filter Examples](docs/apps/last-epoch.md)
    - [Last Epoch Filters](docs/apps/last-epoch-filters-generated.md)
    - [Mullvad VPN Quick Guide](docs/apps/mullvad-vpn.md)
    - [Open WebUi](docs/apps/open-webui.md)
    - [Plex Setup - Linux](docs/apps/plex.md)
    - [Pop!_OS Dual Boot](docs/apps/pop_os-dual-boot.md)
    - [Transmission](docs/apps/transmission.md)
    - [VS Code Insiders Setup](docs/apps/vscode-insiders.md)
    - [VSCode](docs/apps/vscode.md)
    - [Windows VM on Linux](docs/apps/windows-on-linux.md)
    - [Zellij Tutorial for Beginners](docs/apps/zellij.md)
    - **2026-01-04-cleanup/**
      - [Dotfiles Cleanup Research](docs/tasks/2026-01-04-cleanup/research.md)
  - **tools/**
    - [Vidsrc](docs/tools/vidsrc.md)
<!-- TOC_END -->

## Linux

- [Linux Setup Notes](./linux-setup-notes.md)
- [CopyQ](https://hluk.github.io/CopyQ/) - Advanced clipboard manager

## Mac - [Xcode](https://developer.apple.com/xcode/)

```bash
# If you get a path back (like /Applications/Xcode.app/Contents/Developer) then you're good to go
xcode-select -p

# Otherwise to install
xcode-select --install
```

- [Homebrew](https://brew.sh/)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update
```

- [iTerm2](https://iterm2.com/)
  ```bash
  # Install iTerm2
  brew install iterm2 --cask
  ```
   - Now in iTerm2 go to `Preferences > Profiles > Text` and set the font to `Hack Nerd Font`
- [Nerd Fonts](https://www.nerdfonts.com/)
  ```bash
  # Install Nerd Fonts
  brew tap homebrew/cask-fonts
  brew install --cask font-hack-nerd-font
  ```
  

- [Monosnap](https://monosnap.com/) - Screenshot and annotation tool
- Clipboard Manager
  - [CopyQ](https://hluk.github.io/CopyQ/) - Clipboard manager (Linux)
    - Setup autostart and keybinding
  - [Maccy](https://maccy.app/) - Tried as alternative to CopyQ after issues with it locking up when pasting
- [Magnet](https://magnet.crowdcafe.com/) - Window manager
- [VS Code Insiders](https://code.visualstudio.com/insiders/) - See [setup guide](docs/apps/code-insiders.md)
- [Spaceship](https://github.com/spaceship-prompt/spaceship-prompt). Currently using Spaceship and loving it. 



## Windows

- [WSL](https://docs.microsoft.com/en-us/windows/wsl/) - Windows Subsystem for Linux
- [Ditto](https://ditto-cp.sourceforge.io/) - Clipboard manager
- [Ninite](https://ninite.com/) - Bulk software installer

## History

I have a private repo I've been using to backup my `.zshrc` and other common scripts, but recently when rebuilding my home computer I thought I'd copy [Anthony Fu](https://github.com/antfu) and his [dotfiles](https://github.com/antfu/dotfiles) repo and make mine public.
