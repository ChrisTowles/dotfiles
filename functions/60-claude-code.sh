# Claude Code setup and aliases

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v claude >/dev/null 2>&1; then
    echo " Installing Claude Code... (https://code.claude.com/docs/en/setup)"
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  # Configure settings, symlink CLAUDE.md, and rules
  bun run "${0:a:h}/../config/claude/setup-settings.ts"
  echo " Claude Code configured (settings, CLAUDE.md, rules)"

  # Add custom marketplaces
  local _claude_marketplaces=(
    ChrisTowles/towles-tool
  )
  for marketplace in "${_claude_marketplaces[@]}"; do
    local marketplace_name="${marketplace##*/}"
    if [[ ! -d "$HOME/.claude/plugins/marketplaces/$marketplace_name" ]]; then
      echo " Adding Claude marketplace: $marketplace"
      claude plugin marketplace add "$marketplace" 2>/dev/null || true
    else
      echo " Claude marketplace already added: $marketplace_name"
    fi
  done

  # Install plugins (format: name@marketplace)
  # Auto-update is enabled by default for claude-plugins-official marketplace
  local _claude_plugins=(
    superpowers@claude-plugins-official
    code-simplifier@claude-plugins-official
    typescript-lsp@claude-plugins-official
    claude-md-management@claude-plugins-official
    tt@towles-tool
  )
  local _settings_file="$HOME/.claude/settings.json"
  local _settings_content
  _settings_content=$(cat "$_settings_file" 2>/dev/null || echo "{}")
  for entry in "${_claude_plugins[@]}"; do
    if echo "$_settings_content" | grep -q "\"$entry\""; then
      echo " Claude plugin already installed: $entry"
    else
      echo " Installing Claude plugin: $entry"
      claude plugin install "$entry" 2>/dev/null || true
    fi
  done
fi

alias c="claude --dangerously-skip-permissions"
alias cr="claude --dangerously-skip-permissions --resume"


