#!/usr/bin/env zsh
# zsh-check-deps.zsh
# Check which dependencies are missing for the modular zsh setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_info() { echo -e "${CYAN}ℹ ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️ ${NC} $1"; }

echo ""
echo -e "${BLUE}🔍 Dependency Check${NC}"
echo "==================="
echo ""

# Get dotfiles path
DOTFILES_PATH="${DOTFILES_PATH:-$HOME/code/p/dotfiles}"

# Check core dependencies
echo -e "${CYAN}Core Dependencies:${NC}"

# Oh My Zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh installed"
else
    print_error "Oh My Zsh missing"
fi

# Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    print_success "zsh-autosuggestions installed"
else
    print_error "zsh-autosuggestions missing"
fi

if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    print_success "zsh-syntax-highlighting installed"
else
    print_error "zsh-syntax-highlighting missing"
fi

if [[ -d "$ZSH_CUSTOM/plugins/zsh-z" ]]; then
    print_success "zsh-z installed"
else
    print_error "zsh-z missing"
fi

if [[ -d "$ZSH_CUSTOM/plugins/zsh-system-clipboard" ]]; then
    print_success "zsh-system-clipboard installed"
else
    print_error "zsh-system-clipboard missing"
fi

echo ""
echo -e "${CYAN}Command Line Tools:${NC}"

# Git tools
if command -v git &>/dev/null; then
    print_success "Git installed"
else
    print_error "Git missing"
fi

if command -v gh &>/dev/null; then
    print_success "GitHub CLI installed"
else
    print_error "GitHub CLI missing"
fi

# FZF
if command -v fzf &>/dev/null; then
    print_success "FZF installed"
else
    print_error "FZF missing"
fi

if [[ -f ~/.fzf.zsh ]]; then
    print_success "FZF shell integration installed"
else
    print_warning "FZF shell integration missing"
fi

echo ""
echo -e "${CYAN}Development Tools:${NC}"

# Node.js tools
if [[ -d "$HOME/.nvm" ]]; then
    print_success "NVM installed"
else
    print_error "NVM missing"
fi

if command -v node &>/dev/null; then
    print_success "Node.js installed ($(node --version))"
else
    print_error "Node.js missing"
fi

if command -v pnpm &>/dev/null; then
    print_success "pnpm installed"
else
    print_error "pnpm missing"
fi

# Python tools
if command -v uv &>/dev/null; then
    print_success "uv installed"
else
    print_error "uv missing"
fi

echo ""
echo -e "${CYAN}Optional Tools:${NC}"

# Docker
if command -v docker &>/dev/null; then
    print_success "Docker installed"
else
    print_warning "Docker not installed (optional)"
fi

# Claude CLI
if command -v claude &>/dev/null || [[ -f "$HOME/.claude/local/claude" ]]; then
    print_success "Claude CLI installed"
else
    print_warning "Claude CLI not installed (optional)"
fi

# Modern CLI tools
if command -v rg &>/dev/null; then
    print_success "ripgrep installed"
else
    print_warning "ripgrep not installed (optional)"
fi

if command -v fd &>/dev/null; then
    print_success "fd installed"
else
    print_warning "fd not installed (optional)"
fi

if command -v eza &>/dev/null; then
    print_success "eza installed"
else
    print_warning "eza not installed (optional)"
fi

if command -v bat &>/dev/null; then
    print_success "bat installed"
else
    print_warning "bat not installed (optional)"
fi

if command -v live-server &>/dev/null; then
    print_success "live-server installed"
else
    print_warning "live-server not installed (optional)"
fi

echo ""
echo -e "${CYAN}To install missing dependencies:${NC}"
echo -e "  ${YELLOW}zsh-setup${NC}       - Complete setup process (recommended)"
echo -e "  ${YELLOW}zsh-install${NC}     - Dependencies only"
echo ""