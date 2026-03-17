# lazygit - Terminal UI for Git

# Setup: install lazygit and symlink config
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v lazygit >/dev/null 2>&1; then
    echo " Installing lazygit..."
    case "$(uname -s)" in
      Darwin) brew install lazygit ;;
      Linux)
        rm -f /tmp/lazygit_*_linux_x86_64.tar.gz(N)
        gh release download --repo jesseduffield/lazygit --pattern "lazygit_*_linux_x86_64.tar.gz" -D /tmp
        tar xf /tmp/lazygit_*_linux_x86_64.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin/lazygit
        rm -f /tmp/lazygit /tmp/lazygit_*_linux_x86_64.tar.gz(N)
        ;;
    esac
  fi

  local config_src="${0:a:h}/../config/lazygit/config.yml"
  if [[ -f "$config_src" ]]; then
    echo " Linking lazygit config..."
    local config_dir
    if [[ "$(uname)" == "Darwin" ]]; then
      config_dir="$HOME/Library/Application Support/lazygit"
    else
      config_dir="$HOME/.config/lazygit"
    fi
    mkdir -p "$config_dir"
    ln -sf "$config_src" "$config_dir/config.yml"
  fi
fi

alias g="lazygit"
