# Chris's DotFiles

## Description

Optinated setup I use on my machine for things like terminal and  dot files like `.zshrc`.

## Install basic preprecs

- git
- vscode
- terminal
  - iTerm2 on mac
  
### Linux

[ubuntu notes](./ubuntu-notes.md)

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

## local only scripts

```bash
# create a per machine only file, Also I also use this to load additional scripts from a private repo.
touch $HOME/.zshrc_local

# switch back to previous .zshrc file
rm ~/.zshrc
mv ~/.zshrc.old ~/.zshrc

```

## Terminal shell - ZSH

- [.zshrc](.zshrc)
- [oh my zsh](https://ohmyz.sh/)
- [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-z](https://github.com/agkozak/zsh-z) - each switch common directories
- [nvm](https://github.com/nvm-sh/nvm) - use multiple versions of node
- [pnpm](https://pnpm.io/) - fast node manager with monorepos support.
- [antfu/ni](https://github.com/antfu/ni) - use the right package manager

## VsCode Extensions

[Full List of used Extensions](./vscode-extendsions.md)

## Mac Apps

- Iterm2
- Monosnap
- Copyq - clipboard manager
  - setup autostart and keybinding
- Magnet - window manager
- brew

## Linux Apps

- Copyq

## Windows

- WSL
- [Ditto](https://ditto-cp.sourceforge.io/) clipborard manager
- ninite

## History

So I have a private repo I've been using to backup my `.zshrc` and other common scripts but recently when rebuilding my home computer I thought I copy [Anthony Fu](https://github.com/antfu) and his [dotfiles](https://github.com/antfu/dotfiles) repo and made mine public.
