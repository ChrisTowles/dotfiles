# Claude Code setup and aliases

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v claude >/dev/null 2>&1; then
    echo " Installing Claude Code... (https://code.claude.com/docs/en/setup)"
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  # Update Claude Desktop
  if [[ "$(uname)" == "Darwin" ]]; then
    echo " Updating Claude Desktop (brew)..."
    brew upgrade --cask claude 2>/dev/null || brew install --cask claude 2>/dev/null || true
  else
    if command -v apt >/dev/null 2>&1; then
      echo " Updating Claude Desktop (apt)..."
      sudo apt update -qq && sudo apt install -y claude-desktop 2>/dev/null || true
    fi
  fi

  # Add custom marketplaces (before setup-settings.ts so auto-update can find them)
  local _claude_marketplaces=(
    anthropics/skills
    anthropics/claude-plugins-official
    ChrisTowles/towles-tool
    obra/superpowers-marketplace
    EveryInc/compound-engineering-plugin
    trailofbits/skills
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

  # Configure settings, symlink CLAUDE.md, install plugins, and rules
  bun run "${0:a:h}/../config/claude/setup-settings.ts"
  echo " Claude Code configured (settings, CLAUDE.md, plugins, rules)"

  # MCP servers at user scope (format: name command args...)
  local _claude_mcps=(
    "chrome-devtools bunx chrome-devtools-mcp@latest --autoConnect"
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
      # shellcheck disable=SC2034
      local mcp_args="${entry#* }"
      # shellcheck disable=SC2086
      claude mcp add -s user "$mcp_name" -- ${=mcp_args} 2>/dev/null || true
    fi
  done

  # Fix claude-in-chrome native host: use symlink so it survives version updates
  local _native_host="$HOME/.claude/chrome/chrome-native-host"
  local _claude_bin="$HOME/.local/bin/claude"
  if [[ -f "$_native_host" ]] && [[ -L "$_claude_bin" ]]; then
    local _current_target
    _current_target=$(grep -o 'exec "[^"]*"' "$_native_host" 2>/dev/null | sed 's/exec "//;s/"$//')
    local _symlink_target
    _symlink_target=$(readlink -f "$_claude_bin")
    if [[ "$_current_target" != "$_symlink_target" ]]; then
      echo " Fixing claude-in-chrome native host: $_current_target -> $_symlink_target"
      sed -i "s|exec \".*\"|exec \"$_symlink_target\"|" "$_native_host"
    else
      echo " Claude-in-chrome native host is up to date"
    fi
  fi
fi

# Fullscreen rendering: flicker-free alternate screen buffer with mouse support
# https://code.claude.com/docs/en/fullscreen
export CLAUDE_CODE_NO_FLICKER=1
export CLAUDE_CODE_NEW_INIT=1

alias c="claude --dangerously-skip-permissions --chrome"
alias cr="claude --dangerously-skip-permissions --chrome --resume"
alias cc="claude --dangerously-skip-permissions --chrome --channels plugin:discord@claude-plugins-official"
alias ccr="claude --dangerously-skip-permissions --chrome --channels plugin:discord@claude-plugins-official --resume"


