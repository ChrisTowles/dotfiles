# install oh my zsh
# install brew on mac

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
  echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
  exit 1
}




# configure git
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"

# push the current branch and set the remote as upstream automatically every time you push
# git config --global push.default current

### Debug timing
# you can't measure what you don't track, so enable to debug slow starts
zsh_start_time_total=$(date +%s.%N)

# Debug timing: To enable debug timing, run: export ZSH_DEBUG_TIMING=1 && source ~/.zshrc
# Debug timing functions
if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
    zsh_debug_start_time=$(date +%s.%N)
    zsh_debug_section() {
        local current_time=$(date +%s.%N)
        local elapsed=$(echo "$current_time - $zsh_debug_start_time" | bc -l)
        print_warning "$(printf "DEBUG: %s took %.3f seconds" "$1" "$elapsed")"
        zsh_debug_start_time=$current_time
    }
else
    zsh_debug_section() { : }
fi

zsh_debug_section "Initial setup"

alias co="code"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # note: give up on brew for linux, every time its been a mistake
  # eval "$(~/.linuxbrew/bin/brew shellenv)"
  #eval $($(brew --prefix)/bin/brew shellenv)
  #echo "Linux, using vscode-insiders"
  #alias code="code-insiders"
  
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

zsh_debug_section "Brew setup"

# https://www.nerdfonts.com/font-downloads
# "FiraMono Nerd Font"
# set the font of the terminal application

if [[ "$OSTYPE" == "linux-gnu"* ]]; then

  # git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
  # ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
  ZSH_THEME="spaceship"
else
  # `brew install spaceship` better than git clone, due to remembering to update
  source "/opt/homebrew/opt/spaceship/spaceship.zsh" "$ZSH_CUSTOM/themes/spaceship-prompt"
fi

zsh_debug_section "Theme setup"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
# git clone https://github.com/kutsan/zsh-system-clipboard $ZSH_CUSTOM/plugins/zsh-system-clipboard # OMG, this is amazing, fixes the copy and paste issue with zsh on linux so that it works like it does on mac.

plugins=(
  git
  aws # auto complete for aws CLIv2
  #docker # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
  #docker-compose # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose
  # kubectl # auto complete for kubectl
  zsh-autosuggestions # suggests commands as you type based on history and completions.
  zsh-syntax-highlighting
  zsh-system-clipboard # copy and paste commands in zsh with the buffer from os clipboard, use  zle -al to see all key bindings actions
  zsh-z #  jump quickly to directories that you have visited frequently
)

zsh_debug_section "Plugin configuration"


# enable option-stacking for docker autocomplete - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes


### Fix slowness of pastes with zsh-syntax-highlighting.zsh - https://gist.github.com/magicdude4eva/2d4748f8ef3e6bf7b1591964c201c1ab
# posted in 2020 but still needed in 2025 ...
# pasteinit() {
#   OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
#   zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
# }

# pastefinish() {
#   zle -N self-insert $OLD_SELF_INSERT
# }
# zstyle :bracketed-paste-magic paste-init pasteinit
# zstyle :bracketed-paste-magic paste-finish pastefinish

zstyle ':bracketed-paste-magic' active-widgets '.self-*'

### Fix slowness of pastes


# If you come from bash you might have to change your $PATH.

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# increase history size, default is 1000
HISTSIZE=50000
SAVEHIST=50000

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

source $ZSH/oh-my-zsh.sh

zsh_debug_section "Oh-my-zsh loading"

# yes i know this doesn't save many keystrokes, but trying to autocomplete faster, as i run it alot.
alias s-zsh="source ~/.zshrc"
alias source-zsh="source ~/.zshrc"

# -------------------------------- #
# System level Changes Package Manager
# -------------------------------- #

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias ls='ls -al --color=always'
else
  alias ls='ls -al'
fi

alias rmd='rm -rf'   # remove directory
alias rmdir='rm -rf' # remove directory
alias hg='history | grep ' # search history


# Fix issue where `ls` didn't have colors - https://github.com/spaceship-prompt/spaceship-prompt/issues/436
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1




print_success "Chris's ZSH Profile"

zsh_debug_section "System aliases and functions"

# -------------------------------- #
# Node Package Manager
# -------------------------------- #
# mkdir ~/.nvm
# Install NVM - https://github.com/nvm-sh/nvm#installing-and-updating
#
  # moved to a one of function, i don't use it all the time and was slow.
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#}

# pnpm
export PNPM_HOME="/home/ctowles/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end



function npm-install-global() {
npm install --global  pnpm
npm install --global @antfu/ni
#https://github.com/sharkdp/fd 
npm install --global fd-find
npm install --global @towles/tool


}

export PATH="$HOME/.npm-global/bin:$PATH"

# Fd-find configuration
export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_COMMAND='fd --type file --strip-cwd-prefix --hidden --follow --exclude .git --preview "cat {}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"



# FZF - https://github.com/junegunn/fzf
# sudo apt remove fzf 
# most of the package managers are way out of date
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


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

zsh_debug_section "Node/pnpm setup"

# -------------------------------- #
# @towles/tool
# -------------------------------- #
# install @towles/tool
# npm i -g @towles/tool
alias tt="towles-tool"
alias today="towles-tool journal today"
alias meeting="towles-tool journal meeting"
alias note="towles-tool journal note"

zsh_debug_section "Towles tool setup"

# -------------------------------- #
# Github CLI
# -------------------------------- #




# Use gh from https://cli.github.com/
# brew install gh
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# this will create completes at /opt/homebrew/share/zsh/site-functions

# If not installed via Brew
# then generate # GH autocompletion # https://cli.github.com/manual/gh_completion
# "gh completion -s zsh > /usr/local/share/zsh/site-functions/_gh"

