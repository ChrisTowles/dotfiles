# zoxide - Smarter cd replacement that learns from usage
# https://github.com/ajeetdsouza/zoxide

# Setup: install zoxide
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v zoxide >/dev/null 2>&1; then
    echo " Installing zoxide..."
    cargo install zoxide
  fi
fi

# Initialize zoxide (provides z and zi commands)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
