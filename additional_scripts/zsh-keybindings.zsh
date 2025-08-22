# zsh-keybindings.zsh
# Key bindings for Linux systems (optional module)

# Key bindings for Linux only
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Fix issues with copying and pasting in terminal leaves `^[[200~` at the start of text
  # https://superuser.com/questions/1532688/pasting-required-text-into-terminal-emulator-results-in-200required-text
  printf "\e[?2004l"

  # This file contains only zsh bindings. bash bindings are in .inputrc.
  # Show all commands available in zsh for key binding: zle -al
  # More info about key bindings: https://unix.stackexchange.com/questions/116562/key-bindings-table?rq=1

  # fixes issues with copying an post in terminal leaves `^[[200~` at the start of text
  # https://superuser.com/questions/1532688/pasting-required-text-into-terminal-emulator-results-in-200required-text 
  # had issues trying to use `~/.inputrc` so using this instead
  
  # Only set keybindings if zle is available (after oh-my-zsh loads)
  if (( $+functions[zle] )); then
    bindkey "\C-v" ""
    # 2025-04-09 has issue where pasting left out some characters.. so disabling.
    #bindkey "^V" "zsh-system-clipboard-vicmd-vi-yank" 
  fi
  
  set enable-bracketed-paste off
  # this is used into combo with zsh-system-clipboard plugin above
fi

zsh_debug_section "Key bindings setup"