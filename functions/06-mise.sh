# mise - polyglot tool version manager
# https://mise.jdx.dev
#
# Used here for the JDK (Android builds). Node stays on fnm - see functions/05-fnm.sh -
# so mise is deliberately not activated with `--shims` and will not fight over node.

# Add mise to PATH (idempotent)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Activate mise (sets up shims for tools listed in ~/.config/mise/config.toml)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Install mise in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v mise >/dev/null 2>&1; then
    echo " mise already installed: $(mise --version)"
  else
    echo " Installing mise..."
    curl -fsSL https://mise.run | sh
  fi

  if command -v mise >/dev/null 2>&1; then
    echo " Installing JDK 21 (Temurin) for Android builds..."
    mise use -g java@temurin-21

    echo " Generating mise completions..."
    mise completion zsh > ~/.zsh/completions/_mise
  fi
fi
