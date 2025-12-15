#!/bin/zsh
# conf.d/50-python.zsh - Python and uv environment setup

command -v uv &>/dev/null || return 0

# Python venv activation shortcuts
alias s-py="source .venv/bin/activate"
alias source-py="source .venv/bin/activate"

zsh_debug_section "Python setup"
