#!/bin/zsh
# .zshenv: Environment file, loaded always (interactive and non-interactive)
# This is the first file zsh reads. Keep it minimal and fast.

# XDG Base Directory Specification
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Zsh-specific directories (following mattmc3/zdotdir pattern)
: ${__zsh_config_dir:=${ZDOTDIR:-$HOME/code/p/dotfiles}}
: ${__zsh_user_data_dir:=${XDG_DATA_HOME}/zsh}
: ${__zsh_cache_dir:=${XDG_CACHE_HOME}/zsh}

# Ensure directories exist
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
  done
} __zsh_{config,user_data,cache}_dir XDG_{CONFIG,CACHE,DATA,STATE}_HOME

# macOS Terminal.app session restoration fix
[[ "$OSTYPE" == darwin* ]] && export SHELL_SESSIONS_DISABLE=1

# Dotfiles path (for backward compatibility with existing scripts)
export DOTFILES_PATH="${ZDOTDIR:-$HOME/code/p/dotfiles}"

# Rust/Cargo
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)

# Dotfiles bin
[[ -d "$DOTFILES_PATH/bin" ]] && path=("$DOTFILES_PATH/bin" $path)

# Local bin (pip, pipx, lazygit, etc.)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
