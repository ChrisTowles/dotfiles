#!/usr/bin/env zsh
# zsh-install-deps.zsh
# Auto-installation system for all zsh modules and their dependencies

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() { echo -e "${BLUE}ℹ ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️ ${NC} $1"; }

# OS detection
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Package manager detection
detect_package_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v brew &>/dev/null; then
        echo "brew"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Install homebrew (macOS/Linux)
install_homebrew() {
    if ! command -v brew &>/dev/null; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ "$OS" == "linux" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        else
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

# Install oh-my-zsh
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_info "Oh My Zsh already installed"
    fi
    
    # Install oh-my-zsh plugins
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        print_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        print_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    fi
    
    # zsh-z
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-z" ]]; then
        print_info "Installing zsh-z..."
        git clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z"
        print_success "zsh-z installed"
    fi
    
    # zsh-system-clipboard
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-system-clipboard" ]]; then
        print_info "Installing zsh-system-clipboard..."
        git clone https://github.com/kutsan/zsh-system-clipboard "$ZSH_CUSTOM/plugins/zsh-system-clipboard"
        print_success "zsh-system-clipboard installed"
    fi
    
    # Install spaceship theme
    if [[ "$OS" == "linux" ]]; then
        if [[ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
            print_info "Installing Spaceship theme..."
            git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
            ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
            print_success "Spaceship theme installed"
        fi
    else
        # macOS - install via brew
        if ! brew list spaceship &>/dev/null; then
            print_info "Installing Spaceship theme via Homebrew..."
            brew install spaceship
            print_success "Spaceship theme installed"
        fi
    fi
}

# Install Git and GitHub CLI
install_git_tools() {
    # Git is usually pre-installed, but ensure gh is installed
    if ! command -v gh &>/dev/null; then
        print_info "Installing GitHub CLI..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install gh
        else
            print_warning "Please install GitHub CLI manually from https://cli.github.com/"
        fi
        print_success "GitHub CLI installed"
    else
        print_info "GitHub CLI already installed"
    fi
}

# Install FZF
install_fzf() {
    if ! command -v fzf &>/dev/null; then
        print_info "Installing FZF..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install fzf -y
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install fzf
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all --no-bash --no-fish
        fi
        print_success "FZF installed"
    else
        print_info "FZF already installed"
    fi
    
    # Install FZF shell integration
    if [[ ! -f ~/.fzf.zsh ]]; then
        print_info "Setting up FZF shell integration..."
        if command -v fzf &>/dev/null; then
            $(brew --prefix)/opt/fzf/install --no-bash --no-fish 2>/dev/null || \
            /usr/share/doc/fzf/examples/install --no-bash --no-fish 2>/dev/null || \
            print_warning "FZF shell integration may need manual setup"
        fi
    fi
}

# Install Node.js tools
install_node_tools() {
    # Install NVM
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        print_success "NVM installed"
        
        # Install latest LTS Node
        print_info "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        print_success "Node.js LTS installed"
    else
        print_info "NVM already installed"
    fi
    
    # Install pnpm
    if ! command -v pnpm &>/dev/null; then
        print_info "Installing pnpm..."
        npm install -g pnpm
        print_success "pnpm installed"
    else
        print_info "pnpm already installed"
    fi
    
    # Install global npm packages
    print_info "Installing global npm packages..."
    npm install -g @antfu/ni
    npm install -g @towles/tool 2>/dev/null || print_warning "@towles/tool not found in registry"
}

# Install Python tools
install_python_tools() {
    # Install uv (Python package manager)
    if ! command -v uv &>/dev/null; then
        print_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        print_success "uv installed"
    else
        print_info "uv already installed"
    fi

}

# Install Docker
install_docker() {
    if ! command -v docker &>/dev/null; then
        print_info "Installing Docker..."
        if [[ "$OS" == "linux" ]]; then
            curl -fsSL https://get.docker.com | sh
            sudo usermod -aG docker $USER
            print_success "Docker installed"
            print_warning "You may need to log out and back in for Docker group changes to take effect"
        elif [[ "$OS" == "macos" ]]; then
            print_info "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
        fi
    else
        print_info "Docker already installed"
    fi
}

# Install Claude CLI
install_claude() {
    if ! command -v claude &>/dev/null && [[ ! -f "$HOME/.claude/local/claude" ]]; then
        print_info "Installing Claude CLI..."
        if [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install claude
        else
            # Install via script
            curl -fsSL https://storage.googleapis.com/code.mentat.ai/install.sh | sh
        fi
        print_success "Claude CLI installed"
    else
        print_info "Claude CLI already installed"
    fi
}

# Install additional CLI tools
install_cli_tools() {
    # ripgrep - use rg
    if ! command -v rg &>/dev/null; then
        print_info "Installing ripgrep..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install ripgrep -y
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install ripgrep
        fi
        print_success "ripgrep installed"
    fi
    
    # fd
    if ! command -v fd &>/dev/null; then
        print_info "Installing fd..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install fd-find -y
            # Create symlink for fd command
            sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install fd
        fi
        print_success "fd installed"
    fi
    
    # eza (modern ls)
    if ! command -v eza &>/dev/null; then
        print_info "Installing eza..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install -y gpg
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo apt update
            sudo apt install -y eza
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install eza
        fi
        print_success "eza installed"
    fi
    
    # bat (better cat)
    if ! command -v bat &>/dev/null; then
        print_info "Installing bat..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install bat -y
            # Create symlink for bat command (Ubuntu uses batcat)
            sudo ln -sf $(which batcat) /usr/local/bin/bat 2>/dev/null
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install bat
        fi
        print_success "bat installed"
    fi
    
    # jq (JSON processor)
    if ! command -v jq &>/dev/null; then
        print_info "Installing jq..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install jq -y
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install jq
        fi
        print_success "jq installed"
    fi


    # jq (JSON processor)
    if ! command -v jq &>/dev/null; then
        print_info "Installing jq..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install jq -y
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install jq
        fi
        print_success "jq installed"
    fi
}

# Install server tools
install_server_tools() {
    # live-server
    if ! command -v live-server &>/dev/null; then
        print_info "Installing live-server..."
        npm install -g live-server
        print_success "live-server installed"
    fi
}

# Interactive installation menu
interactive_install() {
    echo ""
    echo "🚀 Zsh Module Dependency Installer"
    echo "=================================="
    echo ""
    echo "Select components to install:"
    echo ""
    echo "  1) Core (Oh My Zsh, plugins, theme)"
    echo "  2) Git tools (GitHub CLI)"
    echo "  3) FZF (fuzzy finder)"
    echo "  4) Node.js tools (NVM, pnpm, global packages)"
    echo "  5) Python tools (uv)"
    echo "  6) Docker"
    echo "  7) Claude CLI"
    echo "  8) CLI tools (ripgrep, fd, eza, bat)"
    echo "  9) Server tools (live-server)"
    echo ""
    echo "  a) Install all recommended"
    echo "  c) Install all core + frequently used"
    echo "  q) Quit"
    echo ""
    
    read -r "choice?Enter your choice: "
    
    case $choice in
        1) install_oh_my_zsh ;;
        2) install_git_tools ;;
        3) install_fzf ;;
        4) install_node_tools ;;
        5) install_python_tools ;;
        6) install_docker ;;
        7) install_claude ;;
        8) install_cli_tools ;;
        9) install_server_tools ;;
        a)
            install_oh_my_zsh
            install_git_tools
            install_fzf
            install_node_tools
            install_python_tools
            install_docker
            install_claude
            install_cli_tools
            install_server_tools
            ;;
        c)
            install_oh_my_zsh
            install_git_tools
            install_fzf
            install_node_tools
            install_cli_tools
            ;;
        q) 
            print_info "Installation cancelled"
            return 0
            ;;
        *)
            print_error "Invalid choice"
            interactive_install
            ;;
    esac
    
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your shell: exec zsh"
    echo "  2. Some tools may require logout/login (Docker)"
    echo "  3. Configure git:"
    echo -e "     ${YELLOW}git config --global user.name \"Your Name\"${NC}"
    echo -e "     ${YELLOW}git config --global user.email \"you@example.com\"${NC}"
    echo -e "     ${YELLOW}git config --global core.editor \"code --wait\"${NC}"
    echo -e "     ${YELLOW}git config --global push.default current${NC}"
    echo ""
}

# Main installation function
main() {
    OS=$(detect_os)
    PKG_MANAGER=$(detect_package_manager)
    
    print_info "Detected OS: $OS"
    print_info "Detected package manager: $PKG_MANAGER"
    
    # Ensure we have a package manager
    if [[ "$PKG_MANAGER" == "unknown" ]] && [[ "$OS" != "macos" ]]; then
        print_error "No supported package manager found"
        exit 1
    fi
    
    # On macOS, ensure Homebrew is installed
    if [[ "$OS" == "macos" ]] && [[ "$PKG_MANAGER" == "unknown" ]]; then
        install_homebrew
        PKG_MANAGER="brew"
    fi
    
    # Update package manager (optional)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        print_info "Note: You may want to run 'sudo apt update' before installation"
    elif [[ "$PKG_MANAGER" == "brew" ]]; then
        print_info "Updating Homebrew..."
        brew update
    fi
    
    # Run interactive installer
    interactive_install
}

# Allow sourcing without running
# Check if script is being executed directly (not sourced)
if [[ "${(%):-%x}" == "${0}" ]] || [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi