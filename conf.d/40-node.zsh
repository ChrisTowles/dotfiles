#!/bin/zsh
# conf.d/40-node.zsh - Node.js, NVM, pnpm configuration

# Skip if no node tools
command -v node &>/dev/null || command -v pnpm &>/dev/null || [[ -d "$HOME/.nvm" ]] || return 0

# NVM lazy-loading (saves ~200-500ms on startup)
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  # Add default node to PATH without loading nvm
  [[ -d "$NVM_DIR/versions/node" ]] && PATH="$NVM_DIR/versions/node/$(ls -1 "$NVM_DIR/versions/node" | tail -1)/bin:$PATH"

  # Lazy-load nvm on first use
  nvm() {
    unfunction nvm node npm npx 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
  }
  node() { nvm --version >/dev/null 2>&1; node "$@"; }
  npm() { nvm --version >/dev/null 2>&1; npm "$@"; }
  npx() { nvm --version >/dev/null 2>&1; npx "$@"; }
fi

# pnpm (XDG-compliant location)
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# npm global packages path
export PATH="$HOME/.npm-global/bin:$PATH"

zsh_debug_section "Node/pnpm setup"
