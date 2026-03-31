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
fi
