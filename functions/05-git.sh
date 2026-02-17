# git.sh - Git aliases and helper functions

# Setup: install lazygit
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v lazygit >/dev/null 2>&1; then
    echo " Installing lazygit..."
    case "$(uname -s)" in
      Darwin) brew install lazygit ;;
      Linux)
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin/lazygit
        rm /tmp/lazygit /tmp/lazygit.tar.gz
        ;;
    esac
  fi
fi

alias g="lazygit"
alias gc="git-ai-commit"
alias ga="git add ."
alias gp="git push"
alias gs="git status"

# Add all and commit with AI
alias gca="git add . && git-ai-commit"

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

# git-ai-commit - Generate commit message with Claude AI
#  this is wired up to lazygit as `c` keybinding for committing
git-ai-commit() {
  local files diff suggestions selected

  diff=$(git diff --cached)
  if [ -z "$diff" ]; then
    echo "No staged changes found"
    return 1
  fi

  files=$(git diff --cached --stat --color=always)
  message_count=5

  echo -e "\033[1;36mStaged files:\033[0m"
  echo "$files"
  echo
  echo "Generating ${message_count} commit messages with Claude..."
  suggestions=$(claude --print "Generate ${message_count} concise git commit messages for these changes. One per line, no numbering, no quotes. Use conventional commits (feat:, fix:, refactor:, docs:, chore:).

Files changed:
$files

Diff:
$diff" 2>/dev/null)

  if [ -z "$suggestions" ]; then
    echo "Failed to get suggestions from Claude"
    return 1
  fi

  # use fzf to select a commit message
  selected=$(echo -e "$suggestions\n[Cancel]" | fzf --height=40% --prompt="Select commit message: ")
  if [ -z "$selected" ] || [ "$selected" = "[Cancel]" ]; then
    echo "Cancelled"
    return 1
  fi
  git commit -m "$selected"
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
