#!/bin/zsh
# conf.d/50-towles-tool.zsh - @towles/tool CLI aliases

command -v towles-tool &>/dev/null || return 0

alias tt="towles-tool"
alias today="towles-tool journal today"
alias meeting="towles-tool journal meeting"
alias note="towles-tool journal note"
alias branch='towles-tool gh-branch'
alias branch-me='towles-tool gh-branch --assigned-to-me'

zsh_debug_section "Towles tool setup"
