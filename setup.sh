#!/usr/bin/env bash
# setup.sh
# One-command setup for dotfiles using ZDOTDIR pattern (mattmc3/zdotdir style)

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
print_header "🚀 Dotfiles Setup Script (ZDOTDIR Pattern)"
print_header "==========================================="
echo ""
print_subheader "This script will:"
echo -e "  ${PURPLE}1.${NC} Create ~/.zshenv bootstrap file"
echo -e "  ${PURPLE}2.${NC} Link plugin manifest"
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

# Create bootstrap .zshenv
create_bootstrap() {
    print_step "Setting up ZDOTDIR bootstrap..."
    echo ""

    # Backup and create ~/.zshenv bootstrap
    backup_existing ".zshenv"

    cat > "$HOME/.zshenv" << EOF
#!/bin/zsh
# ~/.zshenv - Bootstrap file (only zsh file needed in \$HOME)
# Sets ZDOTDIR and sources the real .zshenv from dotfiles

export ZDOTDIR="\${ZDOTDIR:-$SCRIPT_DIR}"
[[ -f "\$ZDOTDIR/.zshenv" ]] && source "\$ZDOTDIR/.zshenv"
EOF

    print_success "Created ~/.zshenv bootstrap (ZDOTDIR=$SCRIPT_DIR)"

    # Link plugin manifest to home (needed for antidote)
    backup_existing ".zsh_plugins.txt"
    ln -sf "$SCRIPT_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
    print_success "Linked .zsh_plugins.txt"

    # Link fzf config if exists
    if [[ -f "$SCRIPT_DIR/.fzf.zsh" ]]; then
        backup_existing ".fzf.zsh"
        ln -sf "$SCRIPT_DIR/.fzf.zsh" "$HOME/.fzf.zsh"
        print_success "Linked .fzf.zsh"
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

        # Run the installer from new location
        zsh "$SCRIPT_DIR/install/install-deps.zsh"
    else
        print_warning "Skipping dependency installation"
        echo ""
        print_note "You can install dependencies later by running:"
        echo -e "  ${YELLOW}zsh-install${NC}"
    fi
}

# Main setup
main() {
    # Check if running from the dotfiles directory
    if [[ ! -f "$SCRIPT_DIR/.zshrc" ]]; then
        print_error "This script must be run from the dotfiles directory"
        exit 1
    fi

    # Create bootstrap
    create_bootstrap

    echo ""

    # Install dependencies
    install_dependencies

    echo ""
    print_header "🎉 Setup Complete!"
    echo ""
    print_subheader "Architecture:"
    echo -e "  ${CYAN}~/.zshenv${NC}          → Bootstrap (sets ZDOTDIR)"
    echo -e "  ${CYAN}ZDOTDIR${NC}            → $SCRIPT_DIR"
    echo -e "  ${CYAN}conf.d/${NC}            → Modular configuration"
    echo -e "  ${CYAN}functions/${NC}         → Autoloaded functions"
    echo -e "  ${CYAN}lib/${NC}               → Core libraries (antidote)"
    echo ""
    print_subheader "Next steps:"
    echo -e "  ${PURPLE}1.${NC} Set zsh as your default shell: ${YELLOW}chsh -s \$(which zsh)${NC}"
    echo -e "  ${PURPLE}2.${NC} Start a new shell: ${YELLOW}exec zsh${NC}"
    echo -e "  ${PURPLE}3.${NC} Configure git if needed:"
    echo -e "     ${YELLOW}git config --global user.name \"Your Name\"${NC}"
    echo -e "     ${YELLOW}git config --global user.email \"you@example.com\"${NC}"
    echo -e "     ${YELLOW}git config --global core.editor \"code --wait\"${NC}"
    echo -e "     ${YELLOW}git config --global push.default current${NC}"
    echo ""
    print_note "Useful commands:"
    echo -e "  ${CYAN}zsh-setup${NC}        - Re-run this setup"
    echo -e "  ${CYAN}zsh-install${NC}      - Install missing dependencies"
    echo -e "  ${CYAN}zsh-check-deps${NC}   - Check what's missing"
    echo -e "  ${CYAN}zprofrc${NC}          - Profile zsh startup time"
    echo ""
    print_note "To disable a module: rename ${YELLOW}conf.d/foo.zsh${NC} → ${YELLOW}conf.d/~foo.zsh${NC}"
    echo ""
}

main "$@"
