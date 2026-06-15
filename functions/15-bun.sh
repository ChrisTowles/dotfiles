# bun - JavaScript runtime & toolkit
# https://bun.sh

# Add bun to PATH (idempotent)
export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# tt-update - Install latest @towles/tool globally and restart agentboard
tt-update() {
  echo "tt $(tt --version 2>/dev/null || echo 'not installed')"
  bun install --global @towles/tool@latest || { echo "install failed" >&2; return 1; }
  echo "tt $(tt --version)"
  if pgrep -f "agentboard server" >/dev/null 2>&1; then
    echo "restarting agentboard..."
    tt agentboard restart
  fi
}

# Install bun in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v bun >/dev/null 2>&1; then
    echo " Bun already installed: $(bun --version)"
  else
    echo " Installing bun..."
    curl -fsSL https://bun.sh/install | bash
  fi

  # Install repo dependencies (picocolors, etc.)
  bun install --cwd "${0:a:h}/.."

  # Install @towles/tool globally
  echo " Installing @towles/tool..."
  if ! bun install --global @towles/tool; then
    echo " ⚠️  @towles/tool install FAILED — tt not updated (still $(tt --version 2>/dev/null || echo 'not installed'))" >&2
  fi

  # Generate zsh completions
  if command -v bun >/dev/null 2>&1; then
    echo " Generating bun completions..."
    bun completions > ~/.zsh/completions/_bun 2>/dev/null
  fi
fi
