# github-cli.sh - GitHub CLI configuration and aliases

alias g="lazygit"

# Open repo in browser
alias gw="gh browse"

# List PRs
alias gpr="gh pr-ls"

# Stash, switch to main, and checkout a PR by number
alias gco='git stash && gmain && gh pr checkout '

# Create issue in web interface
alias gi="gh issue create --web"

# List PRs
alias pr-list='gh pr list'

# GH alias shortcuts
alias gh-iv='gh iv'
alias gh-m='gh m'
alias gh-mv='gh mv'

# Last CI run
alias ghci='gh run list -L 1'

# Setup GH alias function (run once to configure gh aliases)
gh-alias-setup() {
  gh alias set m --shell 'PAGER="less -FX" gh issue list --state open --assignee @me'
  gh alias set mv --shell 'PAGER="less -FX" gh issue list --state open --assignee @me --web'
  gh alias set iv --shell 'gh issue view $1 -w'
  gh alias set pr-ls --shell 'PAGER="less -FX" gh pr list'
}

# Push to origin and open GitHub PR creation
pr() {
  remote=origin
  branch=$(git symbolic-ref --short HEAD)

  if [[ $branch == "master" ]] || [[ $branch == "main" ]]; then
    echo "Error: In $branch branch, can't do a PR."
    return 1
  fi

  set -x
  git push ${remote} ${branch}
  gh pr create --web
}




# git-ignored - Show all files not included in Git

git-ignored() {
  echo "Showing all files not included in Git"
  git ls-files . --ignored --exclude-standard --others | grep -v node_modules
  echo ""
  echo "Example: you can remove some folders with the following using grep -v (inverse)"
  echo "git ls-files . --ignored --exclude-standard --others | grep -v node_modules"
}



# gitk - Open Gitkraken to current repository
gitk() {
  dir="$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
  echo "open gitkraken to '$dir'"
  open "gitkraken://repo/$dir"
}


# gmain - Switch to main/master branch and pull
gmain() {
  git stash
  main_branch=$(git branch -l main)
  if [ -z "${main_branch}" ]; then
    echo "checking out master"
    git checkout master
  else
    echo "checking out main"
    git checkout main
  fi
  git pull
}
