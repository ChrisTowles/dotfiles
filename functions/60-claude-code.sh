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
      # https://github.com/aaddrick/claude-desktop-debian
      local _claude_keyring="/usr/share/keyrings/claude-desktop.gpg"
      local _claude_sources="/etc/apt/sources.list.d/claude-desktop.list"
      local _claude_repo_url="https://pkg.claude-desktop-debian.dev"
      local _claude_sources_line="deb [signed-by=$_claude_keyring arch=amd64,arm64] $_claude_repo_url stable main"

      if [[ ! -f "$_claude_keyring" ]]; then
        echo " Adding Claude Desktop GPG key..."
        curl -fsSL "$_claude_repo_url/KEY.gpg" | sudo gpg --dearmor -o "$_claude_keyring"
      fi

      if [[ "$(cat "$_claude_sources" 2>/dev/null)" != "$_claude_sources_line" ]]; then
        echo " Writing Claude Desktop apt source ($_claude_repo_url)..."
        echo "$_claude_sources_line" | sudo tee "$_claude_sources" >/dev/null
      fi

      echo " Updating Claude Desktop (apt)..."
      sudo apt update -qq && sudo apt install -y claude-desktop 2>/dev/null || true
    fi
  fi

  # Configure marketplaces, settings, CLAUDE.md, plugins, rules, MCP servers,
  # and the claude-in-chrome native host (see config/claude/setup-settings.ts).
  bun run "${0:a:h}/../config/claude/setup-settings.ts"
  echo " Claude Code configured (settings, CLAUDE.md, plugins, rules, MCP)"
fi

# Fullscreen rendering: flicker-free alternate screen buffer with mouse support
# https://code.claude.com/docs/en/fullscreen
export CLAUDE_CODE_NO_FLICKER=1
export CLAUDE_CODE_NEW_INIT=1

alias c="claude --dangerously-skip-permissions --chrome"
alias cr="claude --dangerously-skip-permissions --chrome --resume"
alias ca="claude --dangerously-skip-permissions --chrome agents"
alias cc="claude --dangerously-skip-permissions --chrome --channels plugin:discord@claude-plugins-official"
alias ccr="claude --dangerously-skip-permissions --chrome --channels plugin:discord@claude-plugins-official --resume"


