if (Get-Module -ListAvailable PSFzf) {
  Import-Module PSFzf
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Search home directory with fzf and open in $EDITOR
function global:fh {
  $file = fd --type f --hidden --follow @($env:FD_EXCLUDES -split ' ') . $HOME | fzf --preview 'bat --color=always --style=numbers --line-range=:200 {}'
  if ($file) { Start-Process -NoNewWindow -FilePath ($env:EDITOR -split ' ')[0] -ArgumentList $file }
}

# Fuzzy-cd into a directory under the current one: zcd [query]
function global:zcd {
  $dir = fd --type d --hidden --follow @($env:FD_EXCLUDES -split ' ') | fzf --query "$args" --preview 'eza -la --icons --color=always {}'
  if ($dir) { Set-Location $dir }
}
