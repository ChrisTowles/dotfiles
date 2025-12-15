# gitk - Open Gitkraken to current repository

gitk() {
  dir="$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
  print_step "open gitkraken to '$dir'"
  open "gitkraken://repo/$dir"
}
