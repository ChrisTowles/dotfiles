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
  local remote=origin
  local branch
  branch=$(git symbolic-ref --short HEAD)

  if [[ $branch == "master" || $branch == "main" ]]; then
    echo "Error: In $branch branch, can't do a PR."
    return 1
  fi

  git push "$remote" "$branch" && gh pr create --web
}

# Configure git global user.name and user.email from GitHub profile
gh-git-config() {
  if ! gh auth status &>/dev/null; then
    echo "Not authenticated — run 'gh auth login' first."
    return 1
  fi

  local gh_name gh_email
  gh_name="$(gh api user --jq '.name // empty')"
  gh_email="$(gh api user/emails --jq '[.[] | select(.primary)] | .[0].email // empty')"

  if [[ -z "$gh_name" ]] || [[ -z "$gh_email" ]]; then
    echo "Could not fetch name or email from GitHub API."
    return 1
  fi

  echo "Setting git config from GitHub:"
  echo "  user.name  = $gh_name"
  echo "  user.email = $gh_email"
  git config --global user.name "$gh_name"
  git config --global user.email "$gh_email"
  echo "Done."
}

# Setup GH alias function (run once to configure gh aliases)
gh-alias-setup() {
  gh alias set --clobber m --shell 'PAGER="less -FX" gh issue list --state open --assignee @me'
  gh alias set --clobber mv --shell 'PAGER="less -FX" gh issue list --state open --assignee @me --web'
  gh alias set --clobber iv --shell 'gh issue view $1 -w'
  gh alias set --clobber pr-ls --shell 'PAGER="less -FX" gh pr list'
}

# Setup: configure aliases, completions, and git user during dotfiles setup
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  gh-alias-setup

  echo " Generating gh completions..."
  mkdir -p ~/.zsh/completions
  gh completion -s zsh > ~/.zsh/completions/_gh

  if ! gh auth status &>/dev/null; then
    echo " GitHub CLI not authenticated — run 'gh auth login' then 'gh-git-config' to set git user."
  elif [[ -z "$(git config --global user.name)" || -z "$(git config --global user.email)" ]]; then
    echo " Git user not configured globally — pulling from GitHub..."
    gh-git-config
  fi
fi
