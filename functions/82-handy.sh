# Handy — free, open source, offline speech-to-text app (Tauri v2)
# https://github.com/cjpais/Handy

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  case "$(uname -s)" in
    Darwin)
      if [[ ! -d "/Applications/Handy.app" ]]; then
        echo " Installing Handy..."
        brew install --cask handy
      fi
      ;;
    Linux)
      if ! command -v handy >/dev/null 2>&1; then
        echo " Installing Handy..."
        gh release download --repo cjpais/Handy --pattern "*_amd64.deb" -D /tmp --clobber
        sudo apt install -y /tmp/Handy_*_amd64.deb
        rm -f /tmp/Handy_*_amd64.deb
      fi

      # wtype: Wayland text-input backend (Handy falls back to unreliable enigo without it).
      # libgtk-layer-shell0: runtime dep Handy links against on Linux.
      for pkg in wtype libgtk-layer-shell0; do
        if ! dpkg -s "$pkg" &>/dev/null; then
          echo " Installing $pkg..."
          sudo apt install -y "$pkg"
        fi
      done
      ;;
  esac
fi
