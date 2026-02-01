# Chris's Dotfiles

Personal setup notes and documentation for my development environment.

## Git Configuration

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git config --global core.editor "code-insiders --wait"
git config --global push.default current
```

## Setup

- [Linux Setup Notes](./docs/linux-setup-notes.md)
- [Mac Setup Notes](./docs/mac-setup-notes.md)
- [VS Code Extensions](./docs/vscode-extendsions.md)

## Documentation

Browse app-specific guides in `docs/apps/`.

## Starship

- <https://starship.rs>

### Nerd Font (required for icons)

Install a Nerd Font so Starship icons render correctly (especially in VSCode terminal):

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip
unzip FiraCode.zip -d FiraCode
rm FiraCode.zip
fc-cache -fv
```

Then configure VSCode terminal font in `settings.json`:

```json
"terminal.integrated.fontFamily": "FiraCode Nerd Font"
```

## Zsh Plugins

- [zsh-completions](https://github.com/zsh-users/zsh-completions)
  - lets you tab to complete any command line arguments
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - As you type commands, you will see a completion offered from your history
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
  - type part of a previous command and search your history to find it
- [zsh-z (directory jumping)](https://github.com/agkozak/zsh-z)
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
