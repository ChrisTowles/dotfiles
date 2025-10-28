# Fish Shell Setup Guide

## 2025-08-15 - IMPORTANT I stopped Using fish after a week, to many issues with plugins and compatibility!


A comprehensive guide to setting up Fish shell with modern plugins and themes, similar to Oh My Zsh.

## My Experience with Fish

I explored Fish shell as an alternative to Zsh for two key reasons:

- **Copy/paste keybindings** - I use macOS at work and have rebound `Ctrl+C` and `Ctrl+V` for copy/paste in terminal. On Linux, implementing this in Zsh and Bash never works reliably. Fish is the first shell with built-in support for custom copy/paste bindings to override the default `Ctrl+C`(SIGINT) behavior.
- **Terminal startup performance** - [Oh My Zsh](https://ohmyz.sh/) was excellent but significantly slowed terminal startup time. Fish with Starship offers similar functionality with much faster startup performance.

## Quick Setup (From Dotfiles)

If you have this dotfiles repo set up:

```bash
mkdir -p ~/.config/fish

ln -s $HOME/code/p/dotfiles/.config/fish/config.fish $HOME/.config/fish/config.fish
ln -s $HOME/code/p/dotfiles/.config/fish/custom_functions $HOME/.config/fish/custom_functions

fish

# install fisher to manage plugins
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# remove new plugins file
rm -rf ~/.config/fish/fish_plugins

# link fish plugins file from dotfiles repo
ln -s $HOME/code/p/dotfiles/.config/fish/fish_plugins $HOME/.config/fish/fish_plugins
```



## Why Fish?

I'm looking for an optimal shell experience. While Zsh is excellent, each new shell session takes 5-15 seconds to start, which adds up to significant time wasted throughout the day. Fish shell is designed to be user-friendly with built-in features like syntax highlighting, intelligent autosuggestions, and a powerful plugin ecosystem. Most importantly, Fish starts up much faster than Zsh with Oh My Zsh.


## Installation

### Ubuntu/Debian
```bash
sudo apt-add-repository ppa:fish-shell/release-4
sudo apt update
sudo apt install fish
```

#### Remove Repository (if needed)
```bash
# Remove the fish-shell PPA repository
sudo apt-add-repository --remove ppa:fish-shell/release-4
sudo apt update
```

### macOS
```bash
brew install fish
```

### Set as Default Shell
```bash
# Add Fish to valid shells
echo $(which fish) | sudo tee -a /etc/shells

# Change default shell
chsh -s $(which fish)
```

## Plugin Managers

### Fisher (Recommended)
Fisher is the most popular and actively maintained plugin manager for Fish.

```bash
# Install Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

## Essential Plugins

### Core Functionality

**Autopair** - Auto-complete matching pairs
```bash
fisher install jorgebucaran/autopair.fish
```

**z** - Jump to frequently used directories
```bash
fisher install jethrokuan/z
```

**fzf.fish** - Fuzzy finder integration
```bash
# Install fzf first
brew install fzf  # macOS
sudo apt install fzf  # Ubuntu

# Then install the Fish plugin
fisher install PatrickF1/fzf.fish
```

**Bass** - Use Bash utilities in Fish
```bash
fisher install edc/bass
```

### Development Tools

**Git Plugin** - Enhanced Git integration
```bash
fisher install ramlev/git-plugin
```

**Done** - Desktop notifications for long-running commands
```bash
fisher install franciscolourenco/done
```

**Fish You Should Use** - Reminds you of aliases
```bash
fisher install paysonwallach/fish-you-should-use
```

## Prompt/Theme Options

### Starship (Cross-shell, Recommended)
Fast, customizable prompt that works across all shells.

```bash
# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Add to Fish config
echo "starship init fish | source" >> ~/.config/fish/config.fish
```

### Tide (Fish-specific)
PowerLevel10k-inspired prompt for Fish.

```bash
# Install Tide
fisher install IlanCosman/tide@v5

# Configure interactively
tide configure
```

## Configuration

### Basic Config (`~/.config/fish/config.fish`)

```fish
# Disable greeting
set fish_greeting

# Add custom paths
fish_add_path ~/.local/bin
fish_add_path ~/bin

# Set preferred editor
set -gx EDITOR nvim

# Aliases (use abbreviations instead)
abbr --add l ls -la
abbr --add g git
abbr --add gc 'git commit'
abbr --add gp 'git push'
abbr --add gs 'git status'

# Custom functions directory
set -gx fish_function_path ~/.config/fish/functions $fish_function_path
```

### Advanced Features

**Abbreviations** (better than aliases)
```fish
# Expand while typing
abbr --add gco 'git checkout'
abbr --add gcb 'git checkout -b'
```

**Functions** (create in `~/.config/fish/functions/`)
```fish
# Example: mkcd function
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end
```

## Migration from Zsh/Bash

### Environment Variables
Fish uses different syntax for environment variables:
```fish
# Bash/Zsh: export VARIABLE=value
# Fish:
set -gx VARIABLE value
```

### PATH Management
```fish
# Add to PATH
fish_add_path ~/bin

# Or manually
set -gx PATH ~/bin $PATH
```

## Useful Commands

```bash
# Update all Fisher plugins
fisher update

# List installed plugins
fisher list

# Remove plugin
fisher remove plugin-name

# Reload configuration
source ~/.config/fish/config.fish

# Fish help
help
```

## Performance Tips

- Use abbreviations instead of aliases
- Keep functions in separate files in `~/.config/fish/functions/`
- Use `fish --profile-startup` to identify slow startup items
- Consider using Starship over complex Fish-specific prompts for better performance

## Resources

- [Fish Documentation](https://fishshell.com/docs/current/)
- [Fisher Plugin Manager](https://github.com/jorgebucaran/fisher)
- [Awesome Fish](https://github.com/jorgebucaran/awsm.fish)
- [Fish Cookbook](https://github.com/jorgebucaran/cookbook.fish)



## autocomplete generations

https://github.com/adaszko/complgen?tab=readme-ov-file

```bash
cargo install --git https://github.com/adaszko/complgen --tag v0.4.0 complgen
```

Command 'cargo' not found, but can be installed with:
```bash
sudo apt  install cargo  

```



