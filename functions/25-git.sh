# git.sh - Git aliases and helper functions

alias gc="git-ai-commit"
alias gcm="git-ai-commit"
alias ga="git add ."
alias gp="git push"
alias gs="git status"

# Add all and commit with AI
alias gca="git add . && git-ai-commit"

# gmain - Switch to main/master branch and pull
gmain() {
  git stash || { echo "git stash failed"; return 1; }
  local main_branch=$(git branch -l main)
  if [ -z "${main_branch}" ]; then
    echo "checking out master"
    git checkout master || { echo "checkout failed"; return 1; }
  else
    echo "checking out main"
    git checkout main || { echo "checkout failed"; return 1; }
  fi
  git pull || { echo "git pull failed"; return 1; }
}

# gclean - Delete local branches whose remote tracking branch is gone
gclean() {
  git fetch --prune || { echo "git fetch failed"; return 1; }
  local gone_branches
  gone_branches=$(git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | awk '/\[gone\]/ {print $1}')
  if [[ -z "$gone_branches" ]]; then
    echo "No stale branches to clean up."
    return 0
  fi
  echo "Branches with gone remotes:"
  echo "$gone_branches" | sed 's/^/  /'
  echo ""
  read -q "confirm?Delete these branches? [y/N] " || { echo ""; return 0; }
  echo ""
  while IFS= read -r branch; do
    git branch -D "$branch"
  done <<< "$gone_branches"
}

# git-ai-commit - Generate commit message with Claude AI
#  this is wired up to lazygit as `c` keybinding for committing
_GIT_CONFIG_DIR="${0:a:h}/../config/git"
git-ai-commit() {
  bun run "$_GIT_CONFIG_DIR/ai-commit.ts"
}

# grebase-preserve - Rebase onto a branch while preserving original author as committer
# Prevents rebase from overwriting committer info on other people's commits
grebase-preserve() {
  local target="${1:-main}"
  git rebase "$target" && git filter-branch -f --env-filter '
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
    export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
  ' "$(git merge-base HEAD "$target")..HEAD"
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
