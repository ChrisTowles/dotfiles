# Chris's DotFiles

## Description

Opinionated setup I use on my machine for things like terminal and  dot files like `.zshrc`.

## Install core tools

- git
- vscode
  
### Linux

[Linux setup Notes](./linux-setup-notes.md)

## Setup ZSH alialas

```bash
# clone dotfiles repo locally
cd ~
mkdir -p ~/code/p
cd ~/code/p
git clone https://github.com/ChrisTowles/dotfiles.git
cd dotfiles

```

## Link a few files from the repo to home directory

```bash
# make symbolic link for .zshrc
cd ~/
mv .zshrc .zshrc.old
ln -s $HOME/code/p/dotfiles/.zshrc $HOME/.zshrc
```



# Setup Fish shell

I'm exploring Fish shell as an alternative to Zsh for two key reasons:

- **Copy/paste keybindings** - I use macOS at work and have rebound `Ctrl+C` and `Ctrl+V` for copy/paste in terminal. On Linux, implementing this in Zsh and Bash never works reliably. Fish is the first shell with built-in support for custom copy/paste bindings to override the default `Ctrl+C`(SIGINT) behavior.
- **Terminal startup performance** - [Oh My Zsh](https://ohmyz.sh/) was excellent but significantly slowed terminal startup time. Fish with Starship offers similar functionality with much faster startup performance.



```bash
mkdir -p ~/.config/fish

ln -s $HOME/code/p/dotfiles/.config/fish/config.fish $HOME/.config/fish/config.fish
ln -s $HOME/code/p/dotfiles/.config/fish/custom_functions $HOME/.config/fish/custom_functions

fish

# install fisher to manage plugins
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# remove new plugins file
rm -rf ~/.config/fish/fish_plugins

# link fish plugins file from dotfiles repo
ln -s $HOME/code/p/dotfiles/.config/fish/fish_plugins $HOME/.config/fish/fish_plugins


```

## local only scripts

```bash
# create a per machine only file, Also I also use this to load additional scripts from a private repo.
touch $HOME/.zshrc_local

# switch back to previous .zshrc file
rm ~/.zshrc
mv ~/.zshrc.old ~/.zshrc

```

## Terminal shell - ZSH / Fish

### ZSH Configuration
- [.zshrc](.zshrc)
- [oh my zsh](https://ohmyz.sh/)
- [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-z](https://github.com/agkozak/zsh-z) - each switch common directories

### Fish Shell Configuration
- [.config/fish/](.config/fish/) - Fish shell configuration with custom key bindings
- [Starship prompt](https://starship.rs/) - Cross-shell prompt
- Custom Ctrl+C/Ctrl+V copy/paste bindings

### Common Tools
- [nvm](https://github.com/nvm-sh/nvm) - use multiple versions of node
- [pnpm](https://pnpm.io/) - fast node manager with monorepos support.
- [antfu/ni](https://github.com/antfu/ni) - use the right package manager

## VsCode Extensions

[Full List of used Extensions](./vscode-extendsions.md)

## Mac - [xcode](https://developer.apple.com/xcode/)

```bash

 # If you get a path back (like /Applications/Xcode.app/Contents/Developer) then you're good to go
xcode-select -p

# Otherwise to install
xcode-select --install

```

- brew

```bash
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update
```

- git
  - ```bash
    brew install git
    ```
- zsh
  - ```bash
    brew install zsh

    # change default shell to zsh
    chsh -s /usr/local/bin/zsh
    ```
- Iterm2
  - ```bash
    # install iterm2
    brew install iterm2 --cask
    ```
- [oh my zsh](https://ohmyz.sh/)
  - ```bash
    # install oh my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
- Nerd Fonts
  - ```bash
    # install nerd fonts
    brew tap homebrew/cask-fonts
    brew install --cask font-hack-nerd-font
    ```
  - Now in iterm2 go to `Preferences > Profiles > Text` and set the font to `Hack Nerd Font`

- Monosnap
- Clipboard manager
  - Copyq - clipboard manager (linux)
    - setup autostart and keybinding
  - maccy - tried as alternative to copyq after issues with it locking up when pasting.

- Magnet - window manager

- vscode insiders - make "code" as open "code-insiders" that other apps can pickup instead of a bash alias.

```sh
cd /usr/local/bin
ls
sudo unlink code
sudo ln -s "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code" code
```

### Todo

Look into [Powerlevel10k](https://github.com/romkatv/powerlevel10k#powerlevel10k) vs [Spaceship](https://github.com/spaceship-prompt/spaceship-prompt). Currently, using Spaceship and loving it. 

## Linux Apps

- Copyq

## Windows

- WSL
- [Ditto](https://ditto-cp.sourceforge.io/) clipborard manager
- ninite

## History

So I have a private repo I've been using to backup my `.zshrc` and other common scripts but recently when rebuilding my home computer I thought I copy [Anthony Fu](https://github.com/antfu) and his [dotfiles](https://github.com/antfu/dotfiles) repo and made mine public.
