# i p -> cd ~/code/p, i p dotfiles -> cd ~/code/p/dotfiles
function global:i { Set-Location (Join-Path $HOME 'code' @args) }
Register-ArgumentCompleter -CommandName i -ParameterName args -ScriptBlock {
  param($cmd, $param, $word, $ast)
  $parts = @($ast.CommandElements | Select-Object -Skip 1 | ForEach-Object { $_.ToString() })
  $base = if ($parts.Count -gt 1 -or ($parts.Count -eq 1 -and -not $word)) { Join-Path $HOME 'code' $parts[0] } else { Join-Path $HOME 'code' }
  Get-ChildItem -Directory $base -ErrorAction SilentlyContinue | Where-Object Name -like "$word*" | ForEach-Object Name
}

# ii - fuzzy jump into a project directory under ~/code: ii [query]
# (ii is a built-in alias for Invoke-Item, and aliases win over functions)
Remove-Item -Force -ErrorAction SilentlyContinue Alias:ii
function global:ii {
  $code = Join-Path $HOME 'code'
  $dir = Get-ChildItem -Directory (Join-Path $code '*') -ErrorAction SilentlyContinue |
    ForEach-Object { "$($_.Parent.Name)/$($_.Name)" } |
    fzf --query "$args" --preview "eza -la --icons --color=always $code/{}"
  if ($dir) { Set-Location (Join-Path $code $dir) }
}
