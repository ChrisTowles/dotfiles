# bun - JavaScript runtime & toolkit
# https://bun.sh

# Add bun to PATH (idempotent)
export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# tt-update - Pull and reinstall the tt CLI (Rust, crates-cli/tt-cli) from
# the primary checkout via cargo. Replaces the old `bun install --global
# @towles/tool` flow — that TS CLI was uninstalled at the ttr->tt cutover
# (2026-07-13, see towles-tool-rs docs/CUTOVER.md).
tt-update() {
  local repo="$HOME/code/p/towles-tool-repos/towles-tool-rs-primary"
  echo "tt $(tt --version 2>/dev/null || echo 'not installed')"
  git -C "$repo" pull --ff-only || { echo "git pull failed" >&2; return 1; }
  cargo install --path "$repo/crates-cli/tt-cli" --force || { echo "install failed" >&2; return 1; }
  echo "tt $(tt --version)"
}

# Install bun in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v bun >/dev/null 2>&1; then
    echo " Bun already installed: $(bun --version)"
  else
    echo " Installing bun..."
    curl -fsSL https://bun.sh/install | bash
  fi

  # Install repo dependencies (picocolors, etc.)
  bun install --cwd "${0:a:h}/.."

  # Generate zsh completions
  if command -v bun >/dev/null 2>&1; then
    echo " Generating bun completions..."
    bun completions > ~/.zsh/completions/_bun 2>/dev/null
  fi
fi
