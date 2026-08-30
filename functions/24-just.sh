################################################
#   just (command runner) - https://just.systems
################################################

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v just >/dev/null 2>&1; then
    echo " Installing just..."
    case "$(uname -s)" in
      Darwin) brew install just ;;
      Linux)  cargo install --locked just ;;
    esac
  fi

  if command -v just >/dev/null 2>&1; then
    echo " Generating just completions..."
    just --completions zsh > ~/.zsh/completions/_just
  fi
fi

# Print the path of the justfile `just` would run from the current dir: walks
# up the tree like just does, matching its accepted names (justfile, Justfile,
# .justfile - any case). Exit 1 and print nothing when there isn't one.
just-file() {
  setopt localoptions extendedglob
  local dir="$PWD" f
  while true; do
    for f in "$dir"/(#i)justfile(N) "$dir"/(#i).justfile(N); do
      echo "$f"
      return 0
    done
    [[ "$dir" == "/" ]] && return 1
    dir="${dir:h}"
  done
}

# Fuzzy-pick a recipe from the current justfile and run it: jf [query]
# Preview shows the recipe source. Recipes that take parameters are pushed
# onto the command line (print -z) so the args can be filled in before Enter
# instead of being run blind. Ctrl+E opens the justfile in $EDITOR.
just-fzf() {
  local file line name params
  file=$(just-file) || { echo "No justfile found (jn <name> to create one)" >&2; return 1; }

  # --list-heading/--list-prefix strip the "Available recipes:" banner and
  # indentation so the line is "name params # doc"; drop the blank lines and
  # "[group]" headers that --list still emits between groups
  line=$(just --list --unsorted --list-heading '' --list-prefix '' 2>/dev/null \
    | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*\[' \
    | fzf --query "$*" \
        --header "$file  (Ctrl+E: edit)" \
        --preview "just --color always --show {1}" \
        --bind "ctrl-e:execute(${EDITOR:-vi} '$file' >/dev/null 2>&1 &)+abort") || return

  name="${line%% *}"
  params="${line#"$name"}"; params="${params%%#*}"; params="${params// /}"

  if [[ -n "$params" ]]; then
    print -z -- "just $name "
  else
    echo "$ just $name"
    just "$name"
  fi
}
alias jf='just-fzf'

# Append a recipe to the current justfile (creating ./justfile if none):
#   jn [-d "doc comment"] <name> [command...]
# Without a command the recipe gets a TODO body and opens in $EDITOR.
just-new() {
  local doc="" name body file
  if [[ "$1" == "-d" ]]; then
    doc="$2"; shift 2
  fi
  if [[ -z "$1" ]]; then
    echo "usage: jn [-d \"doc comment\"] <name> [command...]" >&2
    return 1
  fi
  name="$1"; shift
  body="$*"

  file=$(just-file) || {
    file="$PWD/justfile"
    echo " Creating $file"
    : > "$file"
  }

  if just --justfile "$file" --summary 2>/dev/null | tr ' ' '\n' | grep -qx "$name"; then
    echo "Recipe '$name' already exists in $file" >&2
    return 1
  fi

  # Blank line before the new recipe, unless the file is empty or ends with one
  if [[ -s "$file" && -n "$(tail -c 2 "$file" | tr -d '\n')" ]]; then
    printf '\n' >> "$file"
  fi
  {
    [[ -n "$doc" ]] && printf '# %s\n' "$doc"
    printf '%s:\n' "$name"
    printf '    %s\n' "${body:-echo \"TODO: $name\"}"
  } >> "$file"

  just --justfile "$file" --color always --show "$name"
  # ${(z)...}: $EDITOR carries flags ("code-insiders --wait"); zsh doesn't
  # word-split unquoted params, so it would be run as one command name.
  [[ -z "$body" ]] && ${(z)EDITOR} "$file" >/dev/null 2>&1 &
  return 0
}
alias jn='just-new'
