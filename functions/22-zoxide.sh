# zoxide - Smarter cd replacement (replaces zsh-z)
# Commands: z <query> (smart cd), zi (interactive with fzf)

# Setup: install zoxide and seed with project directories
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v zoxide >/dev/null 2>&1; then
    echo " Installing zoxide..."
    cargo install zoxide
  fi

  # Seed zoxide database with project directories
  if command -v zoxide >/dev/null 2>&1; then
    for dir in ~/code/p ~/code/w ~/code/f; do
      [[ -d "$dir" ]] && zoxide add "$dir"
    done
  fi

  # Remove old zsh-z if present
  if [[ -d ~/.zsh/zsh-z ]]; then
    echo " Removing old zsh-z (replaced by zoxide)..."
    rm -rf ~/.zsh/zsh-z
  fi
fi

# Initialize zoxide with interactive tab completion
# --cmd z: keeps the familiar `z` command name
# Tab completion on `z <query><tab>` shows ranked matches (like old z plugin)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd z)"
fi
