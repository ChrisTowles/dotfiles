# bun - JavaScript runtime & toolkit
# https://bun.sh

# Add bun to PATH (idempotent)
export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# Install bun in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v bun >/dev/null 2>&1; then
    echo " Bun already installed: $(bun --version)"
  else
    echo " Installing bun..."
    curl -fsSL https://bun.sh/install | bash
  fi
fi
