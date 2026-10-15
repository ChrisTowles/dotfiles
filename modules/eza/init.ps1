# Tree view with optional depth: lt [depth] (default 2)
function global:lt { eza --tree --level=$(if ($args[0]) { $args[0] } else { 2 }) --group-directories-first --icons=auto --git-ignore }

# Fuzzy-filter files under the current dir, open pick in $EDITOR: lsf [query]
function global:lsf {
  $file = fd --type f --hidden --follow @($env:FD_EXCLUDES -split ' ') | fzf --query "$args" --preview 'bat --color=always --style=numbers --line-range=:200 {}'
  if ($file) { Start-Process -NoNewWindow -FilePath ($env:EDITOR -split ' ')[0] -ArgumentList $file }
}
