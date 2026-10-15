# Windows Setup Notes

Windows runs the same `ttd` as Linux and macOS, with PowerShell 7 (`pwsh`) as the shell and `winget` as the package manager.

## Before the install

1. Install PowerShell 7: `winget install --id Microsoft.PowerShell --exact`, then open a **pwsh** window (not Windows PowerShell 5.1).
2. Turn on **Developer Mode**: Settings > System > For developers > Developer Mode.
   Config links are real symlinks (junctions for directories), and an unelevated process can only create file symlinks with Developer Mode on. `install.ps1` stops with a message if it is off.

Then:

```powershell
irm https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.ps1 | iex
```

## What Windows gets

The rule: a tool that is not installed on the Mac is not installed on Windows either. Linux-only tools stay Linux-only.

- **Same as macOS:** fnm, pnpm, bun, uv, rust, fd, fzf (+ PSFzf key bindings), bat, eza, just, git, delta, lazygit, broot, gh, starship, nerd font, VS Code Insiders, Claude Code + Claude Desktop, aws, cloudflare, restic (no scheduled task), docker, chrome, slack, handy, tt.
- **Windows only:** zoxide (`z`), since zsh-z is a zsh plugin.
- **Off on Windows:** tmux, ghostty, karabiner (no Windows build or no need), discord, bambu, bitwarden, gws/gcloud, android/mise, cliphist, popos/keyd, sudo-askpass, granted, psql.

## Clipboard history on Ctrl+`

Windows has clipboard history built in on **Win+V** (turn it on in Settings > System > Clipboard). PowerToys Keyboard Manager maps **Ctrl+`** to Win+V, the same key as Maccy on macOS and the cliphist picker on Linux.

The mapping lives in `modules/clipboard/powertoys/default.json` and is linked to `%LOCALAPPDATA%\Microsoft\PowerToys\Keyboard Manager\default.json`. If you edit remaps in the PowerToys UI it rewrites that file in place; `ttd doctor` then shows the link as `file`. Copy your change into the repo and run `ttd setup clipboard`.

## The pwsh profile

`$PROFILE` links to `modules/pwsh/profile.ps1`. It sets PSReadLine options, regenerates `~/.cache/dotfiles/init.ps1` when a module file is newer, and dot-sources it. Per-machine overrides go in `~/.pwsh_local.ps1` (untracked).

- pwsh aliases cannot take arguments, so every alias is generated as a function. Built-in aliases with the same name (`gc`, `gp`, `gi`, `gcm`, `ls`, `ii`) are removed first.
- A `ttd` picker pick that takes arguments goes into history: press **Up** to edit it. (zsh puts it straight on the prompt.)
