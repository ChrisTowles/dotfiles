# Pop!_OS / COSMIC desktop setup
# Only runs on Pop!_OS — configures keyd, screenshot shortcuts, and desktop tools

# Cache Pop!_OS detection (avoids re-reading /etc/os-release on every shell start)
if [[ "$_DOTFILES_OS" == "Linux" && -f /etc/os-release ]] && grep -qi "pop" /etc/os-release; then
  _IS_POPOS=true
else
  _IS_POPOS=false
fi

_POPOS_DOTFILES_DIR="${0:a:h}/.."

if [[ "$DOTFILES_SETUP" -eq 1 ]] && $_IS_POPOS; then
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

  # ── COSMIC custom keybindings ──
  # Overwrites custom shortcuts file with our desired bindings:
  #   Ctrl+`           → cliphist picker (clipboard manager via wofi)
  #   Ctrl+Shift+4     → cosmic-screenshot (like macOS Cmd+Shift+4)
  #   Ctrl+Shift+Space → claude-sst-toggle (speech-to-text)
  if [[ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]]; then
    local shortcuts_dir="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
    local custom_file="$shortcuts_dir/custom"
    local custom_src="$_POPOS_DOTFILES_DIR/config/cosmic/custom"
    mkdir -p "$shortcuts_dir"

    # The tracked template uses a literal $HOME — COSMIC's Spawn does not expand
    # it, so substitute the real path before writing.
    if [[ -f "$custom_src" ]]; then
      local template desired
      template=$(cat "$custom_src")
      desired="${template//\$HOME/$HOME}"
      if [[ ! -f "$custom_file" ]] || [[ "$(cat "$custom_file")" != "$desired" ]]; then
        echo "  Updating COSMIC custom shortcuts..."
        echo "$desired" > "$custom_file"
      fi
    fi
  fi
fi

# Pop!_OS helper aliases (only defined on Pop!_OS)
if $_IS_POPOS; then
  # Interactive screenshot (opens COSMIC screenshot tool)
  screenshot() {
    cosmic-screenshot --interactive
  }

  # Full screen screenshot saved to ~/Pictures/Screenshots
  screenshot-full() {
    local dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    cosmic-screenshot --interactive=false --save-dir "$dir"
  }

  # Restart COSMIC desktop (restarts display manager, will log you out)
  popos-restart-desktop() {
    echo "This will restart the display manager and LOG YOU OUT."
    # shellcheck disable=SC2162
    read -q "?Are you sure? [y/N] " || { echo; return 1; }
    echo
    sudo systemctl restart cosmic-greeter
  }
fi
