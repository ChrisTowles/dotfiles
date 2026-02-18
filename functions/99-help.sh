# help - Print all custom aliases, functions, and keybindings

_HELP_DIR="${0:a:h}/../config"
zsh-dotfiles-help() {
  bun run "$_HELP_DIR/help.ts"
}
