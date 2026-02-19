# Docker Engine setup and completions
# https://docs.docker.com/engine/install/

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v docker >/dev/null 2>&1; then
    echo " Installing Docker Engine..."
    case "$(uname -s)" in
      Darwin) brew install --cask docker ;;
      Linux)
        # Remove old packages
        sudo apt-get remove -y -qq docker docker-engine docker.io containerd runc 2>/dev/null || true

        # Dependencies
        sudo apt-get update -qq
        sudo apt-get install -y -qq ca-certificates curl

        # Add Docker GPG key
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt-get update -qq
        sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group (avoids needing sudo)
        if ! groups "$USER" | grep -q docker; then
          sudo usermod -aG docker "$USER"
          echo " Added $USER to docker group (log out and back in to take effect)"
        fi

        # Enable and start Docker
        sudo systemctl enable docker
        sudo systemctl start docker
        ;;
    esac
  fi

  # Generate zsh completions
  if command -v docker >/dev/null 2>&1; then
    echo " Generating docker completions..."
    mkdir -p ~/.zsh/completions
    docker completion zsh > ~/.zsh/completions/_docker 2>/dev/null
  fi
fi
