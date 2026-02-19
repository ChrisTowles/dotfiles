# Rust / Cargo setup
# https://rustup.rs

# Add cargo to PATH (idempotent)
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) ;;
  *) export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v rustc >/dev/null 2>&1; then
    echo " Rust already installed: $(rustc --version)"
  else
    echo " Installing Rust via rustup..."
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi

  # Generate zsh completions
  if command -v rustup >/dev/null 2>&1; then
    echo " Generating rustup completions..."
    mkdir -p ~/.zsh/completions
    rustup completions zsh > ~/.zsh/completions/_rustup
    rustup completions zsh cargo > ~/.zsh/completions/_cargo
  fi
fi
