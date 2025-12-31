#!/bin/zsh
# conf.d/50-zellij.zsh - Zellij terminal multiplexer

command -v zellij &>/dev/null || return 0

# Aliases
alias zj='zellij'
alias zjs='zellij -s' # start new named session
alias zja='zellij attach'
alias zjl='zellij list-sessions'
alias zjk='zellij kill-session'
alias zjka='zellij kill-all-sessions'
alias zjr='zellij run --'

alias zj-disable-tmp='ZELLIJ_AUTO_START=false zsh'

# Auto-attach to existing session or create new one
zellij-auto() {
  if [[ -z "$ZELLIJ" ]]; then
    zellij attach -c main
  fi
}

# Attach/create session named after current directory
zj.() {
  if [[ -n "$ZELLIJ" ]]; then
    echo "Already in zellij session"
    return 1
  fi
  local session_name="${PWD:t}"
  zellij attach -c "$session_name"
}

# Auto-start zellij (skip if: already in zellij, in vscode, in ssh, or disabled)
if [[ -z "$ZELLIJ" && -z "$VSCODE_INJECTION" && -z "$SSH_CONNECTION" && "$ZELLIJ_AUTO_START" != "false" ]]; then
  # not ready to default to zellij, yet. 
  # will try to attach to 'main' session or create it if it doesn't exist
  # zellij attach -c main
fi

zsh_debug_section "Zellij setup"
