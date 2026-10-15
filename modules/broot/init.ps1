# `br` instead of `broot`: broot writes a command (usually a cd) for this shell to run.
function global:br {
  $out = New-TemporaryFile
  broot --outcmd $out.FullName @args
  $code = $LASTEXITCODE
  $cmd = Get-Content -Raw $out.FullName -ErrorAction SilentlyContinue
  Remove-Item $out.FullName -ErrorAction SilentlyContinue
  if ($code -eq 0 -and $cmd) { Invoke-Expression $cmd }
}
