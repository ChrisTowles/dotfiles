# VS Code Terminal Ctrl+C Fix

## The Problem

Karabiner remaps `Ctrl+C` → `Cmd+C` for PC-style copy behavior. This happens system-wide except for excluded terminal apps (iTerm2, Terminal.app, Kitty, etc.). VS Code is **not excluded**, so `Ctrl+C` becomes `Cmd+C` (copy) instead of SIGINT.

## Solution: Use Ctrl+Shift+C

Karabiner passes `Ctrl+Shift+C` through as `shift+cmd+c` (the copy rule keeps optional
modifiers). VS Code binds that by default to `workbench.action.terminal.openNativeConsole`
("Open New External Terminal") — which is what fires if you only *add* a sendSequence
binding: the process keeps running and an external Terminal window opens instead. Unbind
the default, re-add it outside the terminal, then bind SIGINT:

```json
{ "key": "shift+cmd+c", "command": "-workbench.action.terminal.openNativeConsole" },
{
  "key": "shift+cmd+c",
  "command": "workbench.action.terminal.openNativeConsole",
  "when": "!terminalFocus"
},
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
