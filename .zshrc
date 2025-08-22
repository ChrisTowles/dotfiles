# Modular .zshrc
# A clean, fast-loading configuration that sources modules as needed

# configure git
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"

# push the current branch and set the remote as upstream automatically every time you push
# git config --global push.default current

# Path to dotfiles
DOTFILES_PATH="$HOME/code/p/dotfiles"

# Load install helpers if in install mode
if [[ "$ZSH_INSTALL_MODE" == "1" ]]; then
    source "$DOTFILES_PATH/additional_scripts/zsh-install-helpers.zsh"
fi

# Helper function to source modules with error handling
zsh_source_module() {
    local module_path="$1"
    local module_name=$(basename "$module_path" .zsh)
    
    if [[ -f "$module_path" ]]; then
        source "$module_path"
    else
        echo "Warning: Module $module_name not found at $module_path"
    fi
}

# Core modules (always loaded)
print_success() { echo -e "\033[0;32m✅ $1\033[0m"; }
print_success "Loading Chris's Modular ZSH Profile"

# Load core modules in order
zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-00-init.zsh"
zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-01-oh-my-zsh.zsh"
zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-02-basic-aliases.zsh"

# Essential tools (loaded based on availability)
zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-git.zsh"

# FZF (if installed)
if [[ -f ~/.fzf.zsh ]] || command -v fzf &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-fzf.zsh"
fi

# GitHub CLI (if installed)
if command -v gh &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-github-cli.zsh"
fi

# Node.js tools (if any node tool is available)
if command -v node &>/dev/null || command -v pnpm &>/dev/null || [[ -d "$HOME/.nvm" ]]; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-node.zsh"
fi

# Claude Code (if installed)
if command -v claude &>/dev/null || [[ -f "$HOME/.claude/local/claude" ]]; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-claude.zsh"
fi

# Towles Tool (if installed)
if command -v towles-tool &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-towles-tool.zsh"
fi

# Optional modules (controlled by environment variables)
# Set these in ~/.zshrc_local.sh to enable:
# export ZSH_LOAD_DOCKER=1
# export ZSH_LOAD_GITKRAKEN=1
# export ZSH_LOAD_PYTHON=1
# export ZSH_LOAD_SERVER=1

if [[ "$ZSH_LOAD_DOCKER" == "1" ]] || command -v docker &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-docker.zsh"
fi

if [[ "$ZSH_LOAD_GITKRAKEN" == "1" ]]; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-gitkraken.zsh"
fi

if [[ "$ZSH_LOAD_PYTHON" == "1" ]] || command -v uv &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-python.zsh"
fi

if [[ "$ZSH_LOAD_SERVER" == "1" ]] || command -v live-server &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-server.zsh"
fi

# Key bindings (Linux only)
zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-keybindings.zsh"

# Installer aliases (always available)
alias zsh-setup='bash "$DOTFILES_PATH/setup.sh"'
alias zsh-install-deps='zsh "$DOTFILES_PATH/additional_scripts/zsh-install-deps.zsh"'
alias zsh-check-deps='zsh "$DOTFILES_PATH/additional_scripts/zsh-check-deps.zsh"'

# Load machine-specific local configuration
if [[ -f "$HOME/.zshrc_local.sh" ]]; then
    source "$HOME/.zshrc_local.sh"
    zsh_debug_section "Local scripts loading"
fi

# Final timing report
if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  local current_time=$(date +%s.%N)
  local elapsed=$(echo "$current_time - $zsh_start_time_total" | bc -l)
  print_success "$(printf "Finished: Total time took %.3f seconds" "$elapsed")"
fi

############### Anything after this auto added ################