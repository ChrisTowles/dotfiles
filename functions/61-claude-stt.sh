# Claude STT — speech-to-text plugin for Claude Code
# Uses ChrisTowles/claude-stt fork (feature/claude-text-improvement branch)
# Not registered as a Claude Code plugin — the plugin uses python/python3 directly
# instead of uv, so the SessionStart hook fails. We manage the daemon via shell commands instead.

_CLAUDE_STT_DIR="$HOME/code/f/claude-stt"

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if [[ "$(uname -s)" == "Linux" ]]; then
    # System deps: audio backend, build deps, text injection
    for pkg in libportaudio2 portaudio19-dev python3-dev xdotool ydotool wtype libnotify-bin; do
      if ! dpkg -s "$pkg" &>/dev/null; then
        echo " Installing $pkg..."
        sudo apt install -y "$pkg"
      fi
    done

    # Ensure user is in 'input' group for global hotkey access
    if ! groups "$USER" | grep -qw input; then
      echo " Adding $USER to input group (required for hotkey listener)..."
      sudo usermod -aG input "$USER"
      echo " NOTE: Log out and back in for the group change to take effect."
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if ! brew list portaudio &>/dev/null; then
      echo " Installing portaudio..."
      brew install portaudio
    fi
  fi

  # Clone or update the fork
  if [[ ! -d "$_CLAUDE_STT_DIR" ]]; then
    echo " Cloning claude-stt fork..."
    git clone -b feature/claude-text-improvement https://github.com/ChrisTowles/claude-stt.git "$_CLAUDE_STT_DIR"
  else
    echo " Updating claude-stt fork..."
    git -C "$_CLAUDE_STT_DIR" pull --ff-only 2>/dev/null || true
  fi

  # Install Python dependencies via uv
  if command -v uv >/dev/null 2>&1; then
    echo " Syncing claude-stt Python deps..."
    uv sync --directory "$_CLAUDE_STT_DIR" 2>/dev/null || true
  fi

  # Symlink config into plugin directory
  local config_src="${0:a:h}/../config/claude-stt/config.toml"
  local config_dir="$HOME/.config/claude-stt"
  mkdir -p "$config_dir"
  ln -sf "$config_src" "$config_dir/config.toml"
fi

# Shell commands for managing the daemon
stt-start() {
  echo "Starting claude-stt daemon in background..."
  uv run --directory "$_CLAUDE_STT_DIR" python -m claude_stt.daemon start --background
}

stt-stop() {
  echo "Stopping claude-stt daemon..."
  uv run --directory "$_CLAUDE_STT_DIR" python -m claude_stt.daemon stop
}

stt-status() {
  echo "Checking claude-stt daemon status..."
  uv run --directory "$_CLAUDE_STT_DIR" python -m claude_stt.daemon status
}

stt-run() {
  echo "Running claude-stt daemon in foreground (Ctrl+C to stop)..."
  uv run --directory "$_CLAUDE_STT_DIR" python -m claude_stt.daemon run
}
