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

## Devices (`ignore: false`)

Karabiner **ignores game pads by default**. The Keychron Q6 HE 8K advertises
`is_game_pad: true` alongside `is_keyboard`/`is_pointing_device`, so out of the box
Karabiner sees it (`caps lock is found on Keychron Q6 HE 8K` in the log) but never
grabs it — every PC-Style rule silently does nothing while the keyboard still types
fine. The `devices` block in `karabiner.json` pins `ignore: false` for it.

Symptom check when a new keyboard's remaps don't apply:

```bash
karabiner_cli --list-connected-devices | grep -A 8 -i '<keyboard name>'   # look for is_game_pad
grep '<keyboard name>' /var/log/karabiner/core_service.log                # want "(grabbed)"
```

`karabiner_cli` lives at
`/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli`.
The equivalent GUI action is Settings → Devices → check **Modify events** for the device.
