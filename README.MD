# Chris's DotFiles

## Description

Setup dotfiles `.zshrc` from github.

```bash

# clone dotfiles repo locally
cd ~
mkdir -p ~/code/p
cd ~/code/p
git clone https://github.com/ChrisTowles/dotfiles.git
cd dotFiles


# make symbolic link for .zshrc
cd ~/
ln -s $HOME/code/p/dotfiles/.zshrc $HOME/.zshrc
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

## History

So I have a private repo I've been using to backup my `.zshrc` and other common scripts but recently when rebuilding my home computer I thought I copy [Anthony Fu](https://github.com/antfu) and his [dotfiles](https://github.com/antfu/dotfiles) repo and make my it public.
