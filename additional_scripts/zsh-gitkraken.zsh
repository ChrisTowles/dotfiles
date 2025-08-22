# zsh-gitkraken.zsh
# Gitkraken CLI integration (optional module)

# Gitkraken opener function
gitk() {
  dir="$(
    cd "$(dirname "$1")"
    pwd -P
  )/$(basename "$1")"
  print_step "open gitkraken to '$dir'"
  open "gitkraken://repo/$dir"
}

zsh_debug_section "Gitkraken setup"