#!/bin/zsh
# conf.d/50-zellij.zsh - Zellij terminal multiplexer

command -v zellij &>/dev/null || return 0

# Aliases
#alias zj='zellij'
alias zjs='zellij -s' # start new named session
alias zja='zellij attach'
alias zjl='zellij list-sessions'
alias zjk='zellij kill-session'
alias zjka='zellij kill-all-sessions'
alias zjr='zellij run --'

# zp command is in bin/zp (Python script)
# Usage: zp <prompt> - runs claude in tasks stack, returns focus

# Auto-attach to existing session or create new one
zellij-auto() {
  if [[ -z "$ZELLIJ" ]]; then
    zellij attach -c main
  fi
}

# Attach/create session named after current directory
zj() {
  if [[ -n "$ZELLIJ" ]]; then
    echo "Already in zellij session"
    return 1
  fi
  local session_name="${PWD:t}"
  zellij attach -c "$session_name"
}

# Claude dev layout - add tabs to existing session or create new
zjc() {
  local session_name="${PWD:t}"
  if [[ -n "$ZELLIJ" ]]; then
    # Inside session: add layout as new tabs
    zellij action new-tab -l ~/.config/zellij/layouts/claude-dev.kdl
  else
    # Outside: create/attach session with layout
    zellij -l ~/.config/zellij/layouts/claude-dev.kdl attach -c "$session_name"
  fi
}

# Claude dev layout - always start fresh session (overwrites)
zjcn() {
  if [[ -n "$ZELLIJ" ]]; then
    echo "Already in zellij - use zjc to add tabs"
    return 1
  fi
  local session_name="${PWD:t}"
  # Remove existing session (kill if alive, delete if dead)
  zellij kill-session "$session_name" 2>/dev/null
  zellij delete-session "$session_name" 2>/dev/null
  zellij -n ~/.config/zellij/layouts/claude-dev.kdl -s "$session_name"
}

# Auto-start zellij (skip if: already in zellij, in vscode, in ssh, or disabled)
# if [[ -z "$ZELLIJ" && -z "$VSCODE_INJECTION" && -z "$SSH_CONNECTION" && "$ZELLIJ_AUTO_START" != "false" ]]; then
#   # not ready to default to zellij, yet. 
#   # will try to attach to 'main' session or create it if it doesn't exist
#   # zellij attach -c main
# fi

zsh_debug_section "Zellij setup"
