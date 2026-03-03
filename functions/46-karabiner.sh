# karabiner - Karabiner-Elements keyboard remapping (macOS only)

# Setup: install Karabiner-Elements and symlink config
if [[ "$DOTFILES_SETUP" -eq 1 && "$(uname -s)" == "Darwin" ]]; then
  if ! brew list --cask karabiner-elements &>/dev/null; then
    echo " Installing Karabiner-Elements..."
    brew install --cask karabiner-elements
  fi

  local config_src="${0:a:h}/../config/karabiner"
  local config_dest="$HOME/.config/karabiner"
  if [[ -d "$config_src" ]]; then
    # Back up existing config if it's a real directory (not a symlink)
    if [[ -d "$config_dest" && ! -L "$config_dest" ]]; then
      echo " Backing up existing karabiner config..."
      mv "$config_dest" "$config_dest.$(date +%Y%m%d).bak"
    fi
    echo " Linking karabiner config..."
    ln -sf "$config_src" "$config_dest"
  fi
fi
