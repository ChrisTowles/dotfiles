# Chris's Dotfiles

## Description

Opinionated setup I use on my machine for things like terminal and dotfiles like `.zshrc`.

![](/docs/images/example-for-my-shell.png)


## Prerequisites

- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/)
- [Set zsh as your default shell](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#how-to-install-zsh-on-many-platforms)

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



**Modular Design**: The configuration is split into focused modules in `additional_scripts/`:
- **Core**: [.zshrc](.zshrc) - Main loader with smart conditional sourcing
- **Oh My Zsh**: Theme, plugins, and core functionality  
- **Git Tools**: Aliases, helper functions, and GitHub CLI integration
- **Node.js**: NVM, pnpm, and development tools
- **Optional**: Docker, Python, Claude CLI, and more

**Key Features**:
- **Smart Loading**: Only loads modules for installed tools
- **Auto-Installation**: Built-in dependency installer
- **Cross-Platform**: Works on Linux and macOS
- **Fast Startup**: Optimized loading with timing debug support

**Included Tools**:
- [oh my zsh](https://ohmyz.sh/) with plugins
- [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-z](https://github.com/agkozak/zsh-z) - jump to frequent directories
- [zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard) - system copy/paste

### Common Tools
- [nvm](https://github.com/nvm-sh/nvm) - Use multiple versions of Node.js
- [pnpm](https://pnpm.io/) - Fast Node.js package manager with monorepo support
- [antfu/ni](https://github.com/antfu/ni) - Use the right package manager

## [VS Code](https://code.visualstudio.com/) Extensions

[Full List of Used Extensions](./vscode-extensions.md)

## Documentation

Browse the complete documentation in the `docs/` directory:

<!-- TOC_START -->
  - **apps/**
    - [Android Studio Install Guide Linux](docs/apps/andriod-studio.md)
    - [Bambu Studio on Linux](docs/apps/bambu-studio.md)
    - [Claude Code](docs/apps/claude-code.md)
    - [Conventional commits](docs/apps/git-conventional-commits.md)
    - [Fusion 360 on Pop!_OS](docs/apps/fustion-360.md)
    - [ghostty install PopOs - Linux](docs/apps/ghostty.md)
    - [Github](docs/apps/github.md)
    - [install](docs/apps/aws-cli-and-sam.md)
    - [Jellyfin  install PopOs - Linux](docs/apps/jellyfin.md)
    - [Last Epoch - Item Filter Examples](docs/apps/last-epoch.md)
    - [Mullvad VPN Quick Guide](docs/apps/mullvad-vpn.md)
    - [Open WebUi](docs/apps/open-webui.md)
    - [Plex Setup - Linux](docs/apps/plex.md)
    - [Pop_IOS Dual Boot](docs/apps/pop_os-dual-boot.md)
    - [Terminl Tools](docs/apps/terminal.md)
    - [Transmission](docs/apps/transmission.md)
    - [VS Code Insiders Setup](docs/apps/code-insiders.md)
    - [VSCode](docs/apps/vscode.md)
    - [Windows VM on Linux](docs/apps/windows-on-linux.md)
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
- [oh my zsh](https://ohmyz.sh/)
  ```bash
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```
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
