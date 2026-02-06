# tmux - Terminal multiplexer helpers



# Setup: symlink tmux config
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  local config_src="${0:a:h}/../config/tmux/tmux.conf"
  if [[ -f "$config_src" ]]; then
    echo " Linking tmux config..."
    mkdir -p ~/.config/tmux
    ln -sf "$config_src" ~/.config/tmux/tmux.conf
  fi

  # Install TPM (Tmux Plugin Manager)
  if [[ -d ~/.tmux/plugins/tpm ]]; then
    echo " Updating TPM..."
    git -C ~/.tmux/plugins/tpm pull
  else
    echo " Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  echo " Run 'prefix + I' inside tmux to install plugins"
fi

# ts - Attach/create session named after current directory
ts() {
  if [ -n "$TMUX" ]; then
    echo "Already in tmux session"
    return 1
  fi
  local session_name
  session_name=$(basename "$PWD" | tr '.' '-')
  tmux new-session -A -s "$session_name"
}

# tsn - Create new session (named after current directory, always new)
tsn() {
  if [ -n "$TMUX" ]; then
    echo "Already in tmux session"
    return 1
  fi
  local session_name
  session_name=$(basename "$PWD" | tr '.' '-')
  tmux new-session -s "$session_name"
}

# tss - Switch session with fzf
tss() {
  local session
  session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --header "Select tmux session")
  [ -n "$session" ] && tmux switch-client -t "$session" 2>/dev/null || tmux attach -t "$session"
}

# ta - Attach to a session by name, or pick from fzf if no args
ta() {
  if [ -n "$1" ]; then
    tmux attach -t "$1"
    return
  fi
  local session
  session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --header "Select tmux session (ESC to cancel)")
  if [ -z "$session" ]; then
    echo "Cancelled"
    return 1
  fi
  tmux attach -t "$session"
}

# tmux-help - Print all custom tmux aliases and keybindings
tmux-help() {
  echo "\033[1;36mCustom tmux aliases:\033[0m"
  echo "  ts       Attach/create session named after current dir"
  echo "  tsn      Always create new session named after current dir"
  echo "  tss      Switch session with fzf picker"
  echo "  ta       Attach to session (fzf picker if no args)"
  echo "  tl       List sessions"
  echo "  tk       Kill session (current if no args, or tk <name>)"
  echo "  tka      Kill all sessions"
  echo "  td       Detach"
  echo "  tw       List windows"
  echo "  tp       List panes"
  echo ""
  echo "\033[1;36mDefault tmux keybindings (prefix = Ctrl+a):\033[0m"
  echo "  Sessions:"
  echo "    prefix s       List sessions"
  echo "    prefix \$       Rename session"
  echo "    prefix d       Detach"
  echo "    prefix (  )    Previous/next session"
  echo "  Windows:"
  echo "    prefix c       New window"
  echo "    prefix ,       Rename window"
  echo "    prefix n  p    Next/previous window"
  echo "    prefix 0-9     Go to window by number"
  echo "    prefix &       Kill window"
  echo "  Panes:"
  echo "    prefix |       Split vertical"
  echo "    prefix -       Split horizontal"
  echo "    prefix h/j/k/l Navigate panes (vim-style)"
  echo "    prefix z       Toggle pane zoom"
  echo "    prefix x       Kill pane"
  echo "    prefix {  }    Swap pane left/right"
  echo "  Other:"
  echo "    prefix [       Enter copy mode"
  echo "    prefix :       Command prompt"
  echo "    prefix ?       List all keybindings"
}

# Aliases
alias tl='tmux list-sessions'
# tk - Kill session by name, or kill current session if no args
tk() {
  if [ -n "$1" ]; then
    tmux kill-session -t "$1"
  else
    tmux kill-session
  fi
}
alias tka='tmux kill-server'
alias td='tmux detach'
alias tw='tmux list-windows'
alias tp='tmux list-panes'
