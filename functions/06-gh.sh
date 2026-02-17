# gh.sh - GitHub CLI aliases and helper functions

# Setup: install GitHub CLI
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo " Installing GitHub CLI..."
    case "$(uname -s)" in
      Darwin) brew install gh ;;
      Linux)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install -y gh
        ;;
    esac
  fi
fi

# Open repo in browser
alias gw="gh browse"

# List PRs
alias gpr="gh pr-ls"
alias pr-list='gh pr list'

# Stash, switch to main, and checkout a PR by number
alias gco='git stash && gmain && gh pr checkout '

# Create issue in web interface
alias gi="gh issue create --web"

# Last CI run
alias ghci='gh run list -L 1'

# GH alias shortcuts
alias gh-iv='gh iv'
alias gh-m='gh m'
alias gh-mv='gh mv'

# Browse issues and checkout a branch for selected issue
gib() {
  gh issue list --state open | fzf --header "Select issue" | awk '{print $1}' | xargs -I{} gh issue develop {} --checkout
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

# Setup GH alias function (run once to configure gh aliases)
gh-alias-setup() {
  gh alias set --clobber m --shell 'PAGER="less -FX" gh issue list --state open --assignee @me'
  gh alias set --clobber mv --shell 'PAGER="less -FX" gh issue list --state open --assignee @me --web'
  gh alias set --clobber iv --shell 'gh issue view $1 -w'
  gh alias set --clobber pr-ls --shell 'PAGER="less -FX" gh pr list'
}

# Run gh-alias-setup during dotfiles setup
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  gh-alias-setup
fi
