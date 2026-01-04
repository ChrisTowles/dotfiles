#!/bin/zsh
# Display zsh key bindings reference

keybindings() {
  bat <<'EOF'
ZSH KEY BINDINGS
================

Modifier Key Legend:
  ^X = Ctrl+X    Alt+X = Alt+X    ESC = Escape

FZF Fuzzy Finder:
  ^R          Fuzzy history search
  ^T          Fuzzy file search (insert path)
  Alt+c       Fuzzy cd into directory

History Search (non-fzf):
  ↑/↓         Search history with current prefix
  ESC then k/j  Search history up/down (vi command mode)

Autosuggestions (zsh-autosuggestions):
  →/End       Accept full suggestion
  Alt+f       Accept partial suggestion (next word)

System Clipboard (vi mode):
  y           Yank to system clipboard
  p           Paste from system clipboard

Navigation:
  ^A          Beginning of line
  ^E          End of line
  ^L          Clear screen
  Alt+.       Insert last argument from previous command

Editing:
  ^U          Kill line backward (cut before cursor)
  ^K          Kill line forward (cut after cursor)
  ^W          Kill word backward
  Alt+d       Kill word forward
  ^Y          Yank (paste killed text)
  ^T          Transpose characters (or fzf file search)

Directory Jumping:
  z <pattern> Jump to frequent directory (zsh-z plugin)

Completion:
  ^Xa         Expand alias
  ^Xc         Correct word
  ^Xh         Complete help
  Tab         Complete/cycle through options

EOF
}
