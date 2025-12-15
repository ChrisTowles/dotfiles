#!/bin/zsh
# conf.d/40-node.zsh - Node.js, NVM, pnpm configuration

# Skip if no node tools
command -v node &>/dev/null || command -v pnpm &>/dev/null || [[ -d "$HOME/.nvm" ]] || return 0

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# pnpm (XDG-compliant location)
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# npm global packages path
export PATH="$HOME/.npm-global/bin:$PATH"

zsh_debug_section "Node/pnpm setup"
