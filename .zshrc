# install oh my zsh

# git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# or `brew install spaceship`

# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
ZSH_THEME="spaceship"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
plugins=(
  git
  zsh-autosuggestions # suggests commands as you type based on history and completions.
  zsh-syntax-highlighting
  zsh-z #  jump quickly to directories that you have visited frequently
)


ZSH_THEME="spaceship"
# If you come from bash you might have to change your $PATH.

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

source $ZSH/oh-my-zsh.sh


# -------------------------------- #
# System level Changes Package Manager
# -------------------------------- #

alias ls='ls -aGl' # have ls have the directory colors (G) and hidden dirs 'a'
alias rmd='rm -rf' # remove directory

# install Gum https://github.com/charmbracelet/gum#installation


echo-red() {
  gum style --foreground "#FF0000" "$1"
}

echo-green() {
  gum style --foreground "#32CD32" "$1"
}

echo-yellow() {
  gum style --foreground "#FFFF00" "$1"
}
echo-green "Chris's ZSH Profile"

# -------------------------------- #
# Node Package Manager
# -------------------------------- #

# Install NVM

# install pnpm 
# pnpm setup
# check what it added to bottom of zshrc


# install @antfu/ni
# npm i -g @antfu/ni



alias s="nr start"
alias d="nr dev"
alias b="nr build"
alias bw="nr build --watch"
alias t="nr test"
alias tw="nr test --watch"
alias w="nr watch"

alias lint="nr lint"
alias lintf="nr lint --fix"
alias release="nr release"



# -------------------------------- #
# Git
# -------------------------------- #

# Use gh from https://cli.github.com/# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

## Most get aliases are from https://github.com/antfu/dotfiles/blob/main/.zshrc and i'm still working on which i like.

alias gs='git status'
alias gp='git push'
alias gpf='git push --force'
alias gpft='git push --follow-tags'
alias gpl='git pull --rebase'
alias gcl='git clone'
alias gst='git stash'
alias grm='git rm'
alias gmv='git mv'

alias gmain='git checkout main'

alias gco='git checkout'
alias gcob='git checkout -b'

alias gb='git branch'
alias gbd='git branch -d'

alias grb='git rebase'
alias grbom='git rebase origin/master'
alias grbc='git rebase --continue'

alias gl='git log'
alias glo='git log --oneline --graph'

alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

alias ga='git add'
alias gA='git add -A'

alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git add -A && git commit -m'
alias gfrb='git fetch origin && git rebase origin/master'

alias gxn='git clean -dn'
alias gx='git clean -df'


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Only for linux
    # sudo apt install xclip xsel

    echo "linux"
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

alias gsha='git rev-parse HEAD | pbcopy'

git-p() {   git push -u origin HEAD}  #   # https://stackoverflow.com/questions/6089294/why-do-i-need-to-do-set-upstream-all-the-time

git-mp() {   git checkout master && git pull && git fetch --all  }


gh-pr() {

  # Pushes to origin and opens a github compare view of it to speed up PR
  # creation.
  #
  
  remote=origin
  branch=$(git symbolic-ref --short HEAD)

  if [[ $branch == "master" ]]
  then
    echo-red "In master branch, can't do a PR."
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

git-ingored() {
  echo "Showing all files not included in Git"

  git ls-files . --ignored --exclude-standard --others | grep -v node_modules

  echo ""
  echo "Example: you can remove some folders with the following using grep -v (inverse)"
  echo "git ls-files . --ignored --exclude-standard --others | grep -v node_modules"

}


# -------------------------------- #
# Github CLI
# -------------------------------- #

# Use gh from https://cli.github.com/

# then login "gh auth login"
# If not installed via Brew
# then generate # GH autocompletion # https://cli.github.com/manual/gh_completion
# "gh completion -s zsh > /usr/local/share/zsh/site-functions/_gh"

autoload -U compinit
compinit -i

alias ghci='gh run list -L 1'

# Setup GH alias
gh-alias-setup() {
  # gh m
  # creates alias to see any issues assigned to me

  gh alias set m --shell \
    'PAGER="less -FX" gh issue list --state open --assignee @me'

  #gh iv 
  # creates alias to open issue on website
  gh alias set iv --shell \
    'gh issue view $1 -w' # open issue on the web
}

# create branch based on issue name
gh-i() {
  title=`gh issue view $1 --json title --jq .title`
  slugTemp=`echo "$title" | sed -e 's/[^[:alnum:]]/-/g'` # replace spaces with `-`
  slugTemp=`echo "$slugTemp" | sed -e 's/--/-/g'` # replace -- with `-`
  slugTemp=`echo "$slugTemp" | sed -e 's/--/-/g'` # replace -- with `-` a second time. 
  slugTemp=`echo "$slugTemp" | sed -e 's/--/-/g'` # replace -- with `-` just to be sure.
  slugTemp=`echo "$slugTemp" | sed -E 's/-$//g'` # remove any trailing dashes
  slug=`echo "$slugTemp" | awk '{ print tolower($1) }'`  # to lower case
  branchName="feature/$1-$slug"; 
  echo "issue:      $1" 
  echo "title:      $title" 
  echo "branchName: $branchName" 
  git checkout -b "$branchName"
}


# -------------------------------- #
# Docker
# -------------------------------- #
alias dstats='docker stats --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.BlockIO}}\t{{.NetIO}}\t{{.PIDs}}"'

alias docker_restart="osascript -e 'quit app \"Docker\"' && open -a Docker"
alias dlist='docker ps'                        # Running
alias dlistAll='docker ps -a'                  # All
alias dkill='docker kill $(docker ps -q)'      # kill all running containers
alias ddel='docker rm $(docker ps -a -q)'      # delete all stopped containers with
alias dimgdel='docker rmi $(docker images -q)' # delete all images
alias dreset='docker-compose down; docker volume prune'

# -------------------------------- #
# Directories
#
# I put all code in a directory called "code"
# mkdir -p ~/code/p # for my projects
# mkdir -p ~/code/f # for forks
# mkdir -p ~/code/r # for reproductions
# -------------------------------- #

function i() {
  cd ~/code/$1
}

function repros() {
  cd ~/code/r/$1
}

function forks() {
  cd ~/code/f/$1
}

function pr() {
  if [ $1 = "ls" ]; then
    gh pr list
  else
    gh pr checkout $1
  fi
}

function dir() {
  mkdir $1 && cd $1
}

# pnpm i -g live-server
function serve() {
  if [[ -z $1 ]] then
    live-server dist
  else
    live-server $1
  fi
}

###


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    #  issue with not wrapping in quotes on linux
    ## https://superuser.com/questions/1532688/pasting-required-text-into-terminal-emulator-results-in-200required-text
    #  printf "\e[?2004l"
fi


## NVM - Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# pnpm
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  #linux folder
  export PNPM_HOME="$HOME/.local/share/pnpm"  
else
  # mac folder
  export PNPM_HOME="$HOME/Library/pnpm"
fi

export PATH="$PNPM_HOME:$PATH"
# pnpm end


## Pyenv

# Install pyenv
# pyenv install --list 
# pyenv install 3.10.4

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# Pyenv end

# load addintional scripts local to this machine...
source $HOME/.zshrc_local