# # load the autocompletions
# autoload -U compinit
# compinit -i

# then login "gh auth login"

alias ghci='gh run list -L 1'

# Setup GH alias
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

# alias to github cli with the dash so both work.
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

zsh_debug_section "GitHub CLI setup"

# -------------------------------- #
# Git
# -------------------------------- #
# Use gh from https://cli.github.com/

# Note: that Oh-my-zsh also adds some git alias
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

## Most get aliases are from https://github.com/antfu/dotfiles/blob/main/.zshrc and i'm still working on which i like.
alias gs='git status'
# https://stackoverflow.com/questions/6089294/why-do-i-need-to-do-set-upstream-all-the-time
alias gp='git push -u origin HEAD'
alias gpf='git push -u origin HEAD --force'
alias gst='git stash'

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

#alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias grb='git rebase'
alias grbc='git rebase --continue'

alias gl='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all --date=short'

alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

alias ga='git add'
alias gai='git add --patch' # asks for each chuck, it feels more intuitive than "--interactive"
alias gA='git add --all'

alias gc='git commit'
alias gcm='git status && git commit -m' # commit with message, 
alias gcmnv='git commit --no-verify -m ' #

# create issue in web interface
alias gic='gh issue create --web --title' # create issue in web interface


# temporary commit untill i move it into `@towles/tool` - https://www.npmjs.com/package/@towles/tool
alias branch='towles-tool gh-branch' # use my cli tool to create a branch from an issue
alias branch-me='towles-tool gh-branch --assigned-to-me'


alias gcam='git add --all && git commit -m'
alias gfrb='git fetch origin && git rebase origin/master'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Only for linux
  # sudo apt install xclip xsel

  # echo "linux"
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi


function pr() {

  # Pushes to origin and opens a github compare view of it to speed up PR
  # creation.
  #
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
alias gi="gh issue create --web"

zsh_debug_section "Git aliases and functions"

git-ingored() {
  print_step "Showing all files not included in Git"

  git ls-files . --ignored --exclude-standard --others | grep -v node_modules

  echo ""
  print_step "Example: you can remove some folders with the following using grep -v (inverse)"
  echo "git ls-files . --ignored --exclude-standard --others | grep -v node_modules"gw

}


zsh_debug_section "Docker and http-server aliases"

# -------------------------------- #
# Gitkraken CLI
# -------------------------------- #

gitk() {
  dir="$(
    cd "$(dirname "$1")"
    pwd -P
  )/$(basename "$1")"
  print_step "open gitkraken to '$dir'"
  open "gitkraken://repo/$dir"
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

zsh_debug_section "Gitkraken and Docker setup"

# -------------------------------- #
# Directories
#
# I put all code in a directory called "code"
# mkdir -p ~/code/p # for my projects
# mkdir -p ~/code/f # for forks
# mkdir -p ~/code/r # for reproductions
# -------------------------------- #

# useful for quick directory change
# type "i p" to go to my personal repositories folder  
# type "i f" to go to my forked repositories folder
i() { cd ~/code/$1; }

alias pr-list='gh pr list'

# pnpm i -g live-server
function serve() {
  if [[ -z $1 ]]; then
    live-server dist
  else
    live-server $1
  fi
}

zsh_debug_section "Directory functions"

###

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  #  issue with not wrapping in quotes on linux, shows issues when copying and pasting constantly with `^[[200~`
  ## https://superuser.com/questions/1532688/pasting-required-text-into-terminal-emulator-results-in-200required-text
  printf "\e[?2004l"
fi



## Python Env
## uv - install uv
# https://docs.astral.sh/uv/getting-started/installation/
# curl -LsSf https://astral.sh/uv/install.sh | sh
alias s-py="source .venv/bin/activate"
alias source-py="source .venv/bin/activate"

zsh_debug_section "Python and PNG compression setup"


# load addintional scripts local to this machine...
source $HOME/.zshrc_local.sh

zsh_debug_section "Local scripts loading"

############## KeyBindings
if [[ "$OSTYPE" == "linux-gnu"* ]]; then


  # This file contains only zsh bindings. bash bindings are in .inputrc.
  # Show all commands available in zsh for key binding: zle -al
  # More info about key bindings: https://unix.stackexchange.com/questions/116562/key-bindings-table?rq=1

  # fixes issues with copying an post in terminal leaves `^[[200~` at the start of text
  # https://superuser.com/questions/1532688/pasting-required-text-into-terminal-emulator-results-in-200required-text 
  # had issues trying to use `~/.inputrc` so using this instead
  bindkey "\C-v" ""

  # 2025-04-09 has issue where pasteing left out some characters.. so disabling.
  #bindkey "^V" "zsh-system-clipboard-vicmd-vi-yank" 
  
  set enable-bracketed-paste off
  # this is used into combo with zsh-system-clipboard plugin above

fi

zsh_debug_section "Key bindings setup"

###### Claude Code 


###### Claude Code 

# install claude code ![claude-app-setup](/docs/apps/claude-code.md)

 
# fpath+=~/.zfunc; autoload -Uz compinit; compinit

#alias claude="/home/ctowles/.claude/local/claude"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PATH+=":$HOME/.claude/local/"
    alias c="claude --dangerously-skip-permissions"
    alias cr="claude --dangerously-skip-permissions --resume"
else
  # shorthand alias to run claude prompt
  alias c="claude"
  alias cr="claude --resume"
fi

alias ccusage="pnpm dlx ccusage blocks --live"

zsh_debug_section "Claude Code setup"

if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  local current_time=$(date +%s.%N)
  local elapsed=$(echo "$current_time - $zsh_start_time_total" | bc -l)
  print_success "$(printf "Finished: Total time %s took %.3f seconds" "$1" "$elapsed")"
fi

############### Anything after this auto added ################
