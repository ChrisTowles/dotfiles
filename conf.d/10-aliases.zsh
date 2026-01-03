#!/bin/zsh
# conf.d/10-aliases.zsh - Essential system aliases

# Editor
alias co="code"

# Directory listing (platform-specific)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias ls='ls -al --color=always'
else
  alias ls='ls -al'
fi

# Directory removal
alias rmd='rm -rf'
alias rmdir='rm -rf'

# History search
alias hg='history | rg '

# ZSH source shortcuts
alias s-zsh="source ~/.zshrc"
alias source-zsh="source ~/.zshrc"

# Modern CLI tool aliases (only if installed)
if command -v eza &>/dev/null; then
  alias ls='eza -la --color=always'
  alias ll='eza -l --color=always'
  alias la='eza -la --color=always'
  alias tree='eza --tree'
fi

# jid - JSON incremental digger for building jq queries
if command -v jid &>/dev/null; then
  alias jid='jid -q'
  alias jidp='jid -p'
fi

# Clipboard aliases for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

zsh_debug_section "System aliases"
