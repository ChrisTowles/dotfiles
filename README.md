# Chris's DotFiles

## Description

Opinionated setup I use on my machine for things like terminal and  dot files like `.zshrc`.

## Install core tools

- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/)
  
### Linux

[Linux setup Notes](./linux-setup-notes.md)

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
- `zsh-install-deps` - Run the interactive dependency installer only
- `zsh-check-deps` - Check which dependencies are missing


## local only scripts

```bash
# create a per machine only file, Also I also use this to load additional scripts from a private repo.
touch $HOME/.zshrc_local

```

## Terminal shell - ZSH / Fish

### ZSH Configuration

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
- [nvm](https://github.com/nvm-sh/nvm) - use multiple versions of node
- [pnpm](https://pnpm.io/) - fast node manager with monorepos support.
- [antfu/ni](https://github.com/antfu/ni) - use the right package manager

## [VS Code](https://code.visualstudio.com/) Extensions

[Full List of used Extensions](./vscode-extendsions.md)

## Mac - [xcode](https://developer.apple.com/xcode/)

```bash

 # If you get a path back (like /Applications/Xcode.app/Contents/Developer) then you're good to go
xcode-select -p

# Otherwise to install
xcode-select --install

```

- [Homebrew](https://brew.sh/)

```bash
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update
```

- [iTerm2](https://iterm2.com/)
  - ```bash
    # install iterm2
    brew install iterm2 --cask
    ```
- [oh my zsh](https://ohmyz.sh/)
  - ```bash
    # install oh my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
- [Nerd Fonts](https://www.nerdfonts.com/)
  - ```bash
    # install nerd fonts
    brew tap homebrew/cask-fonts
    brew install --cask font-hack-nerd-font
    ```
  - Now in iTerm2 go to `Preferences > Profiles > Text` and set the font to `Hack Nerd Font`

- [Monosnap](https://monosnap.com/) - Screenshot and annotation tool
- Clipboard manager
  - [CopyQ](https://hluk.github.io/CopyQ/) - clipboard manager (linux)
    - setup autostart and keybinding
  - [Maccy](https://maccy.app/) - tried as alternative to copyq after issues with it locking up when pasting.

- [Magnet](https://magnet.crowdcafe.com/) - window manager

- [VS Code Insiders](https://code.visualstudio.com/insiders/) - See [setup guide](docs/apps/code-insiders.md)

### Todo

Look into [Powerlevel10k](https://github.com/romkatv/powerlevel10k#powerlevel10k) vs [Spaceship](https://github.com/spaceship-prompt/spaceship-prompt). Currently, using Spaceship and loving it. 

## Linux Apps

- [CopyQ](https://hluk.github.io/CopyQ/) - Advanced clipboard manager

## Windows

- [WSL](https://docs.microsoft.com/en-us/windows/wsl/) - Windows Subsystem for Linux
- [Ditto](https://ditto-cp.sourceforge.io/) - clipboard manager
- [Ninite](https://ninite.com/) - bulk software installer

## History

So I have a private repo I've been using to backup my `.zshrc` and other common scripts but recently when rebuilding my home computer I thought I copy [Anthony Fu](https://github.com/antfu) and his [dotfiles](https://github.com/antfu/dotfiles) repo and made mine public.
