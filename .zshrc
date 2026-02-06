#!/bin/zsh
# .zshrc - Interactive shell configuration
# Minimal orchestrator following mattmc3/zdotdir pattern



DOTFILES_DIR="$HOME/code/p/dotfiles"

alias ls='ls -al'
export EDITOR="code-insiders"
export VISUAL="$EDITOR"

# Profiling support (use: zprofrc)
#[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
#alias zprofrc="ZPROFRC=1 zsh"

alias zsh-dotfiles-setup="DOTFILES_SETUP=1 exec zsh"

if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  echo "⚠️  Running zshrc in setup mode..."
fi



###############################
# Debug Timing (must be early)

# Debug alias - reload with timing
alias zsh-load='ZSH_DEBUG_TIMING=1 exec zsh'

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



################################################
#   zsh-autosuggestions                          # 
################################################


# meaning previous commands are suggested as you type
if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
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
zsh_debug_section "zsh-autosuggestions"

################################################
#   zsh-completions                            # 
################################################

# providing many additional completion definitions
# try with "git -" and hit tab
if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  if [[ -d ~/.zsh/zsh-completions ]]; then
    echo " Updating zsh-completions..."
    git -C ~/.zsh/zsh-completions pull
  else
    echo " Installing from https://github.com/zsh-users/zsh-completions"
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
  fi
fi

fpath=(~/.zsh/zsh-completions/src $fpath)

# Rust/Cargo completions
if command -v rustc >/dev/null 2>&1; then
  fpath=("$(rustc --print sysroot)/share/zsh/site-functions" $fpath)
fi

# Generated completions
mkdir -p ~/.zsh/completions
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  echo " Generating tool completions..."
  command -v zellij >/dev/null && zellij setup --generate-completion zsh > ~/.zsh/completions/_zellij
  command -v docker >/dev/null && docker completion zsh > ~/.zsh/completions/_docker
  command -v gh >/dev/null && gh completion -s zsh > ~/.zsh/completions/_gh
  command -v npm >/dev/null && npm completion > ~/.zsh/completions/_npm
  command -v pnpm >/dev/null && pnpm completion zsh > ~/.zsh/completions/_pnpm
  command -v rustup >/dev/null && rustup completions zsh > ~/.zsh/completions/_rustup
  command -v uv >/dev/null && uv generate-shell-completion zsh > ~/.zsh/completions/_uv
  command -v bun >/dev/null && bun completions > ~/.zsh/completions/_bun
  # aws uses a completer binary, not a generated file
  if command -v aws_completer >/dev/null; then
    echo "autoload -Uz bashcompinit && bashcompinit\ncomplete -C aws_completer aws" > ~/.zsh/completions/_aws
  fi
fi
fpath=(~/.zsh/completions $fpath)

# gcloud completions (installed by gcloud SDK)
[[ -f ~/google-cloud-sdk/completion.zsh.inc ]] && source ~/google-cloud-sdk/completion.zsh.inc

zsh_debug_section "zsh-completions"

################################################
#   ZSH HISTORY SUBSTRING SEARCH               # 
################################################


if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  if [[ -d ~/.zsh/zsh-history-substring-search ]]; then
    echo " Updating zsh-history-substring-search..."
    git -C ~/.zsh/zsh-history-substring-search pull
  else
    echo " Installing from https://github.com/zsh-users/zsh-history-substring-search"
    git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.zsh/zsh-history-substring-search
  fi
fi


source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# Use Ctrl+Up/Down for history substring search (leaves plain arrows for menus)
bindkey '^[[1;5A' history-substring-search-up    # Ctrl+Up
bindkey '^[[1;5B' history-substring-search-down  # Ctrl+Down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_FUZZY=1
zsh_debug_section "zsh-history-substring-search"

################################################
#   Word Navigation Keybindings
################################################

# Ctrl+Left/Right - jump words
bindkey '^[[1;5D' backward-word   # Ctrl+Left
bindkey '^[[1;5C' forward-word    # Ctrl+Right

# Alt+Left/Right - jump words (alternate)
bindkey '^[[1;3D' backward-word   # Alt+Left
bindkey '^[[1;3C' forward-word    # Alt+Right

# Alt+b/f - emacs-style word navigation
bindkey '^[b' backward-word       # Alt+b
bindkey '^[f' forward-word        # Alt+f

zsh_debug_section "word-navigation"

################################################
#   zsh-z (directory jumping)                     
################################################

if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  if [[ -d ~/.zsh/zsh-z ]]; then
    echo " Updating zsh-z..."
    git -C ~/.zsh/zsh-z pull
  else
    echo " Installing from https://github.com/agkozak/zsh-z"
    git clone https://github.com/agkozak/zsh-z.git ~/.zsh/zsh-z
  fi
fi


source ~/.zsh/zsh-z/zsh-z.plugin.zsh
zsh_debug_section "zsh-z"



################################################
#   fast-syntax-highlighting
################################################

if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  if [[ -d ~/.zsh/fast-syntax-highlighting ]]; then
    echo " Updating fast-syntax-highlighting..."
    git -C ~/.zsh/fast-syntax-highlighting pull
  else
    echo " Installing from https://github.com/zdharma-continuum/fast-syntax-highlighting"
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.zsh/fast-syntax-highlighting
  fi
fi


source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
zsh_debug_section "fast-syntax-highlighting"

###############################
# Completion Styles (must be before compinit)
###############################

# Do menu-driven completion.
zstyle ':completion:*' menu select

# Color completion for some things.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Show extra info (like descriptions) in completion menus
zstyle ':completion:*' verbose yes

# Yellow header showing what type of completions are listed (e.g., "--- files")
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"

# Format for informational messages during completion
zstyle ':completion:*:messages' format '%d'

# Red warning when no matches found
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"

# Show correction suggestions with error count
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

# Group completions by type (files, options, etc.) with headers
zstyle ':completion:*' group-name ''

# Custom file patterns for custom scripts
#zstyle ':completion:*:*:CUSTOM1*:*' file-patterns '*.(lst|clst)'
#zstyle ':completion:*:*:CUSTOM2*:*' file-patterns '*.tsv'


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
zsh_debug_section "history-config"




###############################
# Autoload Functions
###############################

# Source custom functions
for _fn in "$DOTFILES_DIR"/functions/*.sh(N); do
  source "$_fn"
  zsh_debug_section "$_fn"
done
zsh_debug_section "autoload-functions"

###############################
# Load Local File as needed. 
###############################

[[ -r "$HOME/.zshrc_local.sh" ]] && source "$HOME/.zshrc_local.sh"
zsh_debug_section "local-zshrc"

# Starship loaded via functions/starship.sh
zsh_debug_section "starship"





###############################
# Initialize Completions - do after almost everything
###############################

# this should be done after adding to fpath, zstyles, and all plugins that add completions
autoload -Uz compinit && compinit
zsh_debug_section "compinit"


###############################
# Final Timing Report
###############################

if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  local current_time=$(date +%s.%N)
  local elapsed=$(echo "$current_time - $zsh_start_time_total" | bc -l)
  echo -e "\033[0;32m$(printf "Finished: Total time took %.3f seconds" "$elapsed")\033[0m"
fi


###############################
# Profiling Output
###############################

#[[ "$ZPROFRC" -eq 1 ]] && zprof
#[[ -v ZPROFRC ]] && unset ZPROFRC


# Always return success

############### Anything after this auto added ################

# pnpm
export PNPM_HOME="/Users/ctowles/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
