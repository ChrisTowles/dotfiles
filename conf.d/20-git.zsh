#!/bin/zsh
# conf.d/20-git.zsh - Git aliases
# Note: Functions (gmain, gcmc, pr, git-ignored) moved to functions/ directory

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

# Basic git aliases
alias gs='git status'
alias gp='git push -u origin HEAD'
alias gpf='git push -u origin HEAD --force'
alias gst='git stash'

# Branch management
alias gcb='git checkout -b'
alias gb='git branch'
alias grb='git rebase'
alias grbc='git rebase --continue'

# Log
alias gl='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all --date=short'

# Reset
alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

# Add
alias ga='git add'
alias gai='git add --patch'
alias gA='git add --all'

# Commit
alias gc='git commit'
alias gcm='git add --all && git commit -m'
alias gfrb='git fetch origin && git rebase origin/master'

# Issue creation (via gh)
alias gic='gh issue create --web --title'

zsh_debug_section "Git aliases"
