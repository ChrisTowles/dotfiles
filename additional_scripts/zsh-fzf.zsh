# zsh-fzf.zsh
# FZF (fuzzy finder) configuration

# Fd-find configuration
export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_COMMAND='fd --type file --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# FZF - https://github.com/junegunn/fzf
# sudo apt remove fzf 
# most of the package managers are way out of date
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

zsh_debug_section "FZF setup"