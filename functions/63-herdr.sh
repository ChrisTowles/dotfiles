# herdr - terminal workspace manager for AI coding agents
# https://herdr.dev

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v herdr >/dev/null 2>&1; then
    case "$(uname -s)" in
      Darwin) echo " Updating herdr (brew)..."; brew upgrade herdr 2>/dev/null || true ;;
      Linux)  echo " Updating herdr..."; herdr update 2>/dev/null || true ;;
    esac
  else
    echo " Installing herdr..."
    case "$(uname -s)" in
      Darwin) brew install herdr ;;
      Linux)  curl -fsSL https://herdr.dev/install.sh | sh ;;
    esac
  fi

  # Generate zsh completions
  if command -v herdr >/dev/null 2>&1; then
    echo " Generating herdr completions..."
    herdr completion zsh > ~/.zsh/completions/_herdr
  fi
fi
