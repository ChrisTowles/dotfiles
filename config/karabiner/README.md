# Karabiner-Elements Configuration

This directory contains Karabiner-Elements configuration that gets symlinked to `~/.config/karabiner/`.

## VS Code Exclusion

VS Code and VS Code Insiders are excluded from all PC-Style keyboard mappings:

- `com.microsoft.VSCode`
- `com.microsoft.VSCodeInsiders`

This prevents Karabiner from remapping Ctrl+key shortcuts to Cmd+key in VS Code, allowing native VS Code keybindings to work (e.g., Ctrl+G for "Go to Line" instead of being remapped to Cmd+G).

Other terminal/editor apps (iTerm2, Terminal.app, Ghostty, Emacs, etc.) are also excluded from these PC-Style mappings.

## Setup

Symlink this directory to the Karabiner config location:

```bash
ln -sf ~/code/p/dotfiles/config/karabiner ~/.config/karabiner
```
