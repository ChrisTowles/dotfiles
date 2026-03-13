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
    anthropics/skills
    anthropics/claude-plugins-official
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
    typescript-lsp@claude-plugins-official
    claude-md-management@claude-plugins-official
    frontend-design@claude-plugins-official
    feature-dev@claude-plugins-official
    plugin-dev@claude-plugins-official
    hookify@claude-plugins-official
    skill-creator@claude-plugins-official
    
  )
  #tt@towles-tool
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

  # MCP servers at user scope (format: name command args...)
  local _claude_mcps=(
    "chrome-devtools npx chrome-devtools-mcp@latest --browserUrl http://127.0.0.1:9222"
  )
  local _claude_json="$HOME/.claude.json"
  local _claude_json_content
  _claude_json_content=$(cat "$_claude_json" 2>/dev/null || echo "{}")
  for entry in "${_claude_mcps[@]}"; do
    local mcp_name="${entry%% *}"
    if echo "$_claude_json_content" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if '$mcp_name' in d.get('mcpServers',{}) else 1)" 2>/dev/null; then
      echo " Claude MCP already configured (user): $mcp_name"
    else
      echo " Adding Claude MCP server (user): $mcp_name"
      local mcp_args="${entry#* }"
      claude mcp add -s user "$mcp_name" -- ${=mcp_args} 2>/dev/null || true
    fi
  done
fi

alias c="claude --dangerously-skip-permissions"
alias cr="claude --dangerously-skip-permissions --resume"


