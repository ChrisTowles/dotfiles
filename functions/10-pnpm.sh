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

# Complete package.json script names for nr (@antfu/ni script runner)
_nr_scripts() {
  [[ -f package.json ]] || return 0
  local -a scripts
  # _describe splits entries on the first unescaped colon, so escape colons in
  # script names (claude:setup) and strip them from the command shown as the desc
  # shellcheck disable=SC2296,SC2206,SC2034  # zsh ${(f)...} line-split; scripts is read by _describe
  scripts=(${(f)"$(jq -r '.scripts // {} | to_entries[] | (.key | gsub(":"; "\\:")) + ":" + (.value | gsub(":"; " "))' package.json 2>/dev/null)"})
  _describe -t scripts 'package.json script' scripts
}
compdef _nr_scripts nr
