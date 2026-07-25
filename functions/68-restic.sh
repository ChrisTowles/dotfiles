# restic - Encrypted, deduplicating backups
# https://restic.net/
#
# Backs up ~/.claude/projects (Claude Code session transcripts).
# See docs/linux-setup-notes.md#restic.

# Where the backup lives. Deliberately has NO default: session transcripts hold
# whatever you were working on, so the destination is a per-machine decision —
# work sessions don't belong in a personal repo, or the other way round. Set it
# in ~/.zshrc_local.sh, which is untracked and never follows this repo onto
# another machine:
#   export CLAUDE_BACKUP_REPO="$HOME/backups/claude-sessions"
# Left unset, setup backs up nothing and every cbk command refuses to run.
export CLAUDE_BACKUP_PASSFILE="${CLAUDE_BACKUP_PASSFILE:-$HOME/.config/restic/claude-sessions.pass}"

_CLAUDE_BACKUP_UNSET_MSG='CLAUDE_BACKUP_REPO is not set — Claude session backups are OFF.
     Session transcripts follow whatever you work on, so pick the destination
     yourself (work sessions do not belong in a personal repo, or vice versa)
     and add it to ~/.zshrc_local.sh:
       export CLAUDE_BACKUP_REPO="/path/you/chose/claude-sessions"'

if [[ "$DOTFILES_SETUP" -eq 1 ]] && [[ -z "$CLAUDE_BACKUP_REPO" ]]; then
  # Nothing below is safe to guess at — no install, no key, no repo, no timer.
  DOTFILES_SETUP_MESSAGES+=("⚠️  $_CLAUDE_BACKUP_UNSET_MSG")
fi

# Setup: install restic, create the repo, install and enable the daily timer
if [[ "$DOTFILES_SETUP" -eq 1 ]] && [[ -n "$CLAUDE_BACKUP_REPO" ]]; then
  echo " Claude session backup repo: $CLAUDE_BACKUP_REPO"

  if ! command -v restic >/dev/null 2>&1; then
    echo " Installing restic..."
    case "$(uname -s)" in
      Darwin) brew install restic ;;
      Linux)
        _restic_tmp="$(mktemp -d)"
        gh release download --repo restic/restic --pattern "restic_*_linux_amd64.bz2" -D "$_restic_tmp" --clobber \
          && bunzip2 "$_restic_tmp"/restic_*_linux_amd64.bz2 \
          && sudo install "$_restic_tmp"/restic_*_linux_amd64 /usr/local/bin/restic \
          && echo " restic installed to /usr/local/bin"
        rm -rf "$_restic_tmp"
        unset _restic_tmp
        ;;
    esac
  fi

  # The password file IS the encryption key — generated once, never regenerated,
  # because a new key orphans every existing snapshot.
  if [[ ! -f "$CLAUDE_BACKUP_PASSFILE" ]]; then
    mkdir -p "$(dirname "$CLAUDE_BACKUP_PASSFILE")"
    head -c 32 /dev/urandom | base64 | tr -d '\n' > "$CLAUDE_BACKUP_PASSFILE"
    chmod 600 "$CLAUDE_BACKUP_PASSFILE"
    echo " Generated restic key at $CLAUDE_BACKUP_PASSFILE"
    DOTFILES_SETUP_MESSAGES+=("⚠️  Copy $CLAUDE_BACKUP_PASSFILE somewhere off this machine — losing it means losing every backup.")
  fi

  if command -v restic >/dev/null 2>&1 && [[ ! -f "$CLAUDE_BACKUP_REPO/config" ]]; then
    RESTIC_REPOSITORY="$CLAUDE_BACKUP_REPO" RESTIC_PASSWORD_FILE="$CLAUDE_BACKUP_PASSFILE" \
      restic init && echo " Initialized restic repo at $CLAUDE_BACKUP_REPO"
  fi

  # Daily timer (Linux only; macOS has no systemd --user). The units are written
  # from $CLAUDE_BACKUP_REPO on every setup run, so the scheduled backup can
  # never drift to a different repo than the interactive `cbk` commands.
  if [[ "$OSTYPE" != darwin* ]] && command -v systemctl >/dev/null 2>&1 && command -v restic >/dev/null 2>&1; then
    _restic_units="$HOME/.config/systemd/user"
    mkdir -p "$_restic_units"

    cat > "$_restic_units/restic-claude-sessions.service" <<EOF
[Unit]
Description=Back up Claude Code session history with restic
Documentation=https://restic.readthedocs.io/

[Service]
Type=oneshot
Nice=10
IOSchedulingClass=idle
Environment=RESTIC_REPOSITORY=$CLAUDE_BACKUP_REPO
Environment=RESTIC_PASSWORD_FILE=$CLAUDE_BACKUP_PASSFILE
ExecStart=$(command -v restic) backup %h/.claude/projects --tag claude-sessions
# Retention: dense recent history, thinning with age. --prune reclaims the space.
ExecStart=$(command -v restic) forget --tag claude-sessions --keep-daily 14 --keep-weekly 8 --keep-monthly 24 --prune
EOF

    cat > "$_restic_units/restic-claude-sessions.timer" <<'EOF'
[Unit]
Description=Daily Claude Code session backup

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=30m

[Install]
WantedBy=timers.target
EOF

    systemctl --user daemon-reload
    if systemctl --user enable --now restic-claude-sessions.timer; then
      echo " Enabled restic-claude-sessions.timer"
    else
      DOTFILES_SETUP_MESSAGES+=("⚠️  Could not enable restic-claude-sessions.timer — session backups will not run on a schedule.")
    fi
    unset _restic_units
  fi
fi

# Refuse to touch a repo the user never picked, and say why.
_cbk_ready() {
  if [[ -z "$CLAUDE_BACKUP_REPO" ]]; then
    echo "$_CLAUDE_BACKUP_UNSET_MSG" >&2
    return 1
  fi
  if ! command -v restic >/dev/null 2>&1; then
    echo "restic is not installed — run: zsh-dotfiles-setup" >&2
    return 1
  fi
}

# Run restic against the Claude session repo without exporting anything:
#   cbk snapshots | cbk check | cbk stats latest
cbk() {
  _cbk_ready || return 1
  RESTIC_REPOSITORY="$CLAUDE_BACKUP_REPO" RESTIC_PASSWORD_FILE="$CLAUDE_BACKUP_PASSFILE" \
    restic "$@"
}

# Back up now rather than waiting for the timer.
cbk-now() {
  _cbk_ready || return 1
  echo "backing up ~/.claude/projects -> $CLAUDE_BACKUP_REPO"
  cbk backup "$HOME/.claude/projects" --tag claude-sessions
}

# Restore to a temp dir — never straight over ~/.claude/projects, which would
# fight the open file handles of any live Claude Code session.
#   cbk-restore                     -> everything
#   cbk-restore '**/<uuid>.jsonl'   -> one session
cbk-restore() {
  _cbk_ready || return 1
  local target="${TMPDIR:-/tmp}/claude-restore-$(date +%s)"
  if [[ -n "$1" ]]; then
    cbk restore latest --target "$target" --include "$1"
  else
    cbk restore latest --target "$target"
  fi
  echo "restored to $target — copy back by hand"
}
