# fnm - Fast Node Manager
# https://github.com/Schniz/fnm

# Add fnm to PATH (idempotent)
export FNM_PATH="$HOME/.local/share/fnm"
case ":$PATH:" in
  *":$FNM_PATH:"*) ;;
  *) export PATH="$FNM_PATH:$PATH" ;;
esac

# Initialize fnm (sets up node/npm shims, auto-use on cd)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Install fnm in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v fnm >/dev/null 2>&1; then
    echo " fnm already installed: $(fnm --version)"
  else
    echo " Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  fi
  # Install latest LTS node
  if command -v fnm >/dev/null 2>&1; then
    echo " Installing latest LTS Node.js..."
    fnm install --lts
    fnm default lts-latest
  fi

  # Generate zsh completions
  if command -v fnm >/dev/null 2>&1; then
    echo " Generating fnm completions..."
    mkdir -p ~/.zsh/completions
    fnm completions --shell zsh > ~/.zsh/completions/_fnm
  fi
fi
