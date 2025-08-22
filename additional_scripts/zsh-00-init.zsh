# zsh-00-init.zsh
# Core initialization, colors, and utility functions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
  echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
  exit 1
}

# Debug timing
zsh_start_time_total=$(date +%s.%N)

# Debug timing functions
if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
    zsh_debug_start_time=$(date +%s.%N)
    zsh_debug_section() {
        local current_time=$(date +%s.%N)
        local elapsed=$(echo "$current_time - $zsh_debug_start_time" | bc -l)
        print_warning "$(printf "DEBUG: %s took %.3f seconds" "$1" "$elapsed")"
        zsh_debug_start_time=$current_time
    }
else
    zsh_debug_section() { : }
fi

# Debug alias
alias zsh-load='export ZSH_DEBUG_TIMING=1 && source ~/.zshrc && export ZSH_DEBUG_TIMING=0'

# Basic environment setup
export ZSH="$HOME/.oh-my-zsh"
HISTSIZE=50000
SAVEHIST=50000

# Fix issue where `ls` didn't have colors
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

zsh_debug_section "Initial setup"