#!/bin/zsh
# conf.d/50-claude.zsh - Claude Code configuration and aliases

command -v claude &>/dev/null || [[ -f "$HOME/.claude/local/claude" ]] || return 0

# Fix IDE detection in zellij by clearing conflicting env vars
# See: https://github.com/zellij-org/zellij/issues/4390
_claude_cmd="VSCODE_PID= VSCODE_CWD= TERM_PROGRAM= ~/.claude/local/claude"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PATH+=":$HOME/.claude/local/"
  alias claude="$_claude_cmd"
  alias c="$_claude_cmd --dangerously-skip-permissions"
  alias cr="$_claude_cmd --dangerously-skip-permissions --resume"
  #echo "Linux detected: Claude aliases set with --dangerously-skip-permissions"
else
  alias claude="$_claude_cmd"
  alias c="$_claude_cmd"
  alias cr="$_claude_cmd --resume"
  #echo "Non-Linux OS detected: Claude aliases set without --dangerously-skip-permissions"
fi

# Claude usage monitoring
alias ccusage="pnpm dlx ccusage blocks --live"

zsh_debug_section "Claude Code setup"
