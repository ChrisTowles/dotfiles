################################################
#   fzf (fuzzy finder)
################################################

# Ctrl+T: paste files/dirs, Ctrl+R: history, Alt+C: cd into dir
if [[ "$DOTFILES_SETUP" -eq 1 ]] ; then
  # Install fd (faster find, used by fzf)
  if ! command -v fd >/dev/null 2>&1; then
    echo " Installing fd..."
    cargo install fd-find
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    echo " Installing fzf..."
    case "$(uname -s)" in
      Darwin) brew install fzf ;;
      Linux)
        gh release download --repo junegunn/fzf --pattern "fzf-*-linux_amd64.tar.gz" -D /tmp --clobber
        tar xf /tmp/fzf-*-linux_amd64.tar.gz -C /tmp fzf
        sudo install /tmp/fzf /usr/local/bin/fzf
        rm /tmp/fzf /tmp/fzf-*-linux_amd64.tar.gz
        ;;
    esac
  fi
fi

eval "$(fzf --zsh)"

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





