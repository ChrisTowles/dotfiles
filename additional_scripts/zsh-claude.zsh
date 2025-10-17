# zsh-claude.zsh
# Claude Code configuration and aliases

# install claude code - see docs/apps/claude-code.md
# fpath+=~/.zfunc; autoload -Uz compinit; compinit


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PATH+=":$HOME/.claude/local/"
    alias claude="~/.claude/local/claude"
    alias c="claude --dangerously-skip-permissions"
    alias cr="claude --dangerously-skip-permissions --resume"
else
  # shorthand alias to run claude prompt

  alias claude="~/.claude/local/claude"
  alias c="claude"
  alias cr="claude --resume"

fi

# Claude usage monitoring
alias ccusage="pnpm dlx ccusage blocks --live"

zsh_debug_section "Claude Code setup"