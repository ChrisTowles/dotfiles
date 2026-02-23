# VS Code Configuration

## Keybinding Unbind+Bind Pattern (macOS)

Karabiner remaps `Ctrl+<key>` → `Cmd+<key>` for PC-style shortcuts. VS Code is excluded from most PC-style remaps, but terminal-critical shortcuts may still need special handling in the integrated terminal.

To override a keybinding for the integrated terminal, you must **both unbind the default command AND bind the replacement**. Just adding a `sendSequence` binding is not enough — VS Code's default binding still fires.

### Pattern

```jsonc
// 1. Remove the default command globally (no when clause = matches the default)
{
  "key": "cmd+a",
  "command": "-editor.action.selectAll"
},
// 2. Remove the terminal-specific command
{
  "key": "cmd+a",
  "command": "-workbench.action.terminal.selectAll"
},
// 3. Re-add the default command excluding terminal context
{
  "key": "cmd+a",
  "command": "editor.action.selectAll",
  "when": "!terminalFocus"
},
// 4. Bind the terminal replacement
{
  "key": "cmd+a",
  "command": "workbench.action.terminal.sendSequence",
  "args": { "text": "\u0001" },
  "when": "terminalFocus"
}
```

### Key Points

- The `-` prefix unbind must match the original binding's `when` clause (or have none) to actually remove it. Adding a `when` to a `-` entry doesn't mean "remove conditionally".
- You often need to remove **two bindings**: a generic `editor.action.*` and a terminal-specific `workbench.action.terminal.*`.
- After removing, **re-add** the default command with `"when": "!terminalFocus"` so it still works outside the terminal.
- The `sendSequence` text uses Unicode escapes for control characters: `\u0001` = Ctrl+A, `\u0003` = Ctrl+C, etc.
