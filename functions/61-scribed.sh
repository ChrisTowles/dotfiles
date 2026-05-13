# scribed — local streaming dictation daemon (Parakeet ASR via sherpa-onnx).
# Rust port of claude-stt. Repo lives at ~/code/p/scribed.

_SCRIBED_DIR="$HOME/code/p/scribed"

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if [[ "$(uname -s)" == "Linux" ]]; then
    # Build deps + Wayland/X11 keystroke injection backends.
    for pkg in libasound2-dev libdbus-1-dev ydotool xdotool; do
      if ! dpkg -s "$pkg" &>/dev/null; then
        echo " Installing $pkg..."
        sudo apt install -y "$pkg"
      fi
    done

    # scribed reads /dev/input/event* directly for the global hotkey; membership
    # in 'input' is required and a relog is needed for the change to take effect.
    if ! groups "$USER" | grep -qw input; then
      echo " Adding $USER to input group (required for hotkey listener)..."
      sudo usermod -aG input "$USER"
      echo " NOTE: Log out and back in for the group change to take effect."
    fi
  fi

  _git_clone_or_pull "https://github.com/ChrisTowles/scribed.git" "$_SCRIBED_DIR"

  # Canonical install (cargo build + bin + sidecar libs into ~/.cargo/bin/).
  if [[ -x "$_SCRIBED_DIR/scripts/install.sh" ]]; then
    echo " Installing scribed (cargo build + libs)..."
    "$_SCRIBED_DIR/scripts/install.sh"
  fi

  # Wayland prerequisites: ydotoold user service + /dev/uinput access.
  if [[ "$(uname -s)" == "Linux" ]]; then
    local _ydoto_unit="/etc/systemd/user/ydotoold.service"
    local _ydoto_src="$_SCRIBED_DIR/docs/ydotoold.service"
    if [[ -f "$_ydoto_src" ]] && ! cmp -s "$_ydoto_src" "$_ydoto_unit" 2>/dev/null; then
      echo " Installing ydotoold systemd user unit..."
      sudo install -m 0644 "$_ydoto_src" "$_ydoto_unit"
      systemctl --user daemon-reload
      systemctl --user enable --now ydotoold 2>/dev/null || true
    fi

    local _uinput_rule="/etc/udev/rules.d/99-uinput.rules"
    local _uinput_src="$_SCRIBED_DIR/docs/99-uinput.rules"
    if [[ -f "$_uinput_src" ]] && ! cmp -s "$_uinput_src" "$_uinput_rule" 2>/dev/null; then
      echo " Installing /dev/uinput udev rule..."
      sudo install -m 0644 "$_uinput_src" "$_uinput_rule"
      sudo udevadm control --reload-rules
      sudo udevadm trigger
    fi
  fi

  # Symlink the tracked config into ~/.config/scribed/.
  local config_src="${0:a:h}/../config/scribed/config.toml"
  local config_dir="$HOME/.config/scribed"
  mkdir -p "$config_dir"
  ln -sf "$config_src" "$config_dir/config.toml"
fi
