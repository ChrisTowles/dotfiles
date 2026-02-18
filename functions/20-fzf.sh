################################################
#   fzf (fuzzy finder)
################################################

# Ctrl+T: paste files/dirs, Ctrl+R: history, Alt+C: cd into dir
if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  # Install fd (faster find, used by fzf)
  if ! command -v fd >/dev/null 2>&1; then
    echo " Installing fd..."
    case "$(uname -s)" in
      Darwin) brew install fd ;;
      Linux) sudo apt install -y fd-find ;;
    esac
  fi

  if [[ -d ~/.fzf ]]; then
    echo " Updating fzf..."
    git -C ~/.fzf pull && ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
  else
    echo " Installing from https://github.com/junegunn/fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
  fi
fi

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Use fd if available (faster, respects .gitignore)
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Search home directory with fzf and open in $EDITOR
fh() {
  local file preview_cmd
  if command -v bat >/dev/null 2>&1; then
    preview_cmd='bat --color=always --style=numbers --line-range=:200 {}'
  else
    preview_cmd='head -100 {}'
  fi
  if command -v fd >/dev/null 2>&1; then
    file=$(fd --type f --hidden --follow --exclude .git . ~ | fzf --preview "$preview_cmd")
  else
    file=$(find ~ -type f 2>/dev/null | fzf --preview "$preview_cmd")
  fi
  [[ -n "$file" ]] && $EDITOR "$file" >/dev/null 2>&1 &
}





