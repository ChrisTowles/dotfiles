# Fuzzy-pick a recipe from the current justfile and run it: jf [query]
# A recipe with parameters goes into history (press Up) instead of running blind.
function global:just-fzf {
  $file = ttd just-file
  if (-not $file) { Write-Error 'No justfile found (jn <name> to create one)'; return }
  $line = just --list --unsorted --list-heading '' --list-prefix '' 2>$null |
    Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*\[' } |
    fzf --query "$args" --header "$file" --preview 'just --color always --show {1}'
  if (-not $line) { return }
  $name = ($line -split ' ')[0]
  $params = (($line.Substring($name.Length) -split '#')[0]).Trim()
  if ($params) { [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory("just $name ") }
  else { Write-Host "$ just $name"; just $name }
}
Set-Alias -Scope Global jf just-fzf
