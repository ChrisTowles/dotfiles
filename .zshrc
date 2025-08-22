# Modular .zshrc
# A clean, fast-loading configuration that sources modules as needed

# configure git
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"

# set code as the default editor
# git config --global core.editor "code --wait"

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



###############################
# zsh setup of oh-my-zsh
############################################
# Oh-my-zsh configuration, themes, and plugins

# Fix module path corruption that occurs during sourcing
# This is a workaround for a zsh module path issue when sourcing scripts
if [[ "$module_path" == *"/additional_scripts/"* ]]; then
    # Module path got corrupted, restore to system default
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        module_path=(/usr/lib/$(uname -m)-linux-gnu/zsh/$(zsh --version | awk '{print $2}'))
    fi
fi

# Brew setup
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Note: give up on brew for linux, every time its been a mistake
  # eval "$(~/.linuxbrew/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

zsh_debug_section "Brew setup"



#git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
#ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

ZSH_THEME="spaceship"

# Plugins configuration
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
# git clone https://github.com/kutsan/zsh-system-clipboard $ZSH_CUSTOM/plugins/zsh-system-clipboard

plugins=(
  git
  aws # auto complete for aws CLIv2
  #docker # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
  #docker-compose # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose
  # kubectl # auto complete for kubectl
  zsh-autosuggestions # suggests commands as you type based on history and completions.
  # zsh-syntax-highlighting
  zsh-system-clipboard # copy and paste commands in zsh with the buffer from os clipboard, use  zle -al to see all key bindings actions
  zsh-z #  jump quickly to directories that you have visited frequently
)

zsh_debug_section "Plugin configuration"
# Load oh-my-zsh
# NOTE: ON mac if i ever tried to loaded this from any file but `.zshrc` all kinds of issues, mainily tons of `failed to load module` spamming the console
source $ZSH/oh-my-zsh.sh

zsh_debug_section "Oh My Zsh Setup"


# # Enable option-stacking for docker autocomplete
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# # Fix slowness of pastes with zsh-syntax-highlighting.zsh
zstyle ':bracketed-paste-magic' active-widgets '.self-*'



# Ensure modules are still available after Oh My Zsh loads
zmodload zsh/zle 2>/dev/null
zmodload zsh/parameter 2>/dev/null

zsh_debug_section "Oh-my-zsh loading"

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


if command -v docker &>/dev/null; then
   zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-docker.zsh"
fi

#if command -v docker &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-gitkraken.zsh"
#fi

if command -v uv &>/dev/null; then
    zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-python.zsh"
fi



# Installer aliases (always available)
alias zsh-setup='bash "$DOTFILES_PATH/setup.sh"'
alias zsh-install='zsh "$DOTFILES_PATH/additional_scripts/zsh-install-deps.zsh"'
alias zsh-check-deps='zsh "$DOTFILES_PATH/additional_scripts/zsh-check-deps.zsh"'

# Final timing report
if [[ -n "$ZSH_DEBUG_TIMING" ]]; then
  local current_time=$(date +%s.%N)
  local elapsed=$(echo "$current_time - $zsh_start_time_total" | bc -l)
  print_success "$(printf "Finished: Total time took %.3f seconds" "$elapsed")"
fi

############### Anything after this auto added ################
. "$HOME/.local/bin/env"
