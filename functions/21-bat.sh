# bat - A cat clone with syntax highlighting
# NOTE: cat is NOT aliased to bat — tools like Claude Code depend on plain cat output

# Setup: install bat
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v bat >/dev/null 2>&1; then
    echo " Installing bat..."
    case "$(uname -s)" in
      Darwin) brew install bat ;;
      Linux) sudo apt install -y bat ;;
    esac
  fi
fi

# On Ubuntu, bat is installed as 'batcat' — alias to 'bat'
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi

# Use bat for fzf previews
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
fi
