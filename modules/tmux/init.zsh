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

# tz - Fuzzy-pick a frecent dir (via z + fzf) and open/attach a tmux session there
# Usage: tz [query]   query pre-seeds the fzf search; empty picks from the full list
tz() {
  local dir
  dir=$(z -l 2>/dev/null \
    | sed 's/^[0-9.]*[[:space:]]*//' \
    | fzf --tac --query "$*" --header "Open tmux session in which dir? (ESC to cancel)")
  if [ -z "$dir" ] || [ ! -d "$dir" ]; then
    echo "Cancelled"
    return 1
  fi
  local session_name
  session_name=$(basename "$dir" | tr '.' '-')
  if [ -n "$TMUX" ]; then
    # Already inside tmux: create-if-missing (detached), then switch to it
    tmux has-session -t "$session_name" 2>/dev/null || \
      tmux new-session -d -s "$session_name" -c "$dir"
    tmux switch-client -t "$session_name"
  else
    tmux new-session -A -s "$session_name" -c "$dir"
  fi
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
# tka - Kill tmux server and clear saved sessions so nothing auto-restores
tka() {
  rm -f ~/.local/share/tmux/resurrect/last
  echo "Cleared saved sessions. Killing tmux server..."
  tmux kill-server
}
alias td='tmux detach'
alias tw='tmux list-windows'
alias tp='tmux list-panes'

# Complete running session names for ta (attach) and tk (kill)
_tmux_sessions_complete() {
  local -a sessions
  sessions=(${(f)"$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"})
  _describe -t sessions 'tmux session' sessions
}
compdef _tmux_sessions_complete ta tk
