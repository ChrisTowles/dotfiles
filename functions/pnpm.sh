# pnpm - Fast, disk space efficient package manager

# Add pnpm to PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

pnpm-install() {
  curl -fsSL https://get.pnpm.io/install.sh | sh -
}

pnpm-install-global() {
  pnpm install --global tsx
  pnpm install --global @antfu/ni
  pnpm install --global fd-find
  pnpm install --global @towles/tool
}

if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  if ! command -v pnpm >/dev/null 2>&1; then
    echo " Installing pnpm..."
    pnpm-install
  else
    echo " pnpm already installed"
  fi
  echo " Installing global pnpm packages..."
  pnpm-install-global
fi