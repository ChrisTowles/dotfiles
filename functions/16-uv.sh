# uv - Fast Python package manager

# Setup: install uv
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v uv >/dev/null 2>&1; then
    echo " Installing uv..."
    case "$(uname -s)" in
      Darwin) brew install uv ;;
      Linux) curl -LsSf https://astral.sh/uv/install.sh | sh ;;
    esac
  fi

  # Generate zsh completions
  if command -v uv >/dev/null 2>&1; then
    echo " Generating uv completions..."
    mkdir -p ~/.zsh/completions
    uv generate-shell-completion zsh > ~/.zsh/completions/_uv
  fi
fi

# Add uv to PATH if installed to default location
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
