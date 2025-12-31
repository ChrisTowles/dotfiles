#!/bin/zsh
# .zshrc - Interactive shell configuration
# Minimal orchestrator following mattmc3/zdotdir pattern

# Profiling support (use: zprofrc)
[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
alias zprofrc="ZPROFRC=1 zsh"

###############################
# Directory Setup
###############################

# Set directory variables (use ZDOTDIR from bootstrap)
ZSH_CONFIG_DIR="${ZDOTDIR:-$HOME/code/p/dotfiles}"
ZSH_DATA_DIR="${__zsh_user_data_dir:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh}"
ZSH_CACHE_DIR="${__zsh_cache_dir:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

# Ensure directories exist
mkdir -p "$ZSH_DATA_DIR" "$ZSH_CACHE_DIR"

# Essential options
setopt EXTENDED_GLOB INTERACTIVE_COMMENTS

# History configuration (XDG-compliant location)
HISTFILE="${ZSH_DATA_DIR}/history"

###############################
# Debug Timing (must be early)
###############################

zsh_start_time_total=$(date +%s.%N)
if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  zsh_debug_start_time=$(date +%s.%N)
  zsh_debug_section() {
    local current_time=$(date +%s.%N)
    local elapsed=$(echo "$current_time - $zsh_debug_start_time" | bc -l)
    echo -e "\033[1;33m⚠️  $(printf "DEBUG: %s took %.3f seconds" "$1" "$elapsed")\033[0m"
    zsh_debug_start_time=$current_time
  }
else
  zsh_debug_section() { : }
fi

###############################
# Load zstyles
###############################

[[ -r "$ZSH_CONFIG_DIR/.zstyles" ]] && source "$ZSH_CONFIG_DIR/.zstyles"

###############################
# Autoload Functions
###############################

# Source custom functions
for _fn in "$ZSH_CONFIG_DIR"/functions/*.sh(N); do
  source "$_fn"
done
unset _fn

# Add custom completions to fpath
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
fi

###############################
# Bootstrap Antidote
###############################

source "$ZSH_CONFIG_DIR/lib/antidote.zsh"

###############################
# Source conf.d Modules
###############################

# Source all conf.d modules alphabetically
# Files prefixed with ~ are skipped (disabled)
for _rc in "$ZSH_CONFIG_DIR"/conf.d/*.zsh(N); do
  [[ "${_rc:t}" != '~'* ]] || continue
  [[ -n "$ZSH_DEBUG_TIMING" ]] && echo -e "\033[0;36m  ↳ ${_rc:t}\033[0m"
  source "$_rc"
done
unset _rc

###############################
# Installer Aliases
###############################

alias zsh-setup='bash "$ZSH_CONFIG_DIR/setup.sh"'
alias zsh-install='zsh "$ZSH_CONFIG_DIR/install/install-deps.zsh"'
alias zsh-check-deps='zsh "$ZSH_CONFIG_DIR/install/check-deps.zsh"'

###############################
# Final Timing Report
###############################

if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  local current_time=$(date +%s.%N)
  local elapsed=$(echo "$current_time - $zsh_start_time_total" | bc -l)
  print_success "$(printf "Finished: Total time took %.3f seconds" "$elapsed")"
fi



###############################
# direnv Integration
###############################
eval "$(direnv hook zsh)"  # or bash


###############################
# Profiling Output
###############################

[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Never start in root filesystem
[[ "$PWD" != "/" ]] || cd

# Always return success
true
############### Anything after this auto added ################