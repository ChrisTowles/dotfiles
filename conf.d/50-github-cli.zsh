#!/bin/zsh
# conf.d/50-github-cli.zsh - GitHub CLI configuration and aliases

# command -v gh &>/dev/null || return 0

# Basic GitHub CLI aliases
alias ghci='gh run list -L 1'
alias gh-iv='gh iv'
alias gh-m='gh m'
alias gh-mv='gh mv'
alias gpr="gh pr-ls"
alias gw="gh browse"
alias gco='git stash && gmain && gh pr checkout '
alias gi="gh issue create --web"
alias pr-list='gh pr list'

# Setup GH alias function (run once to configure gh aliases)
gh-alias-setup() {
  gh alias set m --shell 'PAGER="less -FX" gh issue list --state open --assignee @me'
  gh alias set mv --shell 'PAGER="less -FX" gh issue list --state open --assignee @me --web'
  gh alias set iv --shell 'gh issue view $1 -w'
  gh alias set pr-ls --shell 'PAGER="less -FX" gh pr list'
}

zsh_debug_section "GitHub CLI setup"
