#!/bin/zsh
# conf.d/00-init.zsh - Core initialization, colors, and utility functions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() { echo -e "${BLUE}🔧 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Debug alias - reload with timing
alias zsh-load='ZSH_DEBUG_TIMING=1 source ~/.zshrc'

# History settings
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Sync across sessions
setopt HIST_IGNORE_DUPS       # Skip consecutive dupes
setopt HIST_IGNORE_ALL_DUPS   # Remove older dupes
setopt HIST_IGNORE_SPACE      # Ignore space-prefixed cmds
setopt HIST_REDUCE_BLANKS     # Strip whitespace
setopt INC_APPEND_HISTORY     # Append immediately

# Fix issue where `ls` didn't have colors
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

print_success "Loading Chris's Modular ZSH Profile"
zsh_debug_section "Initial setup"
