# VS Code Terminal Ctrl+C Fix

## The Problem

Karabiner remaps `Ctrl+C` → `Cmd+C` for PC-style copy behavior. This happens system-wide except for excluded terminal apps (iTerm2, Terminal.app, Kitty, etc.). VS Code is **not excluded**, so `Ctrl+C` becomes `Cmd+C` (copy) instead of SIGINT.

## Solution: Use Ctrl+Shift+C

Added keybinding in VS Code to send SIGINT via `shift+cmd+c`:

```json
{
  "key": "shift+cmd+c",
  "command": "workbench.action.terminal.sendSequence",
  "args": { "text": "\u0003" },
  "when": "terminalFocus"
}
```

## Keybindings Summary

| Action                | VS Code Terminal                 |
| --------------------- | -------------------------------- |
| Kill process (SIGINT) | `Ctrl+Shift+C`                   |
| Copy text             | `Ctrl+C` (via Karabiner → Cmd+C) |
| Close tab             | `Ctrl+W`                         |

## Alternative: Exclude VS Code from Karabiner

If you want native `Ctrl+C` in VS Code, add to Karabiner's exclusion list:
```
^com\\.microsoft\\.VSCode$
```

This would make `Ctrl+C` work for SIGINT but require `Cmd+C` for copy.
