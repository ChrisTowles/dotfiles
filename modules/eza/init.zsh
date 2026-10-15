# Tree view with optional depth: lt [depth] (default 2)
lt() {
  eza --tree --level="${1:-2}" --group-directories-first --icons=auto --git-ignore
}

# Fuzzy-filter files under the current dir, open pick in $EDITOR: lsf [query]
lsf() {
  local file preview_cmd
  if (( $+commands[bat] )); then
    preview_cmd='bat --color=always --style=numbers --line-range=:200 {}'
  else
    preview_cmd='head -100 {}'
  fi
  file=$(fd --type f --hidden --follow ${=FD_EXCLUDES} | fzf --query "$*" --preview "$preview_cmd")
  # ${(z)...}: $EDITOR carries flags ("code-insiders --wait")
  [[ -n "$file" ]] && ${(z)EDITOR} "$file" >/dev/null 2>&1 &
}
