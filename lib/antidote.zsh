#!/bin/zsh
# lib/antidote.zsh - Antidote plugin manager bootstrap

# Brew setup (keep before plugins for macOS)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux - skip brew (not worth the hassle)
  :
else
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
fi

zsh_debug_section "Brew setup"

# Clone antidote if not present (XDG-compliant location)
ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
[[ -d "${XDG_DATA_HOME:-$HOME/.local/share}" ]] || mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"
if [[ ! -d "$ANTIDOTE_HOME" ]]; then
  print_warning "Antidote not found. Cloning..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
fi

# Source antidote
source "$ANTIDOTE_HOME/antidote.zsh"

# Static plugin file for fast loading
zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle < "${zsh_plugins}.txt" > "${zsh_plugins}.zsh"
fi
source "${zsh_plugins}.zsh"

# Completion system init (AFTER plugins modify fpath)
autoload -Uz compinit && compinit

zsh_debug_section "Antidote plugins"

# AWS CLI v2 completion
if command -v aws &>/dev/null; then
  autoload -Uz bashcompinit && bashcompinit
  complete -C "$(which aws_completer)" aws
fi

# Ensure zsh modules available
zmodload zsh/zle 2>/dev/null
zmodload zsh/parameter 2>/dev/null

zsh_debug_section "Plugin configuration complete"
