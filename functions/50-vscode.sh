# vscode - VS Code Insiders setup

# Setup: install VS Code Insiders
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v code-insiders >/dev/null 2>&1; then
    echo " Installing VS Code Insiders..."
    case "$(uname -s)" in
      Darwin) brew install --cask visual-studio-code-insiders ;;
      Linux)
        curl -fL "https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-x64" -o /tmp/code-insiders.deb
        sudo apt install -y /tmp/code-insiders.deb
        rm -f /tmp/code-insiders.deb
        ;;
    esac
  fi

  # Symlink keybindings.json
  local config_src="${0:a:h}/../config"
  case "$(uname -s)" in
    Darwin)
      local keybindings_dir="$HOME/Library/Application Support/Code - Insiders/User"
      local src="$config_src/vscode/mac/keybindings.json"
      ;;
    Linux)
      local keybindings_dir="$HOME/.config/Code - Insiders/User"
      local src="$config_src/vscode/linux/keybindings.json"
      ;;
  esac
  if [[ -f "$src" ]]; then
    echo " Linking VS Code keybindings..."
    mkdir -p "$keybindings_dir"
    local dest="$keybindings_dir/keybindings.json"
    # Back up existing file if it's not already a symlink
    if [[ -f "$dest" && ! -L "$dest" ]]; then
      echo " Backing up existing keybindings.json"
      mv "$dest" "$dest.$(date +%Y%m%d).bak"
    fi
    ln -sf "$src" "$dest"
  fi
fi

alias code='code-insiders'