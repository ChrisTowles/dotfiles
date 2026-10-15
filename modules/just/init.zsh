# Fuzzy-pick a recipe from the current justfile and run it: jf [query]
# Preview shows the recipe source. Recipes that take parameters are pushed
# onto the command line (print -z) so the args can be filled in before Enter
# instead of being run blind. Ctrl+E opens the justfile in $EDITOR.
just-fzf() {
  local file line name params
  file=$(command ttd just-file) || { echo "No justfile found (jn <name> to create one)" >&2; return 1; }

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
