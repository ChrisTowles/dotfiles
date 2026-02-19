#!/usr/bin/env bash
# install.sh - Bootstrap dotfiles on a fresh machine
# Usage: curl -fsSL https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.sh | bash
#    or: bash install.sh  (from repo root)
set -euo pipefail

DOTFILES_REPO="https://github.com/ChrisTowles/dotfiles.git"
DOTFILES_DIR="$HOME/code/p/dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

info()  { echo -e "${BLUE}[info]${RESET}  $*"; }
ok()    { echo -e "${GREEN}[ ok ]${RESET}  $*"; }
warn()  { echo -e "${YELLOW}[warn]${RESET}  $*"; }
error() { echo -e "${RED}[error]${RESET} $*" >&2; }

# Platform detection
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux|Darwin) ;;
  *) error "Unsupported OS: $OS (only Linux and macOS are supported)"; exit 1 ;;
esac

if [[ "$OS" == "Linux" && "$ARCH" != "x86_64" ]]; then
  error "Unsupported architecture: $ARCH (only x86_64 is supported on Linux)"
  exit 1
fi

# Install a package if the command is missing
ensure_installed() {
  local cmd="$1"
  local pkg="${2:-$1}"

  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd is already installed"
    return
  fi

  info "Installing $pkg..."
  case "$OS" in
    Linux)
      sudo apt update -qq
      sudo apt install -y -qq "$pkg"
      ;;
    Darwin)
      # Xcode CLI tools provide git; brew provides everything else
      if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew is required on macOS. Install it from https://brew.sh"
        exit 1
      fi
      brew install "$pkg"
      ;;
  esac
  ok "$pkg installed"
}

ensure_installed git
ensure_installed zsh

# Clone or update the repo
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "Dotfiles repo already exists at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only
  ok "Repo updated"
else
  info "Cloning dotfiles to $DOTFILES_DIR..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  ok "Repo cloned"
fi

# Symlink .zshrc
ZSHRC_TARGET="$DOTFILES_DIR/.zshrc"

if [[ -L "$HOME/.zshrc" && "$(readlink "$HOME/.zshrc")" == "$ZSHRC_TARGET" ]]; then
  ok "~/.zshrc already symlinked to dotfiles"
elif [[ -L "$HOME/.zshrc" ]]; then
  warn "~/.zshrc points to $(readlink "$HOME/.zshrc"), replacing..."
  ln -sf "$ZSHRC_TARGET" "$HOME/.zshrc"
  ok "~/.zshrc symlink updated"
elif [[ -f "$HOME/.zshrc" ]]; then
  BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
  warn "Backing up existing ~/.zshrc to $BACKUP"
  mv "$HOME/.zshrc" "$BACKUP"
  ln -s "$ZSHRC_TARGET" "$HOME/.zshrc"
  ok "~/.zshrc symlinked (old file backed up)"
else
  ln -s "$ZSHRC_TARGET" "$HOME/.zshrc"
  ok "~/.zshrc symlinked"
fi

# Set zsh as default shell
if [[ "$(basename "$SHELL")" == "zsh" ]]; then
  ok "zsh is already the default shell"
else
  ZSH_PATH="$(which zsh)"
  info "Setting default shell to $ZSH_PATH..."
  sudo chsh -s "$ZSH_PATH" "$USER"
  ok "Default shell changed to zsh"
fi

# Run dotfiles setup (installs plugins, tools, and config symlinks)
echo ""
info "Running dotfiles setup..."
export DOTFILES_SETUP=1
exec zsh
