# Ghostty terminal emulator setup
# https://ghostty.org

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v ghostty >/dev/null 2>&1 && [[ ! -d "/Applications/Ghostty.app" ]]; then
    echo " Installing Ghostty..."
    case "$(uname -s)" in
      Darwin) brew install --cask ghostty ;;
      Linux)
        if ! grep -q "mkasberg/ghostty-ubuntu" /etc/apt/sources.list.d/*.list 2>/dev/null; then
          sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
        fi
        sudo apt-get update -qq
        sudo apt-get install -y -qq ghostty
        ;;
    esac
  fi

  local config_src="${0:a:h}/../config/ghostty/config"
  if [[ -f "$config_src" ]]; then
    echo " Linking Ghostty config..."
    local config_dir
    if [[ "$(uname)" == "Darwin" ]]; then
      config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
    else
      config_dir="$HOME/.config/ghostty"
    fi
    mkdir -p "$config_dir"
    ln -sf "$config_src" "$config_dir/config"
  fi
fi

# ghostty-help - Print Ghostty tips and workarounds
ghostty-help() {
  echo "\033[1;36mGhostty keybindings:\033[0m"
  echo "  Cmd+Shift+Click    Open URL (required inside tmux)"
  echo "  Cmd+Click          Open URL (only works outside tmux)"
  echo "  Cmd+D              Split right"
  echo "  Cmd+Shift+D        Split down"
  echo "  Cmd+Shift+Enter    Toggle fullscreen"
  echo "  Cmd+Shift+,        Open config"
  echo ""
  echo "\033[1;36mConfig:\033[0m"
  echo "  copy-on-select = clipboard  (selecting text copies it automatically)"
  echo ""
  echo "\033[1;36mKnown issues:\033[0m"
  echo "  Right-click menu in tmux is broken (follows cursor)"
  echo "    https://github.com/ghostty-org/ghostty/discussions/5362"
  echo "  Cmd+Click in tmux requires Shift workaround"
  echo "    https://github.com/ghostty-org/ghostty/issues/11573"
}
