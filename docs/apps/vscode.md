# VSCode

- Always set saveOnEdit for `afterDelay`!!!

## Dictation

Install Microsoft Speech
https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-speech

Setup Ctrl+G in claude code, and then just use editor key bindings for dictation!

### Key bindings

Location: `~/.config/Code/User/keybindings.json`

```jsonc
[
  // Fix all with alt+f
  { "key": "alt+f", "command": "editor.action.fixAll" },

  // Terminal: ctrl+c for copy (instead of ctrl+shift+c)
  {
    "key": "ctrl+c",
    "command": "workbench.action.terminal.copySelection",
    "when": "terminalTextSelectedInFocused || terminalFocus && terminalHasBeenCreated && terminalTextSelected || terminalFocus && terminalProcessSupported && terminalTextSelected"
  },
  { "key": "ctrl+shift+c", "command": "-workbench.action.terminal.copySelection" },

  // Terminal: ctrl+v for paste (instead of ctrl+shift+v)
  {
    "key": "ctrl+v",
    "command": "workbench.action.terminal.paste",
    "when": "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported"
  },
  { "key": "ctrl+shift+v", "command": "-workbench.action.terminal.paste" },

  // Claude Code: shift+enter sends newline in terminal
  {
    "key": "shift+enter",
    "command": "workbench.action.terminal.sendSequence",
    "args": { "text": "\u001b\r" },
    "when": "terminalFocus"
  },

  // Claude Code: remove ctrl+g conflicts (allows opening prompt in editor)
  { "key": "ctrl+g", "command": "-workbench.action.gotoLine" },
  {
    "key": "ctrl+g",
    "command": "-workbench.action.terminal.goToRecentDirectory",
    "when": "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported"
  },

  // Quick open: remap to ctrl+alt+p (avoids zellij ctrl+p conflict)
  { "key": "ctrl+alt+p", "command": "workbench.action.quickOpen" },
  { "key": "ctrl+p", "command": "-workbench.action.quickOpen" },

  // Go to definition: ctrl+b (IntelliJ style)
  {
    "key": "ctrl+b",
    "command": "editor.action.revealDefinition",
    "when": "editorHasDefinitionProvider && editorTextFocus"
  },
  { "key": "f12", "command": "-editor.action.revealDefinition" },
  { "key": "ctrl+b", "command": "-markdown.extension.editing.toggleBold", "when": "!editorTextFocus" },

  // Dictation: ctrl+numpad0 for voice input
  {
    "key": "ctrl+numpad0",
    "command": "workbench.action.terminal.startVoice",
    "when": "terminalFocus && !speechToTextInProgress"
  },
  { "key": "ctrl+numpad0", "command": "workbench.action.terminal.stopVoice", "when": "speechToTextInProgress" },
  {
    "key": "ctrl+numpad0",
    "command": "workbench.action.editorDictation.start",
    "when": "editorFocus && hasSpeechProvider && !editorReadonly && !speechToTextInProgress"
  },
  { "key": "ctrl+numpad0", "command": "workbench.action.editorDictation.stop", "when": "editorDictation.inProgress" },
  { "key": "ctrl+numpad0", "command": "workbench.action.terminal.stopVoice", "when": "terminalDictationInProgress" }
]
```

## Testing performance tip posted by Jonson Chu

https://x.com/kyrylosilin/status/1849921659546812732

```json
"disable-hardware-acceleration": true
```

## Wrap of Editor

```json
{
  "editor.wordWrap": "on",
  "editor.wrappingIndent": "same",
  "editor.wordWrapColumn": 160,
  "editor.wordWrapMinified": true
}
```
