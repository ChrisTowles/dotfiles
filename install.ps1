# install.ps1 - Bootstrap dotfiles on a fresh Windows machine (PowerShell 7)
# Usage: irm https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.ps1 | iex
# Installs Bun (the only prerequisite), then runs bootstrap.ts, which does the rest.
$ErrorActionPreference = 'Stop'

# Config links are real symlinks; an unelevated process can only create them with Developer Mode on.
$dev = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
if ($dev.AllowDevelopmentWithoutDevLicense -ne 1) {
  Write-Host 'Turn on Developer Mode first: Settings > System > For developers > Developer Mode. Then run this again.' -ForegroundColor Yellow
  return
}

if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
  Invoke-RestMethod https://bun.sh/install.ps1 | Invoke-Expression
  $env:PATH = (Join-Path $HOME '.bun\bin') + [IO.Path]::PathSeparator + $env:PATH
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) 'dotfiles-bootstrap.ts'
Invoke-RestMethod https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/bootstrap.ts -OutFile $tmp
bun run $tmp
Remove-Item $tmp
