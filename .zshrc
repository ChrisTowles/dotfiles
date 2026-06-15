#!/bin/zsh
# .zshrc - Interactive shell configuration
# Minimal orchestrator following mattmc3/zdotdir pattern



DOTFILES_DIR="$HOME/code/p/dotfiles"

# Cache platform once — avoids repeated uname subprocess calls across function files
_DOTFILES_OS="$(uname -s)"

alias ls='ls -al'
# --wait makes VS Code block until the tab is closed, required for tools
# that use $EDITOR (git commit, claude code ctrl+g prompt editing, etc.)
export EDITOR="code-insiders --wait"
export VISUAL="$EDITOR"

# Profiling support (use: zprofrc)
#[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
#alias zprofrc="ZPROFRC=1 zsh"

# exec replaces the shell process cleanly; `source ~/.zshrc` can leave stale state
alias ez="unset DOTFILES_SETUP && exec zsh"
alias ez-setup="DOTFILES_SETUP=1 exec zsh"
alias zsh-dotfiles-setup="DOTFILES_SETUP=1 exec zsh"

if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  echo "⚠️  Running zshrc in setup mode..."
fi

# Helper: clone or pull a git repo (setup-only)
_git_clone_or_pull() {
  local repo_url="$1" target_dir="$2"
  [[ "${DOTFILES_SETUP:-0}" -eq 1 ]] || return 0
  local name="${target_dir##*/}"
  if [[ -d "$target_dir" ]]; then
    echo " Updating $name..."
    git -C "$target_dir" pull || { echo "git pull failed for $name"; return 1; }
  else
    echo " Installing $name from $repo_url"
    git clone "$repo_url" "$target_dir" || { echo "git clone failed for $name"; return 1; }
  fi
}

# Convenience wrapper for zsh plugins under ~/.zsh/
_zsh_plugin_update() {
  _git_clone_or_pull "$1" "$HOME/.zsh/$2"
}

###############################
# Debug Timing (must be early)

# Debug alias - reload with timing
alias zsh-load='ZSH_DEBUG_TIMING=1 exec zsh'

if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  zsh_start_time_total=$(date +%s.%N)
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
_zsh_plugin_update "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh_debug_section "zsh-autosuggestions"

################################################
#   zsh-completions                            #
################################################

# providing many additional completion definitions
# try with "git -" and hit tab
_zsh_plugin_update "https://github.com/zsh-users/zsh-completions.git" "zsh-completions"

fpath=(~/.zsh/zsh-completions/src $fpath)

# Rust/Cargo completions (cached to avoid rustc subprocess on every shell start)
_rust_sysroot="$HOME/.cache/zsh-rust-sysroot"
if command -v rustc >/dev/null 2>&1; then
  [[ -f "$_rust_sysroot" ]] || rustc --print sysroot > "$_rust_sysroot"
  fpath=("$(<$_rust_sysroot)/share/zsh/site-functions" $fpath)
fi

# Generated completions (individual function files handle their own during DOTFILES_SETUP)
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  mkdir -p ~/.zsh/completions
fi
fpath=(~/.zsh/completions $fpath)

zsh_debug_section "zsh-completions"

################################################
#   ZSH HISTORY SUBSTRING SEARCH               #
################################################


_zsh_plugin_update "https://github.com/zsh-users/zsh-history-substring-search.git" "zsh-history-substring-search"


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
#   Reset Kitty keyboard protocol at each prompt
################################################
# If a TUI (Claude Code, nvim, etc.) enables enhanced keys and crashes without
# popping the mode, Ghostty sends sequences like ESC[1;29A for arrow keys and
# zle leaks "29A" as literal text. Clearing flags on every prompt is defensive.
# Pop the kitty stack before clearing — ESC[=0u only zeroes the top entry, so
# stale pushes underneath would resurface later. Also drop color-scheme
# reporting (2031); TUIs re-enable it when they start.
_reset_keyboard_protocol() {
  printf '\e[<3u\e[=0u\e[?2031l'
  # Inside tmux that only reaches the pane pty. A dead TUI can leave the kitty
  # protocol stuck on the OUTER terminal too (Esc arrives as CSI 27u → dead Esc,
  # phantom shortcuts). When this prompt is in the focused pane of an attached
  # session, heal the Ghostty-facing client tty directly.
  if [[ -n $TMUX && -n $TMUX_PANE ]]; then
    # One call: the pane the client is currently viewing, and the client tty.
    # Only the viewed pane's prompt may touch the outer terminal (sessions can
    # share linked windows, so resolving via session names is unreliable).
    local cur ctty
    read -r cur ctty <<< "$(tmux display-message -p '#{pane_id} #{client_tty}' 2>/dev/null)"
    [[ $cur == "$TMUX_PANE" && -w $ctty ]] && printf '\e[<3u\e[=0u' > "$ctty"
  fi
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _reset_keyboard_protocol

zsh_debug_section "keyboard-protocol-reset"

################################################
#   Swallow stray terminal-query replies
################################################
# TUIs (Claude Code) probe terminal capabilities on startup: DECRQM for modes
# 2026/2027/2031/1004/1016/2004, a kitty-graphics query (i=31337), and DA1.
# If the app exits before reading Ghostty's replies, they land at the prompt as
# garbage like "1016;2$y2027;1$y...Gi=31337;OK62;22;52c". These prefixes never
# come from a keyboard, so bind them to widgets that drain the reply instead.

# CSI replies (ESC [ ? ... ): DECRPM ends in $y, DA1 in c, kitty-kbd in u,
# cursor position in R — all end at the first ASCII letter.
_swallow_csi_reply() {
  local c
  while read -t 0.05 -k 1 c; do
    [[ $c == [a-zA-Z] ]] && break
  done
}
zle -N _swallow_csi_reply
bindkey '\e[?' _swallow_csi_reply

# String replies (APC kitty-graphics, DCS, OSC color queries): terminated by
# ST (ESC \) or BEL. Compare char codes — a bare backslash misbehaves in
# zsh pattern context ([[ $c == '\\' ]] fails to match it).
_swallow_st_reply() {
  local c prev=''
  while read -t 0.05 -k 1 c; do
    (( #prev == 27 && #c == 92 )) && break  # ESC \
    (( #c == 7 )) && break                  # BEL
    prev=$c
  done
}
zle -N _swallow_st_reply
bindkey '\e_' _swallow_st_reply   # APC (kitty graphics reply)
bindkey '\eP' _swallow_st_reply   # DCS
bindkey '\e]' _swallow_st_reply   # OSC (color/background query replies)

zsh_debug_section "terminal-reply-guard"

################################################
#   zsh-z (directory jumping)
################################################

_zsh_plugin_update "https://github.com/agkozak/zsh-z.git" "zsh-z"


source ~/.zsh/zsh-z/zsh-z.plugin.zsh
zsh_debug_section "zsh-z"



################################################
#   fast-syntax-highlighting
################################################

_zsh_plugin_update "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" "fast-syntax-highlighting"


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

# Post-setup message queue (functions append via: DOTFILES_SETUP_MESSAGES+=("message"))
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  DOTFILES_SETUP_MESSAGES=()
fi

###############################
# Initialize Completions
###############################

# Must run before functions/*.sh are sourced so compdef is available
autoload -Uz compinit && compinit
zsh_debug_section "compinit"

# Source custom functions
for _fn in "$DOTFILES_DIR"/functions/*.sh(N); do
  if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
    echo "\033[2m──\033[0m \033[36m${_fn:t}\033[0m \033[2m──\033[0m"
  fi
  source "$_fn"
  zsh_debug_section "$_fn"
done
zsh_debug_section "autoload-functions"

# Print post-setup messages
if [[ "$DOTFILES_SETUP" -eq 1 ]] && (( ${#DOTFILES_SETUP_MESSAGES[@]} > 0 )); then
  echo ""
  echo "\033[1;33m--- Post-setup actions ---\033[0m"
  for _msg in "${DOTFILES_SETUP_MESSAGES[@]}"; do
    echo "  $_msg"
  done
  echo ""
fi
unset DOTFILES_SETUP

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

# compinit already ran before functions/*.sh - see above


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

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
