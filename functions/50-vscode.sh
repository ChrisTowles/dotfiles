# vscode - VS Code Insiders setup

# Setup: install VS Code Insiders
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v code-insiders >/dev/null 2>&1; then
    echo " Installing VS Code Insiders..."
    case "$(uname -s)" in
      Darwin) brew install --cask visual-studio-code-insiders ;;
      Linux)
        # Add Microsoft apt repository
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install -y -qq code-insiders
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