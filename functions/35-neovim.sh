# neovim - Terminal editor with LazyVim

# Setup: install neovim and symlink config
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v nvim >/dev/null 2>&1; then
    echo " Installing neovim from GitHub releases..."
    case "$(uname -s)" in
      Darwin) brew install neovim ;;
      Linux)
        gh release download --repo neovim/neovim --pattern "nvim-linux-x86_64.tar.gz" -D /tmp --clobber
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar xzf /tmp/nvim-linux-x86_64.tar.gz -C /opt
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        rm -f /tmp/nvim-linux-x86_64.tar.gz
        ;;
    esac
  fi

  local config_src="${0:a:h}/../config/nvim"
  if [[ -d "$config_src" ]]; then
    echo " Linking neovim config..."
    mkdir -p ~/.config
    ln -sfn "$config_src" ~/.config/nvim
  fi
fi

alias v="nvim"
