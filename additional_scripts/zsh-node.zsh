# zsh-node.zsh
# Node.js, NVM, pnpm configuration

# NVM setup - moved to a one of function, i don't use it all the time and was slow.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/ctowles/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# npm global packages installer function
function npm-install-global() {
  npm install --global  pnpm
  npm install --global @antfu/ni
  #https://github.com/sharkdp/fd 
  npm install --global fd-find
  npm install --global @towles/tool
}

export PATH="$HOME/.npm-global/bin:$PATH"

# Uncommented npm aliases (using @antfu/ni)
# alias s="nr start"
# alias d="nr dev"
# alias b="nr build"
# alias bw="nr build --watch"
# alias t="nr test"
# alias tw="nr test --watch"
# alias w="nr watch"

# alias lint="nr lint"
# alias lintf="nr lint --fix"
# alias release="nr release"

zsh_debug_section "Node/pnpm setup"