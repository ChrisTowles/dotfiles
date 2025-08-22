# zsh-02-basic-aliases.zsh
# Essential aliases used frequently

# Basic system aliases
alias co="code"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias ls='ls -al --color=always'
else
  alias ls='ls -al'
fi

alias rmd='rm -rf'   # remove directory
alias rmdir='rm -rf' # remove directory
alias hg='history | rg ' # search history

# ZSH source shortcuts
alias s-zsh="source ~/.zshrc"
alias source-zsh="source ~/.zshrc"

# Modern CLI tool aliases (only if installed)
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

if command -v eza &>/dev/null; then
  alias ls='eza -la --color=always'
  alias ll='eza -l --color=always'
  alias la='eza -la --color=always'
  alias tree='eza --tree'
fi

if command -v bat &>/dev/null; then
  alias cat='bat'
fi

# Clipboard aliases for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # sudo apt install xclip xsel
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# Directory navigation
# useful for quick directory change
# type "i p" to go to my personal repositories folder  
# type "i f" to go to my forked repositories folder
i() { cd ~/code/$1; }

zsh_debug_section "System aliases and functions"