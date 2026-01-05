#!/bin/zsh
# Keybindings configuration

# History substring search (type partial command, up/down to filter)
# Plugin: zsh-users/zsh-history-substring-search
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up      # Up arrow
  bindkey '^[[B' history-substring-search-down    # Down arrow
  bindkey '^[OA' history-substring-search-up      # Up arrow (alternate)
  bindkey '^[OB' history-substring-search-down    # Down arrow (alternate)
  # vi mode support
  # bindkey -M vicmd 'k' history-substring-search-up
  #  bindkey -M vicmd 'j' history-substring-search-down
fi



# Keybindings for word navigation
# Ctrl+Left/Right to move by word
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[f' forward-word          # Alt+f (fallback)
bindkey '^[b' backward-word         # Alt+b (fallback)

# Home/End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line   # Home (alternate)
bindkey '^[[4~' end-of-line         # End (alternate)

# Delete word
bindkey '^[[3;5~' kill-word         # Ctrl+Delete
bindkey '^H' backward-kill-word     # Ctrl+Backspace
