# Search home directory with fzf and open in $EDITOR
fh() {
  local file preview_cmd
  if (( $+commands[bat] )); then
    preview_cmd='bat --color=always --style=numbers --line-range=:200 {}'
  else
    preview_cmd='head -100 {}'
  fi
  file=$(fd --type f --hidden --follow ${=FD_EXCLUDES} . ~ | fzf --preview "$preview_cmd")
  # ${(z)...}: $EDITOR carries flags ("code-insiders --wait"); zsh doesn't
  # word-split unquoted params, so it would be run as one command name.
  [[ -n "$file" ]] && ${(z)EDITOR} "$file" >/dev/null 2>&1 &
}

# Fuzzy-cd into a directory under the current one: zcd [query]
# Same job as fzf's Alt+C widget, but as a command — works in any terminal and
# over ssh, where Alt may not reach the shell as a meta key.
zcd() {
  local dir preview_cmd
  if (( $+commands[eza] )); then
    preview_cmd='eza -la --icons --color=always {}'
  else
    preview_cmd='ls -la {}'
  fi
  dir=$(fd --type d --hidden --follow ${=FD_EXCLUDES} | fzf --query "$*" --preview "$preview_cmd")
  [[ -n "$dir" ]] && cd "$dir"
}
