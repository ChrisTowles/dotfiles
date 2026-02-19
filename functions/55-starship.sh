# starship - Cross-shell prompt configuration

STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"

# Setup starship config with git metrics enabled
_starship_setup_config() {
  mkdir -p "$(dirname "$STARSHIP_CONFIG_FILE")"

  cat > "$STARSHIP_CONFIG_FILE" << 'EOF'
# Starship Configuration
# https://starship.rs/config/

# Module order - put git_status before git_metrics
format = """$directory$git_branch$git_status$git_metrics$all"""

# Git status - file count (dim)
[git_status]
style = 'dimmed'
format = '([· $modified]($style) )'
modified = '$count files'
staged = ''
untracked = ''
deleted = ''
renamed = ''
conflicted = ''

# Git metrics - lines added/deleted
[git_metrics]
disabled = false
added_style = 'green'
deleted_style = 'red'
format = '([+$added]($added_style) )([-$deleted]($deleted_style) )'
EOF

  echo "Starship config written to $STARSHIP_CONFIG_FILE"
}

# Install/update starship in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v starship >/dev/null 2>&1; then
    echo " Starship already installed: $(starship --version)"
  else
    echo " Installing starship..."
    cargo install starship
  fi
  _starship_setup_config

  # Generate zsh completions
  echo " Generating starship completions..."
  mkdir -p ~/.zsh/completions
  starship completions zsh > ~/.zsh/completions/_starship
fi

# Initialize starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Alias to regenerate config
alias starship-setup='_starship_setup_config'
