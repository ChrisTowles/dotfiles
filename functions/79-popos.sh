# Pop!_OS / COSMIC desktop setup
# Only runs on Pop!_OS — configures keyd, screenshot shortcuts, and desktop tools

_is_popos() {
  [[ "$(uname -s)" == "Linux" && -f /etc/os-release ]] && grep -qi "pop" /etc/os-release
}

_POPOS_DOTFILES_DIR="${0:a:h}/.."

if [[ "$DOTFILES_SETUP" -eq 1 ]] && _is_popos; then
  echo " Setting up Pop!_OS / COSMIC..."

  # ── keyd — system-level key remapping daemon ──
  # Swaps left Ctrl ↔ left Super so muscle memory transfers from macOS.
  # See config/keyd/default.conf for full details.
  if ! command -v keyd >/dev/null 2>&1; then
    # Prefer apt if the package exists (Ubuntu 24.04+ / some PPAs have it)
    if sudo apt-get install -y -qq keyd 2>/dev/null; then
      echo "  keyd installed via apt"
    else
      # Fall back to building from source — only needs git, make, and gcc
      echo "  keyd not in apt repos, building from source..."
      local tmp="/tmp/keyd-build"
      rm -rf "$tmp"
      git clone https://github.com/rvaiya/keyd "$tmp"
      make -C "$tmp"
      sudo make -C "$tmp" install
      rm -rf "$tmp"
      echo "  keyd built and installed from source"
    fi

    sudo systemctl enable keyd
    sudo systemctl start keyd
  fi

  # Deploy keyd config to /etc/keyd/ (requires root, so cp instead of symlink)
  local keyd_src="$_POPOS_DOTFILES_DIR/config/keyd/default.conf"
  if [[ -f "$keyd_src" ]]; then
    sudo mkdir -p /etc/keyd
    if ! diff -q "$keyd_src" /etc/keyd/default.conf &>/dev/null; then
      sudo cp "$keyd_src" /etc/keyd/default.conf
      sudo systemctl restart keyd
      echo "  keyd config updated and daemon restarted"
    fi
  fi

  # ── grim + slurp for direct area screenshots ──
  for pkg in grim slurp; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
      echo " Installing $pkg..."
      sudo apt install -y "$pkg"
    fi
  done

  # ── COSMIC custom keybindings ──
  if [[ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]]; then
    local shortcuts_dir="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
    local custom_file="$shortcuts_dir/custom"
    mkdir -p "$shortcuts_dir"

    # Ctrl+4 → area screenshot to clipboard (like macOS Cmd+Shift+4)
    if [[ ! -f "$custom_file" ]]; then
      echo " Creating COSMIC shortcuts with Ctrl+4 screenshot..."
      cat > "$custom_file" <<'EORON'
{
    (modifiers: [Ctrl], key: "4"): Spawn("bash -c 'grim -g \"$(slurp)\" - | wl-copy'"),
}
EORON
    elif ! grep -q 'key: "4"' "$custom_file"; then
      echo " Adding Ctrl+4 screenshot shortcut..."
      # Insert new binding before the closing }
      head -n -1 "$custom_file" > "${custom_file}.tmp"
      echo '    (modifiers: [Ctrl], key: "4"): Spawn("bash -c '\''grim -g \\\"$(slurp)\\\" - | wl-copy'\''"),' >> "${custom_file}.tmp"
      echo "}" >> "${custom_file}.tmp"
      mv "${custom_file}.tmp" "$custom_file"
    fi
  fi
fi

# Pop!_OS helper aliases (only defined on Pop!_OS)
if _is_popos; then
  # Area screenshot to clipboard
  screenshot-area() {
    grim -g "$(slurp)" - | wl-copy
    echo "Screenshot copied to clipboard"
  }

  # Full screen screenshot to clipboard
  screenshot-full() {
    grim - | wl-copy
    echo "Screenshot copied to clipboard"
  }

  # Area screenshot saved to file
  screenshot-save() {
    local dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    local file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
    grim -g "$(slurp)" "$file"
    echo "Screenshot saved to $file"
  }
fi
