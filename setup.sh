#!/usr/bin/env bash
# setup.sh
# One-command setup for dotfiles with dependency installation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_info() { echo -e "${CYAN}ℹ ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️ ${NC} $1"; }
print_step() { echo -e "${PURPLE}📋${NC} $1"; }
print_header() { echo -e "${BOLD}${WHITE}$1${NC}"; }
print_subheader() { echo -e "${BOLD}${BLUE}$1${NC}"; }
print_note() { echo -e "${GRAY}💡 $1${NC}"; }

echo ""
print_header "🚀 Dotfiles Setup Script"
print_header "========================"
echo ""
print_subheader "This script will:"
echo -e "  ${PURPLE}1.${NC} Back up existing dotfiles"
echo -e "  ${PURPLE}2.${NC} Link new dotfiles" 
echo -e "  ${PURPLE}3.${NC} Install dependencies (optional)"
echo ""

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Backup existing files
backup_existing() {
    local file="$1"
    if [[ -f "$HOME/$file" ]] || [[ -d "$HOME/$file" ]]; then
        if [[ ! -L "$HOME/$file" ]]; then  # Not a symlink
            print_info "Backing up existing $file to $file.backup"
            mv "$HOME/$file" "$HOME/$file.backup"
        else
            print_info "Removing existing symlink $file"
            rm "$HOME/$file"
        fi
    fi
}

# Link dotfiles
link_dotfiles() {
    print_step "Linking dotfiles..."
    echo ""
    
    # Link .zshrc
    backup_existing ".zshrc"
    ln -sf "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
    print_success "Linked .zshrc"
    
    # Link .gitconfig if exists
    if [[ -f "$SCRIPT_DIR/.gitconfig" ]]; then
        backup_existing ".gitconfig"
        ln -sf "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
        print_success "Linked .gitconfig"
    fi
    
    # Ensure .zshrc_local.sh exists for machine-specific config
    if [[ ! -f "$HOME/.zshrc_local.sh" ]]; then
        cat > "$HOME/.zshrc_local.sh" <<'EOF'
# Machine-specific configuration
# Add any local-only settings here


EOF
        print_success "Created .zshrc_local.sh for machine-specific config"
    fi
}

# Install dependencies
install_dependencies() {
    echo ""
    print_step "Dependency Installation"
    echo -e "${CYAN}❓${NC} Install dependencies? ${GRAY}(y/n)${NC}: \c"
    read -r choice
    
    if [[ "$choice" == "y" ]]; then
        echo ""
        print_info "Starting dependency installation..."
        
        # Check if zsh is installed
        if ! command -v zsh &>/dev/null; then
            print_error "Zsh is not installed. Please install zsh first:"
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                echo -e "  ${YELLOW}sudo apt install zsh${NC}"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                echo -e "  ${YELLOW}brew install zsh${NC}"
            fi
            exit 1
        fi
        
        # Run the installer
        zsh "$SCRIPT_DIR/additional_scripts/zsh-installer.zsh"
    else
        print_warning "Skipping dependency installation"
        echo ""
        print_note "You can install dependencies later by running:"
        echo -e "  ${YELLOW}zsh $SCRIPT_DIR/additional_scripts/zsh-installer.zsh${NC}"
    fi
}

# Main setup
main() {
    # Check if running from the dotfiles directory
    if [[ ! -f "$SCRIPT_DIR/.zshrc" ]]; then
        print_error "This script must be run from the dotfiles directory"
        exit 1
    fi
    
    # Link dotfiles
    link_dotfiles
    
    echo ""
    
    # Install dependencies
    install_dependencies
    
    echo ""
    print_header "🎉 Setup Complete!"
    echo ""
    print_subheader "Next steps:"
    echo -e "  ${PURPLE}1.${NC} Set zsh as your default shell: ${YELLOW}chsh -s \$(which zsh)${NC}"
    echo -e "  ${PURPLE}2.${NC} Start a new shell: ${YELLOW}exec zsh${NC}"
    echo -e "  ${PURPLE}3.${NC} Configure git if needed:"
    echo -e "     ${YELLOW}git config --global user.name \"Your Name\"${NC}"
    echo -e "     ${YELLOW}git config --global user.email \"you@example.com\"${NC}"
    echo ""
    print_note "Useful commands after setup:"
    echo -e "  ${CYAN}zsh-setup${NC}        - Re-run this setup (recommended)"
    echo -e "  ${CYAN}zsh-install${NC}      - Install missing dependencies only"
    echo -e "  ${CYAN}zsh-check-deps${NC}   - Check what's missing"
    echo ""
    print_note "To enable optional modules, edit ${YELLOW}~/.zshrc_local.sh${NC}"
    echo ""
}

main "$@"