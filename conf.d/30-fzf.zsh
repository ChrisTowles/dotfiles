#!/bin/zsh
# conf.d/30-fzf.zsh - FZF (fuzzy finder) configuration

# Skip if fzf not available
[[ -f ~/.fzf.zsh ]] || command -v fzf &>/dev/null || return 0

# FZF options
export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_COMMAND='fd --type file --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Source fzf shell integration
if [[ -f ~/.fzf.zsh ]]; then
  source "$HOME/.fzf.zsh"
fi

zsh_debug_section "FZF setup"
