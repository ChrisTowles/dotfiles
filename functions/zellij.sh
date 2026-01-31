# zellij functions - Terminal multiplexer helpers

# zj - Attach/create session named after current directory
zj() {
  if [ -n "$ZELLIJ" ]; then
    echo "Already in zellij session"
    return 1
  fi
  local session_name
  session_name=$(basename "$PWD")
  zellij attach -c "$session_name"
}

# zjcn - Zellij create new session (named after current directory, always new)
zjcn() {
  if [ -n "$ZELLIJ" ]; then
    echo "Already in zellij session"
    return 1
  fi
  local session_name
  session_name=$(basename "$PWD")
  zellij -s "$session_name"
}

# Aliases
alias zjs='zellij -s'
alias zja='zellij attach'
alias zjl='zellij list-sessions'
alias zjk='zellij kill-session'
alias zjka='zellij kill-all-sessions'
alias zjr='zellij run --'
