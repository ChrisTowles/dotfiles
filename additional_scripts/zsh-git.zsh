# zsh-git.zsh
# Git aliases and functions

# Note: Oh-my-zsh also adds some git aliases
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

# Basic git aliases
alias gs='git status'
# https://stackoverflow.com/questions/6089294/why-do-i-need-to-do-set-upstream-all-the-time
alias gp='git push -u origin HEAD'
alias gpf='git push -u origin HEAD --force'
alias gst='git stash'

# Function to switch to main/master branch
gmain() {
  git stash
  main_branch=$(git branch -l main)
  if [ -z "${main_branch}" ]; then
    print_step "checking out master"
    git checkout master
  else
    print_step "checking out main"
    git checkout main
  fi
  git pull
}

# Branch management
alias gcb='git checkout -b'
alias gb='git branch'
alias grb='git rebase'
alias grbc='git rebase --continue'

# Commit and log
alias gl='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all --date=short'

alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

alias ga='git add'
alias gai='git add --patch' # asks for each chuck, it feels more intuitive than "--interactive"
alias gA='git add --all'

alias gc='git commit'
alias gcm='git add --all && git commit -m'
alias gfrb='git fetch origin && git rebase origin/master'

# Create issue in web interface
alias gic='gh issue create --web --title' # create issue in web interface

# Commit helper function - suggests 3 commit message options and creates commit
function gcmc() {
    echo "Initializing git commit message helper..."
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Check if there are staged changes
    if ! git diff --cached --quiet; then
        echo "Staged changes detected. Proceeding with commit message suggestions..."
    elif ! git diff --quiet; then
        echo "Unstaged changes detected. Staging all changes..."
        git add .
    else
        echo "No changes to commit"
        return 0
    fi

    # Get the diff of staged changes
    local DIFF=$(git diff --cached --name-only | head -10)
    local SUMMARY=$(git diff --cached --stat | tail -1)

    echo "Changes to commit:"
    echo "$SUMMARY"
    echo ""

    # Generate 3 commit message options based on file changes
    echo "Commit message options:"
    echo ""

    local MSG1 MSG2 MSG3

    # Option 1: feat/fix/chore based on file types
    if echo "$DIFF" | grep -q "\.github/workflows"; then
        MSG1="ci: update GitHub workflow configuration"
    elif echo "$DIFF" | grep -q "package\.json\|pnpm-lock\.yaml"; then
        MSG1="chore: update dependencies"
    elif echo "$DIFF" | grep -q "\.md$"; then
        MSG1="docs: update documentation"
    elif echo "$DIFF" | grep -q "\.vue\|\.ts\|\.js"; then
        MSG1="feat: implement new functionality"
    else
        MSG1="chore: update project files"
    fi

    # Option 2: More specific based on directory
    if echo "$DIFF" | grep -q "packages/blog"; then
        MSG2="blog: update blog functionality"
    elif echo "$DIFF" | grep -q "content/"; then
        MSG2="content: add new blog content"
    elif echo "$DIFF" | grep -q "server/"; then
        MSG2="server: update server logic"
    else
        MSG2="refactor: improve code structure"
    fi

    # Option 3: Simple descriptive
    if [ $(echo "$DIFF" | wc -l) -eq 1 ]; then
        local FILENAME=$(basename "$DIFF")
        MSG3="update: modify $FILENAME"
    else
        MSG3="update: modify multiple files"
    fi

    echo "1) $MSG1"
    echo "2) $MSG2" 
    echo "3) $MSG3"
    echo ""

    # Prompt for selection
    read "choice?Select commit message (1-3) or enter custom message: "

    local COMMIT_MSG
    case $choice in
        1)
            COMMIT_MSG="$MSG1"
            ;;
        2)
            COMMIT_MSG="$MSG2"
            ;;
        3)
            COMMIT_MSG="$MSG3"
            ;;
        *)
            COMMIT_MSG="$choice"
            ;;
    esac

    # Create the commit
    git commit -m "$COMMIT_MSG"
    echo ""
    echo "✅ Committed with message: $COMMIT_MSG"
}

# PR function
function pr() {
  # Pushes to origin and opens a github compare view of it to speed up PR
  # creation.
  remote=origin
  branch=$(git symbolic-ref --short HEAD)

  if [[ $branch == "master" ]]; then
    print_error "In master branch, can't do a PR."
  else
    # https://github.com/foo/bar.git -> foo/bar
  repo=$(git ls-remote --get-url ${remote} |
      sed 's|^.*.com[:/]\(.*\)$|\1|' |
      sed 's|\(.*\)/$|\1|' |
      sed 's|\(.*\)\(\.git\)|\1|')

    set -x
    git push ${remote} ${branch}
    gh pr create --web # create pr in web interface
  fi
}

# Git utility function
git-ignored() {
  print_step "Showing all files not included in Git"
  git ls-files . --ignored --exclude-standard --others | grep -v node_modules
  echo ""
  print_step "Example: you can remove some folders with the following using grep -v (inverse)"
  echo "git ls-files . --ignored --exclude-standard --others | grep -v node_modules"
}

zsh_debug_section "Git aliases and functions"