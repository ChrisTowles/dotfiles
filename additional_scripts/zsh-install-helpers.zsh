#!/usr/bin/env zsh
# zsh-install-helpers.zsh
# Helper functions for checking and installing dependencies from modules

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running in install mode
is_install_mode() {
    [[ "$ZSH_INSTALL_MODE" == "1" ]] || [[ "$1" == "--install" ]]
}

# Prompt to install missing dependency
prompt_install() {
    local tool_name="$1"
    local install_cmd="$2"
    
    if is_install_mode; then
        echo -e "${YELLOW}⚠️ ${NC} $tool_name is not installed"
        read -r "choice?Install $tool_name? (y/n): "
        if [[ "$choice" == "y" ]]; then
            eval "$install_cmd"
            return $?
        fi
    fi
    return 1
}

# Check and optionally install a command
check_or_install() {
    local cmd_name="$1"
    local tool_name="$2"
    local install_function="$3"
    
    if ! command -v "$cmd_name" &>/dev/null; then
        if is_install_mode && [[ -n "$install_function" ]]; then
            echo -e "${YELLOW}⚠️ ${NC} $tool_name is not installed"
            if type "$install_function" &>/dev/null; then
                $install_function
            else
                echo -e "${RED}❌${NC} Install function $install_function not found"
            fi
        fi
        return 1
    fi
    return 0
}

# Module-specific installers
install_oh_my_zsh_module() {
    # Source the main installer for the function
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_oh_my_zsh
}

install_fzf_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_fzf
}

install_gh_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_git_tools
}

install_node_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_node_tools
}

install_python_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_python_tools
}

install_docker_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_docker
}

install_claude_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_claude
}

install_cli_tools_module() {
    source "$DOTFILES_PATH/additional_scripts/zsh-installer.zsh"
    install_cli_tools
}

# Check if all dependencies for a module are met
check_module_deps() {
    local module_name="$1"
    local missing_deps=()
    
    case "$module_name" in
        "oh-my-zsh")
            [[ ! -d "$HOME/.oh-my-zsh" ]] && missing_deps+=("oh-my-zsh")
            ;;
        "fzf")
            ! command -v fzf &>/dev/null && missing_deps+=("fzf")
            ;;
        "github-cli")
            ! command -v gh &>/dev/null && missing_deps+=("gh")
            ;;
        "node")
            ! command -v node &>/dev/null && missing_deps+=("node")
            ! command -v pnpm &>/dev/null && missing_deps+=("pnpm")
            ;;
        "python")
            ! command -v uv &>/dev/null && missing_deps+=("uv")
            ;;
        "docker")
            ! command -v docker &>/dev/null && missing_deps+=("docker")
            ;;
        "claude")
            ! command -v claude &>/dev/null && [[ ! -f "$HOME/.claude/local/claude" ]] && missing_deps+=("claude")
            ;;
    esac
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️ ${NC} Module $module_name has missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    return 0
}

# Export functions
export -f is_install_mode
export -f prompt_install
export -f check_or_install
export -f check_module_deps