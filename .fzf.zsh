# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/ctowles/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/ctowles/.fzf/bin"
fi

source <(fzf --zsh)
