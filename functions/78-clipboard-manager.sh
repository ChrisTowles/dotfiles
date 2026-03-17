# shellcheck disable=SC1036,SC1046,SC1047,SC1072,SC1073,SC1009
# Clipboard manager — cliphist (Linux/Wayland) / Maccy (macOS)

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if [[ "$(uname -s)" == "Linux" ]]; then
    # ── Linux: cliphist + wofi with image previews ──
    # Requires: wl-clipboard, wofi, xdg-utils, gawk, imagemagick, ripgrep
    for pkg in wl-clipboard wofi xdg-utils wtype gawk imagemagick ripgrep; do
      if ! dpkg -s "$pkg" &>/dev/null; then
        echo " Installing $pkg..."
        sudo apt install -y "$pkg"
      fi
    done

    # Install cliphist binary
    if ! command -v cliphist >/dev/null 2>&1; then
      echo " Installing cliphist..."
      rm -f /tmp/*-linux-amd64(N)
      gh release download --repo sentriz/cliphist --pattern "*-linux-amd64" -D /tmp
      sudo install /tmp/*-linux-amd64 /usr/local/bin/cliphist
      rm -f /tmp/*-linux-amd64(N)
    fi

    # Install cliphist-wofi-img helper (official contrib script, patched for ImageMagick 6)
    if [[ ! -f /usr/local/bin/cliphist-wofi-img ]]; then
      echo " Installing cliphist-wofi-img..."
      curl -fsSL https://raw.githubusercontent.com/sentriz/cliphist/master/contrib/cliphist-wofi-img \
        -o /tmp/cliphist-wofi-img
      # Upstream uses `magick` (ImageMagick 7), Ubuntu ships `convert` (ImageMagick 6)
      sed -i 's/magick - -resize/convert - -resize/g' /tmp/cliphist-wofi-img
      chmod +x /tmp/cliphist-wofi-img
      sudo install /tmp/cliphist-wofi-img /usr/local/bin/cliphist-wofi-img
      rm /tmp/cliphist-wofi-img
    fi

    # Autostart: wl-paste --watch cliphist store (text)
    local autostart_dir="$HOME/.config/autostart"
    mkdir -p "$autostart_dir"
    if [[ ! -f "$autostart_dir/cliphist.desktop" ]]; then
      echo " Adding cliphist to autostart..."
      cat > "$autostart_dir/cliphist.desktop" <<'EOF'
[Desktop Entry]
Name=Cliphist
Comment=Clipboard history for Wayland (text)
Exec=wl-paste --watch cliphist store
Type=Application
X-GNOME-Autostart-enabled=true
EOF
    fi

    # Autostart: wl-paste --type image --watch cliphist store (images)
    if [[ ! -f "$autostart_dir/cliphist-image.desktop" ]]; then
      echo " Adding cliphist image watcher to autostart..."
      cat > "$autostart_dir/cliphist-image.desktop" <<'EOF'
[Desktop Entry]
Name=Cliphist Image
Comment=Clipboard history for Wayland (images)
Exec=wl-paste --type image --watch cliphist store
Type=Application
X-GNOME-Autostart-enabled=true
EOF
    fi

    # COSMIC shortcut for cliphist is managed in 79-popos.sh (Ctrl+`)

  elif [[ "$(uname -s)" == "Darwin" ]]; then
    # ── macOS: Maccy ──
    local maccy_app="/Applications/Maccy.app"
    if ! brew list --cask maccy &>/dev/null && [[ ! -d "$maccy_app" ]]; then
      echo " Installing Maccy..."
      brew install --cask maccy
    fi
  fi
fi

# ── Linux helpers ──
if [[ "$(uname -s)" == "Linux" ]]; then
  # Clipboard picker with image previews (Ctrl+` via COSMIC shortcut, or run manually)
  cliphist-pick() {
    cliphist-wofi-img | wl-copy
  }

  # Delete items from history
  cliphist-delete() {
    cliphist list | wofi --dmenu | cliphist delete
  }
fi
