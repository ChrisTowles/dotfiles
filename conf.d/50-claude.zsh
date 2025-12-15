#!/bin/zsh
# conf.d/50-claude.zsh - Claude Code configuration and aliases

command -v claude &>/dev/null || [[ -f "$HOME/.claude/local/claude" ]] || return 0

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PATH+=":$HOME/.claude/local/"
  alias claude="~/.claude/local/claude"
  alias c="claude --dangerously-skip-permissions"
  alias cr="claude --dangerously-skip-permissions --resume"
else
  alias claude="~/.claude/local/claude"
  alias c="claude"
  alias cr="claude --resume"
fi

# Claude usage monitoring
alias ccusage="pnpm dlx ccusage blocks --live"

zsh_debug_section "Claude Code setup"
