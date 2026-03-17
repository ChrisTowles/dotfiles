# Simplify Summary — Issue #17

## Simplifications Made

1. **`.shellcheckrc`** — Moved repeated `SC1036,SC1072,SC1073,SC1009` disables (zsh `(N)` glob qualifier) from per-file comments into the global config. Removed duplicate lines from `functions/20-fzf.sh`, `functions/30-lazygit.sh`, and reduced `functions/78-clipboard-manager.sh` to only its unique codes (`SC1046,SC1047`).

2. **`functions/40-tmux.sh`** — Replaced `A && B || C` anti-pattern in `tss()` with explicit `if/fi` block. Eliminates SC2015 suppress and fixes a latent logic bug where `tmux attach` could run when `$session` is empty if `switch-client` fails.

3. **`package.json`** — Changed `lint:shell` from naming `scripts/git-push.sh` explicitly to using `scripts/*.sh` glob, consistent with the `functions/*.sh` pattern and future-proof for new scripts.

4. **`functions/60-claude-code.sh`** — SC2034/SC2086 disables kept as-is (agents suggested combining, but shellcheck directives are per-statement so original placement was already correct). No change needed.

## Verification Results

- `pnpm run lint:shell` — passes
- `pnpm run typecheck` — passes
