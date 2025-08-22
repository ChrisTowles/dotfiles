# zsh-github-cli.zsh
# GitHub CLI configuration and aliases

# Use gh from https://cli.github.com/
# brew install gh
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# Basic GitHub CLI aliases
alias ghci='gh run list -L 1'

# Setup GH alias function
gh-alias-setup() {
  # gh m
  # creates alias to see any issues assigned to me
  gh alias set m --shell \
    'PAGER="less -FX" gh issue list --state open --assignee @me'

  # open my issues in the web
  gh alias set mv --shell \
    'PAGER="less -FX" gh issue list --state open --assignee @me --web'

  #gh iv
  # creates alias to open issue on website
  gh alias set iv --shell \
    'gh issue view $1 -w' # open issue on the web

  gh alias set pr-ls --shell \
    'PAGER="less -FX" gh pr list'
}

# GitHub CLI shortcuts
alias gh-iv='gh iv'
alias gh-m='gh m'
alias gh-mv='gh mv'
alias gpr="gh pr-ls"

# open repo in browser
alias gw="gh browse"

# create branch based on issue name
# i use the "tt branch" from the cli folder to do this now.

# stash current changes and checkout a PR by number
alias gco='git stash && gmain && gh pr checkout '

# create issue in web interface  
alias gi="gh issue create --web"

alias pr-list='gh pr list'

zsh_debug_section "GitHub CLI setup"