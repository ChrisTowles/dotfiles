# cliphist - Wayland clipboard manager with image support
# Requires: wl-clipboard, wofi, xdg-utils

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  # Dependencies (Linux only)
  if [[ "$(uname -s)" == "Linux" ]]; then
    for pkg in wl-clipboard wofi xdg-utils; do
      if ! dpkg -s "$pkg" &>/dev/null; then
        echo " Installing $pkg..."
        sudo apt install -y "$pkg"
      fi
    done

    # Install cliphist binary
    if ! command -v cliphist >/dev/null 2>&1; then
      echo " Installing cliphist..."
      gh release download --repo sentriz/cliphist --pattern "*-linux-amd64" -D /tmp --clobber
      sudo install /tmp/*-linux-amd64 /usr/local/bin/cliphist
      rm /tmp/*-linux-amd64
    fi

    # Autostart: wl-paste --watch cliphist store
    local autostart_dir="$HOME/.config/autostart"
    mkdir -p "$autostart_dir"
    if [[ ! -f "$autostart_dir/cliphist.desktop" ]]; then
      echo " Adding cliphist to autostart..."
      cat > "$autostart_dir/cliphist.desktop" <<'EOF'
[Desktop Entry]
Name=Cliphist
Comment=Clipboard history for Wayland
Exec=wl-paste --watch cliphist store
Type=Application
X-GNOME-Autostart-enabled=true
EOF
    fi

    # COSMIC shortcut: Alt+` to open clipboard picker
    if [[ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]]; then
      local shortcuts_dir="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
      mkdir -p "$shortcuts_dir"
      if [[ ! -f "$shortcuts_dir/custom" ]] || ! grep -q "cliphist" "$shortcuts_dir/custom"; then
        echo " Adding Alt+\` shortcut for cliphist..."
        cat > "$shortcuts_dir/custom" <<'EOF'
{
    (modifiers: [Alt], key: "grave"): Spawn("bash -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'"),
}
EOF
      fi
    fi
  fi
fi

# Clipboard picker (Alt+` via COSMIC shortcut, or run manually)
cliphist-pick() {
  cliphist list | wofi --dmenu | cliphist decode | wl-copy
}

# Delete items from history
cliphist-delete() {
  cliphist list | wofi --dmenu | cliphist delete
}
