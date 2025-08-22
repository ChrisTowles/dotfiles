# zsh-01-oh-my-zsh.zsh
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

# Theme setup
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
  # ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
  ZSH_THEME="spaceship"
else
  # `brew install spaceship` better than git clone, due to remembering to update
  source "/opt/homebrew/opt/spaceship/spaceship.zsh" "$ZSH_CUSTOM/themes/spaceship-prompt"
fi

zsh_debug_section "Theme setup"

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
  zsh-syntax-highlighting
  zsh-system-clipboard # copy and paste commands in zsh with the buffer from os clipboard, use  zle -al to see all key bindings actions
  zsh-z #  jump quickly to directories that you have visited frequently
)

zsh_debug_section "Plugin configuration"

# Enable option-stacking for docker autocomplete
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Fix slowness of pastes with zsh-syntax-highlighting.zsh
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Ensure modules are still available after Oh My Zsh loads
zmodload zsh/zle 2>/dev/null
zmodload zsh/parameter 2>/dev/null

zsh_debug_section "Oh-my-zsh loading"