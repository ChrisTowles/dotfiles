# tmux - Terminal multiplexer helpers



# Setup: install tmux and symlink config
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v tmux >/dev/null 2>&1; then
    echo " Installing tmux..."
    case "$(uname -s)" in
      Darwin) brew install tmux ;;
      Linux) sudo apt install -y tmux ;;
    esac
  fi

  # macOS /bin/bash is 3.2 which lacks associative arrays — tmux plugins need bash 4+
  if [[ "$(uname -s)" == "Darwin" ]] && ! /opt/homebrew/bin/bash --version &>/dev/null; then
    echo " Installing modern bash (required for tmux plugins)..."
    brew install bash
  fi

  local config_src="${0:a:h}/../config/tmux/tmux.conf"
  if [[ -f "$config_src" ]]; then
    echo " Linking tmux config..."
    mkdir -p ~/.config/tmux
    ln -sf "$config_src" ~/.config/tmux/tmux.conf
  fi

  # Install TPM (Tmux Plugin Manager) into XDG config dir
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  _git_clone_or_pull "https://github.com/tmux-plugins/tpm" "$tpm_dir"
  # Install and update tmux plugins via TPM
  "$tpm_dir/bin/install_plugins"
  "$tpm_dir/bin/update_plugins" all
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
  if [ -n "$session" ]; then
    tmux switch-client -t "$session" 2>/dev/null || tmux attach -t "$session"
  fi
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
  echo "\033[1;36m── Starting a session ──\033[0m"
  echo "  ts         Start or reattach session named after current dir (most common)"
  echo "  tsn        Force a new session even if one exists for this dir"
  echo ""
  echo "\033[1;36m── Navigating sessions ──\033[0m"
  echo "  ta         Reattach to a session (fzf picker, or ta <name>)"
  echo "  tss        Switch between sessions while inside tmux"
  echo "  tl         List all running sessions"
  echo ""
  echo "\033[1;36m── Leaving a session ──\033[0m"
  echo "  td         Detach — leave session running in background, come back with ta"
  echo "  exit       Close current pane — kills session when it's the last pane"
  echo "  Ctrl+d     Same as exit"
  echo ""
  echo "\033[1;36m── Destroying sessions ──\033[0m"
  echo "  tkc        Kill the current session and drop out of tmux"
  echo "  tk         Kill a session by name or fzf picker (tk <name>)"
  echo "  tka        Kill tmux server — destroys ALL sessions"
  echo ""
  echo "\033[1;36m── Windows & panes ──\033[0m"
  echo "  tw         List windows in current session"
  echo "  tp         List panes in current window"
  echo ""
  echo "\033[1;36m── Keybindings (prefix = Ctrl+a) ──\033[0m"
  echo "  Sessions:"
  echo "    prefix d       Detach (same as td)"
  echo "    prefix s       List/pick sessions"
  echo "    prefix \$       Rename session"
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
  echo "    prefix [       Enter copy mode (scroll/copy text)"
  echo "    prefix :       Command prompt"
  echo "    prefix ?       List all keybindings"
}

# Aliases
alias tl='tmux list-sessions'
# tk - Kill session by name, or pick from fzf if no args (saves resurrect state after)
tk() {
  if [ -n "$1" ]; then
    tmux kill-session -t "$1"
  else
    local session
    session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --header "Kill which session? (ESC to cancel)")
    if [ -z "$session" ]; then
      echo "Cancelled"
      return 1
    fi
    tmux kill-session -t "$session"
  fi
  ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh 2>/dev/null
}
# tkc - Kill the current session (saves resurrect state after)
tkc() {
  tmux kill-session
  ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh 2>/dev/null
}
# tka - Save sessions then kill tmux server
tka() {
  ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh 2>/dev/null
  echo "Sessions saved. Killing tmux server..."
  tmux kill-server
}
alias td='tmux detach'
alias tw='tmux list-windows'
alias tp='tmux list-panes'
