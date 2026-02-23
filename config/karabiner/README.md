# Karabiner-Elements Configuration

This directory contains Karabiner-Elements configuration that gets symlinked to `~/.config/karabiner/`.

## VS Code Exclusion

VS Code and VS Code Insiders are excluded from all PC-Style keyboard mappings:

- `com.microsoft.VSCode`
- `com.microsoft.VSCodeInsiders`

This prevents Karabiner from remapping Ctrl+key shortcuts to Cmd+key in VS Code, allowing native VS Code keybindings to work (e.g., Ctrl+G for "Go to Line" instead of being remapped to Cmd+G).

Other terminal/editor apps (iTerm2, Terminal.app, Ghostty, Emacs, etc.) are also excluded from these PC-Style mappings.

## Linux-Style Terminal Copy/Paste

Terminal apps use **Ctrl+Shift+C/V** for copy/paste (matching Linux terminal conventions), handled by a dedicated Karabiner rule:

| Shortcut | Action | How |
| --- | --- | --- |
| Ctrl+Shift+C | Copy | → Cmd+C via Karabiner |
| Ctrl+V | Paste (text) | → Cmd+V via Karabiner |
| Ctrl+Shift+V | Paste (image) | → raw Ctrl+V (Claude Code reads clipboard) |
| Ctrl+C | SIGINT (kill process) | Raw passthrough (excluded from remap) |

Ctrl+Shift+V sends raw Ctrl+V so Claude Code can detect and paste images from the clipboard. Ctrl+V does standard text paste.

## Setup

Symlink this directory to the Karabiner config location:

```bash
ln -sf ~/code/p/dotfiles/config/karabiner ~/.config/karabiner
```
