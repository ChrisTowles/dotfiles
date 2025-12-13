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
    local _zsh_mod_path="$1"
    local _zsh_mod_name=$(basename "$_zsh_mod_path" .zsh)

    if [[ -f "$_zsh_mod_path" ]]; then
        source "$_zsh_mod_path"
    else
        echo "Warning: Module $_zsh_mod_name not found at $_zsh_mod_path"
    fi
}

# Core modules (always loaded)
print_success() { echo -e "\033[0;32m✅ $1\033[0m"; }
print_success "Loading Chris's Modular ZSH Profile"

# Load core modules in order
zsh_source_module "$DOTFILES_PATH/additional_scripts/zsh-00-init.zsh"



###############################
# Antidote Plugin Manager
###############################

# Brew setup (keep before plugins)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Note: give up on brew for linux, every time its been a mistake
  # eval "$(~/.linuxbrew/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

zsh_debug_section "Brew setup"

# Completion system init (MUST be before plugins that use compdef)
autoload -Uz compinit && compinit

# Bootstrap antidote
ANTIDOTE_HOME="${ZDOTDIR:-$HOME}/.antidote"
if [[ -d "$ANTIDOTE_HOME" ]]; then
    source "$ANTIDOTE_HOME/antidote.zsh"

    # Static plugin file for fast loading
    zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
    if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
        antidote bundle < "${zsh_plugins}.txt" > "${zsh_plugins}.zsh"
    fi
    source "${zsh_plugins}.zsh"
else
    print_warning "Antidote not found. Run 'zsh-install' to install."
fi

zsh_debug_section "Antidote plugins"

# AWS CLI v2 completion (replaces OMZ aws plugin)
if command -v aws &>/dev/null; then
    autoload -Uz bashcompinit && bashcompinit
    complete -C "$(which aws_completer)" aws
fi

# Enable option-stacking for docker autocomplete
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Fix slowness of pastes with zsh-syntax-highlighting.zsh
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# Ensure modules are still available
zmodload zsh/zle 2>/dev/null
zmodload zsh/parameter 2>/dev/null

zsh_debug_section "Plugin configuration complete"

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


### Google cloud

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

############### Anything after this auto added ################

