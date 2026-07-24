# Karabiner-Elements Configuration

This directory contains Karabiner-Elements configuration that gets symlinked to `~/.config/karabiner/`.

## Terminal Exclusion

Terminal apps (Terminal.app, iTerm2, Ghostty, kitty, Alacritty, Hyper, Emacs, and
Towles Tool — `dev.towles.tool`) are excluded from every PC-Style Ctrl→Cmd rule, so
Ctrl+key reaches the shell as a control byte: **Ctrl+C is SIGINT**, Ctrl+A/R/W/K keep
their readline/tmux meaning.

## VS Code

VS Code is **not** a blanket exclusion — it is only excluded from the Select-All, Find,
and Close Window rules (`com.microsoft.VSCode`, `com.microsoft.VSCodeInsiders`). Ctrl+C
still becomes Cmd+C (copy) everywhere in VS Code, including the integrated terminal, so
SIGINT there goes through **Ctrl+Shift+C** — see
[../vscode/mac/vscode-terminal-ctrl-c.md](../vscode/mac/vscode-terminal-ctrl-c.md).

## Linux-Style Terminal Copy/Paste

Terminal apps use **Ctrl+Shift+C/V** for copy/paste (matching Linux terminal conventions), handled by a dedicated Karabiner rule:

| Shortcut | Action | How |
| --- | --- | --- |
| Ctrl+Shift+C | Copy | → Cmd+C via Karabiner (→ Cmd+Shift+C in Towles Tool, its own copy chord) |
| Ctrl+V | Paste (text) | → Cmd+V via Karabiner |
| Ctrl+Shift+V | Paste (image) | → raw Ctrl+V (Claude Code reads clipboard) |
| Ctrl+C | SIGINT (kill process) | Raw passthrough (excluded from remap) |

Ctrl+Shift+V sends raw Ctrl+V so Claude Code can detect and paste images from the clipboard. Ctrl+V does standard text paste.

Towles Tool's canvas terminals implement copy/paste in the app itself (macOS chords
Cmd+Shift+C / Cmd+Shift+V), which is why its Ctrl+Shift+C maps to Cmd+Shift+C rather
than Cmd+C — a plain Cmd+C copies nothing from a canvas.

## Setup

Symlink this directory to the Karabiner config location:

```bash
ln -sf ~/code/p/dotfiles/config/karabiner ~/.config/karabiner
```
