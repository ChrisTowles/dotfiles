# Claude Code setup and aliases

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v claude >/dev/null 2>&1; then
    echo " Installing Claude Code... (https://code.claude.com/docs/en/setup)"
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  # Configure statusline and hooks in ~/.claude/settings.json
  bun run "${0:a:h}/../config/claude/setup-settings.ts"
  echo " Claude Code hooks configured"
fi

alias c="claude --dangerously-skip-permissions"
alias cr="claude --dangerously-skip-permissions --resume"


