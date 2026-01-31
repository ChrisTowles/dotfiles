# CopyQ - Clipboard Manager

Clipboard manager with history, search, and image support.

## Installation

Use apt, not Flatpak. Flatpak has sandbox issues on Wayland.

```bash
sudo apt install -y copyq
```

## Setup on Pop!_OS (COSMIC Desktop)

### 1. Start CopyQ

```bash
copyq &
```

### 2. Enable Autostart

- Open CopyQ preferences
- General → Check "Autostart


### 3. Set Keybinding

```bash
cosmic-settings keyboard
```

Add custom shortcut:
- Command: `copyq toggle`
- Keybinding: `Ctrl + `` ``

