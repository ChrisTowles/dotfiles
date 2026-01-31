#!/bin/zsh
# .zshrc - Interactive shell configuration
# Minimal orchestrator following mattmc3/zdotdir pattern

# Profiling support (use: zprofrc)
#[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
#alias zprofrc="ZPROFRC=1 zsh"

alias zsh-towles-setup="TOWLES_SETUP=1 exec zsh"

echo "TOWLES_SETUP is set to '${TOWLES_SETUP}'"

# Setup zsh-autosuggestions, meaning previous commands are suggested as you type
if [[ "$TOWLES_SETUP" -eq 1 ]] ; then
  echo "⚠️  Running zshrc in setup mode..."
  if [[ -d ~/.zsh/zsh-autosuggestions ]]; then
    echo " Updating zsh-autosuggestions..."
    git -C ~/.zsh/zsh-autosuggestions pull
  else
    echo " Installing from https://github.com/zsh-users/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  fi
fi

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


# Setup zsh-completions, providing many additional completion definitions
# try with "git -" and hit tab
if [[ "$TOWLES_SETUP" -eq 1 ]] ; then
  if [[ -d ~/.zsh/zsh-completions ]]; then
    echo " Updating zsh-completions..."
    git -C ~/.zsh/zsh-completions pull
  else
    echo " Installing from https://github.com/zsh-users/zsh-completions"
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
  fi
fi

fpath=(~/.zsh/zsh-completions/src $fpath)
################################################

# source zsh-syntax-highlighting.zsh

################################################
#   ZSH HISTORY SUBSTRING SEARCH               # 
################################################

# Setup zsh-history-substring-search
if [[ "$TOWLES_SETUP" -eq 1 ]] ; then
  if [[ -d ~/.zsh/zsh-history-substring-search ]]; then
    echo " Updating zsh-history-substring-search..."
    git -C ~/.zsh/zsh-history-substring-search pull
  else
    echo " Installing from https://github.com/zsh-users/zsh-history-substring-search"
    git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.zsh/zsh-history-substring-search
  fi
fi


source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# these are both up/down arrow keys, depending on terminal
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '\eOA' history-substring-search-up
bindkey '\eOB' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_FUZZY=1

################################################


# Initialize completions
autoload -Uz compinit && compinit

###############################
# History Configuration
###############################
HISTFILE=~/.zsh_history
HISTSIZE=50000                # Commands to keep in memory
SAVEHIST=50000                # Commands to save to file
setopt EXTENDED_HISTORY       # Save timestamp and duration
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming
setopt HIST_IGNORE_DUPS       # Don't record consecutive duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show command before executing from history
setopt INC_APPEND_HISTORY     # Write immediately, not on shell exit
setopt SHARE_HISTORY          # Share history between sessions



               



###############################
# Directory Setup
###############################

# Set directory variables (use ZDOTDIR from bootstrap)
#ZSH_CONFIG_DIR="${ZDOTDIR:-$HOME/code/p/dotfiles}"
#ZSH_DATA_DIR="${__zsh_user_data_dir:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh}"
#ZSH_CACHE_DIR="${__zsh_cache_dir:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

# Ensure directories exist
#mkdir -p "$ZSH_DATA_DIR" "$ZSH_CACHE_DIR"

# Essential options
#setopt EXTENDED_GLOB INTERACTIVE_COMMENTS

# History configuration (XDG-compliant location)
#HISTFILE="${ZSH_DATA_DIR}/history"

###############################
# Debug Timing (must be early)

# Debug alias - reload with timing
alias zsh-load='ZSH_DEBUG_TIMING=1 source ~/.zshrc'

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

#[[ -r "$ZSH_CONFIG_DIR/.zstyles" ]] && source "$ZSH_CONFIG_DIR/.zstyles"

###############################
# Autoload Functions
###############################

# Source custom functions
#for _fn in "$ZSH_CONFIG_DIR"/functions/*.sh(N); do
#  source "$_fn"
#done
#unset _fn

# Add custom completions to fpath
#if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
#  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
#fi

###############################
# Generate Tool Completions (before compinit)
###############################

# Ensure completions dir exists
#mkdir -p "$ZSH_CONFIG_DIR/completions"

# Cargo completions (via rustup)
#if command -v rustup &>/dev/null && [[ ! -f "$ZSH_CONFIG_DIR/completions/_cargo" ]]; then
#  rustup completions zsh cargo > "$ZSH_CONFIG_DIR/completions/_cargo" 2>/dev/null
#fi

###############################
# Source conf.d Modules
###############################

# Source all conf.d modules alphabetically
# Files prefixed with ~ are skipped (disabled)
#for _rc in "$ZSH_CONFIG_DIR"/conf.d/*.zsh(N); do
#  [[ "${_rc:t}" != '~'* ]] || continue
#  [[ -n "$ZSH_DEBUG_TIMING" ]] && echo -e "\033[0;36m  ↳ ${_rc:t}\033[0m"
#  source "$_rc"
#done
#unset _rc

###############################
# Installer Aliases
###############################

#alias zsh-setup='bash "$ZSH_CONFIG_DIR/setup.sh"'
#alias zsh-install='zsh "$ZSH_CONFIG_DIR/install/install-deps.zsh"'
#alias zsh-check-deps='zsh "$ZSH_CONFIG_DIR/install/check-deps.zsh"'

###############################
# Load Local File as needed. 
###############################

[[ -r "$HOME/.zshrc_local.sh" ]] && source "$HOME/.zshrc_local.sh"

###############################
# Starship Prompt
###############################

eval "$(starship init zsh)"

###############################
# Final Timing Report
###############################

if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  local current_time=$(date +%s.%N)
  local elapsed=$(echo "$current_time - $zsh_start_time_total" | bc -l)
  print_success "$(printf "Finished: Total time took %.3f seconds" "$elapsed")"
fi





###############################
# Profiling Output
###############################

#[[ "$ZPROFRC" -eq 1 ]] && zprof
#[[ -v ZPROFRC ]] && unset ZPROFRC




# Always return success
#true
############### Anything after this auto added ################

