# gwt - pick a worktree of the repos under cwd and cd into it
function global:gwt {
  $repos = Get-ChildItem -Recurse -Depth 6 -Force -Directory -Filter .git -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch 'node_modules|\.cache' }
  $line = $repos | ForEach-Object { git -C $_.Parent.FullName worktree list 2>$null } | Sort-Object -Unique |
    fzf --header 'Select worktree (ESC to cancel)'
  if ($line) { Set-Location ($line -split '\s+')[0] }
}
