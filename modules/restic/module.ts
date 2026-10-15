import { chmodSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { randomBytes } from "node:crypto";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { defineModule } from "../../lib/module";
import type { Ctx } from "../../lib/types";

// restic - encrypted, deduplicating backups (https://restic.net/) of
// ~/.claude/projects (Claude Code session transcripts). See docs/linux-setup-notes.md#restic.
//
// CLAUDE_BACKUP_REPO deliberately has NO default: transcripts hold whatever you
// worked on, so the destination is a per-machine decision. Set it in
// ~/.zshrc_local.sh. Left unset, setup backs up nothing and every cbk command refuses.

const UNSET = `CLAUDE_BACKUP_REPO is not set — Claude session backups are OFF.
     Session transcripts follow whatever you work on, so pick the destination
     yourself (work sessions do not belong in a personal repo, or vice versa)
     and add it to ~/.zshrc_local.sh:
       export CLAUDE_BACKUP_REPO="/path/you/chose/claude-sessions"`;

const repo = () => process.env.CLAUDE_BACKUP_REPO;
const passfile = (home: string) => process.env.CLAUDE_BACKUP_PASSFILE ?? join(home, ".config", "restic", "claude-sessions.pass");

/** Run restic against the session repo without exporting anything. */
async function cbk(ctx: Ctx, args: string[]): Promise<number> {
  const r = repo();
  if (!r) return console.error(UNSET), 1;
  if (!ctx.has("restic")) return console.error("restic is not installed — run: ttd setup restic"), 1;
  return ctx.exec(["restic", ...args], { env: { RESTIC_REPOSITORY: r, RESTIC_PASSWORD_FILE: passfile(ctx.home) } });
}

const SERVICE = (restic: string, r: string, pass: string) => `[Unit]
Description=Back up Claude Code session history with restic
Documentation=https://restic.readthedocs.io/

[Service]
Type=oneshot
Nice=10
IOSchedulingClass=idle
Environment=RESTIC_REPOSITORY=${r}
Environment=RESTIC_PASSWORD_FILE=${pass}
ExecStart=${restic} backup %h/.claude/projects --tag claude-sessions
# Retention: dense recent history, thinning with age. --prune reclaims the space.
ExecStart=${restic} forget --tag claude-sessions --keep-daily 14 --keep-weekly 8 --keep-monthly 24 --prune
`;

const TIMER = `[Unit]
Description=Daily Claude Code session backup

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=30m

[Install]
WantedBy=timers.target
`;

export default defineModule({
  id: "restic",
  needs: ["gh"],
  install: {
    linux: { via: "gh-release", repo: "restic/restic", asset: "restic_*_linux_amd64.bz2", bins: ["restic"] },
    darwin: { via: "brew", pkg: "restic" },
    win32: { via: "winget", id: "restic.restic" },
  },
  env: { CLAUDE_BACKUP_PASSFILE: "~/.config/restic/claude-sessions.pass" },
  commands: {
    cbk: { desc: "restic against the Claude session repo (cbk snapshots | check | stats latest)", args: "<restic args>", run: cbk },
    "cbk-now": {
      desc: "Back up ~/.claude/projects now rather than waiting for the timer",
      async run(ctx) {
        if (repo()) console.log(`backing up ~/.claude/projects -> ${repo()}`);
        return cbk(ctx, ["backup", join(ctx.home, ".claude", "projects"), "--tag", "claude-sessions"]);
      },
    },
    "cbk-restore": {
      // Never straight over ~/.claude/projects — that fights live sessions' open files
      desc: "Restore the latest snapshot to a temp dir (optionally one '**/<uuid>.jsonl')",
      args: "[include-glob]",
      async run(ctx, [include]) {
        const target = join(tmpdir(), `claude-restore-${Math.floor(Date.now() / 1000)}`);
        const code = await cbk(ctx, ["restore", "latest", "--target", target, ...(include ? ["--include", include] : [])]);
        if (code === 0) console.log(`restored to ${target} — copy back by hand`);
        return code;
      },
    },
  },
  async setup(ctx) {
    const r = repo();
    // Nothing is safe to guess at without a repo — no key, no repo, no timer.
    if (!r) return ctx.notice(`⚠️  ${UNSET}`);
    ctx.log(`Claude session backup repo: ${r}`);
    const pass = passfile(ctx.home);

    // The password file IS the encryption key — generated once, never
    // regenerated, because a new key orphans every existing snapshot.
    if (!existsSync(pass) && !ctx.dryRun) {
      mkdirSync(dirname(pass), { recursive: true });
      writeFileSync(pass, randomBytes(32).toString("base64"));
      chmodSync(pass, 0o600);
      ctx.log(`generated restic key at ${pass}`);
      ctx.notice(`⚠️  Copy ${pass} somewhere off this machine — losing it means losing every backup.`);
    }
    if (!existsSync(join(r, "config"))) await ctx.exec(["restic", "init"], { env: { RESTIC_REPOSITORY: r, RESTIC_PASSWORD_FILE: pass } });

    // Daily timer: Linux only (no systemd --user on macOS; no scheduled task on Windows).
    // Rewritten from CLAUDE_BACKUP_REPO each run, so it never drifts from the cbk commands.
    const restic = Bun.which("restic");
    if (ctx.os !== "linux" || !ctx.has("systemctl") || !restic) return;
    const units = join(ctx.home, ".config", "systemd", "user");
    await ctx.write(join(units, "restic-claude-sessions.service"), SERVICE(restic, r, pass));
    await ctx.write(join(units, "restic-claude-sessions.timer"), TIMER);
    await ctx.exec(["systemctl", "--user", "daemon-reload"]);
    if ((await ctx.exec(["systemctl", "--user", "enable", "--now", "restic-claude-sessions.timer"])) !== 0)
      ctx.notice("⚠️  Could not enable restic-claude-sessions.timer — session backups will not run on a schedule.");
  },
});
