# Fish shell configuration file
#./../../docs/apps/fish.md)

if status is-interactive
    # Commands to run in interactive sessions can go here
    
    # Custom key bindings for copy/paste
    # Override default Ctrl+C to copy selected text
    bind \cc fish_clipboard_copy
    
    # Add Ctrl+V for paste
    bind \cv fish_clipboard_paste
    
    # Rebind cancel-commandline to Ctrl+G as alternative
    #bind ctrl-shift-c cancel-commandline 
    
    # Clear command line with Escape key
    bind \e kill-whole-line
end


# Disable greeting
set fish_greeting

# Add custom paths
fish_add_path ~/.local/bin
fish_add_path ~/bin

fish_add_path ~/.cargo/bin

# Set preferred editor
#set -gx EDITOR nvim

# Aliases (use abbreviations instead)
    

abbr --add ls 'ls -al'

# Git abbreviations
abbr --add g git
abbr --add gc 'git commit'
abbr --add gs 'git status'
abbr --add gco 'git checkout'
abbr --add gcb 'git checkout -b'

# Additional git abbreviations
abbr --add gst 'git stash'
abbr --add grm 'git rm'
abbr --add gmv 'git mv'

# Go to project root
abbr --add grt 'cd "$(git rev-parse --show-toplevel)"'


# Add to PATH
#fish_add_path ~/bin



# Reload configuration
abbr --add source-fish 'source ~/.config/fish/config.fish'


# load starship prompt
starship init fish | source


# Custom functions directory
set -gx fish_function_path ~/.config/fish/custom_functions/ $fish_function_path

