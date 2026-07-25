# Linux Setup Notes

Pop!_OS 24.04 LTS
Wayland

## Apps

- [Chrome](https://www.google.com/chrome/)
- [Warp Terminal](https://www.warp.dev/) - AI-powered terminal
- [VS Code Insiders](https://code.visualstudio.com/insiders/)
  - Login and sync with GitHub account
- [Claude Code](https://claude.ai/code) - `npm install -g @anthropic-ai/claude-code`
- [GitHub CLI](https://cli.github.com/) - `sudo apt install gh`
- [restic](https://restic.net/) - encrypted, deduplicating backups - see [restic](#restic)

## Screenshot Shortcut

Change shortcut to take screenshot: Settings > Keyboard > Custom Shortcuts

![](docs/images/keybinding-set-take-screenshot.png)




sudo update-alternatives --set editor /usr/bin/code-insiders

## USB Switch Keyboard Fix

If using a USB switch (KVM), the keyboard may stop responding after extended uptime due to Linux USB autosuspend.

Disable autosuspend permanently via kernelstub (Pop!_OS):

```bash
sudo kernelstub -a "usbcore.autosuspend=-1"
```

Verify it was applied:

```bash
sudo kernelstub --print-config
# Should show usbcore.autosuspend=-1 in Kernel Boot Options
```

Takes effect after next reboot.

## restic

Encrypted, deduplicating backups of `~/.claude/projects` (Claude Code session
transcripts). Managed by `functions/68-restic.sh`.

**Pick the destination first — setup does nothing until you do.** Session
transcripts contain whatever you were working on, so a work machine and a
personal machine must not share a repo. Add the choice to `~/.zshrc_local.sh`
(untracked, per-machine — on this box it's a symlink into the toolbox repo):

```bash
# personal machine — transcripts go to the personal toolbox repo
export CLAUDE_BACKUP_REPO="$HOME/code/p/toolbox/backups/claude-sessions"
```

Then run `zsh-dotfiles-setup`. It installs restic, generates the encryption key
at `~/.config/restic/claude-sessions.pass`, initializes the repo, and installs +
enables a daily systemd user timer (`restic-claude-sessions.timer`) pointed at
that same repo.

⚠️ **Copy the password file off the machine.** It *is* the encryption key —
lose it and every snapshot is unreadable.

Commands:

```bash
cbk snapshots        # any restic subcommand against the repo
cbk check            # verify repo integrity
cbk-now              # back up now instead of waiting for the timer
cbk-restore          # restore everything to a temp dir
cbk-restore '**/<uuid>.jsonl'   # restore one session

systemctl --user list-timers restic-claude-sessions.timer
journalctl --user -u restic-claude-sessions.service -n 50
```

Retention (applied by the timer): 14 daily, 8 weekly, 24 monthly.

Restores always land in a temp dir, never over `~/.claude/projects` — copying
back over a live session's open file handles corrupts it.