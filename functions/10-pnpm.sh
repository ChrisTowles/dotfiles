# pnpm - Fast, disk space efficient package manager
# pnpm is provided by corepack (enabled in 05-fnm.sh), no standalone install needed

# Add pnpm global bin to PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

pnpm-install-global() {
  pnpm install --global \
    tsx `# TypeScript execute - run .ts files directly` \
    @antfu/ni `# Unified package manager runner (ni, nr, nu)`
}

if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  if ! command -v pnpm >/dev/null 2>&1; then
    echo " pnpm not found — ensure corepack is enabled (corepack enable)"
  else
    echo " pnpm already installed (via corepack): $(pnpm --version)"
  fi
  echo " Installing global pnpm packages..."
  pnpm-install-global

  # Generate zsh completions
  echo " Generating pnpm completions..."
  pnpm completion zsh > ~/.zsh/completions/_pnpm
fi
