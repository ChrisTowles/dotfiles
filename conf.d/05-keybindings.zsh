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
