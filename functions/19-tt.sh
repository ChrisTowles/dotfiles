# towles-tool (tt) — personal CLI, built from source via cargo
# https://github.com/ChrisTowles/towles-tool-rs
# See also: functions/19-tt-tmux.sh for the legacy tmux-based AgentBoard (`ttt`).

# tt-update - Pull and reinstall the tt CLI (Rust, crates-cli/tt-cli) from
# the primary checkout via cargo. The TS CLI (@towles/tool, bun-global) was
# uninstalled at the ttr->tt cutover (2026-07-13, see towles-tool-rs
# docs/CUTOVER.md); its tmux AgentBoard lives on separately as `ttt`.
tt-update() {
  local repo="$HOME/code/p/towles-tool-repos/towles-tool-rs-primary"
  echo "tt $(tt --version 2>/dev/null || echo 'not installed')"
  git -C "$repo" pull --ff-only || { echo "git pull failed" >&2; return 1; }
  cargo install --path "$repo/crates-cli/tt-cli" --force || { echo "install failed" >&2; return 1; }
  echo "tt $(tt --version)"
}

# Generate zsh completions from `tt --help` (clap; no built-in generator)
if [[ "$DOTFILES_SETUP" -eq 1 ]] && command -v tt >/dev/null 2>&1; then
  echo " Generating tt completions..."
  bun run "${0:a:h}/../config/generate-completions.ts" tt > ~/.zsh/completions/_tt
fi
