# towles-tool (tt) — personal CLI, built from source via cargo
# https://github.com/ChrisTowles/towles-tool-rs

# tt-update - Pull and reinstall the tt CLI (Rust, crates-cli/tt-cli) from
# the primary checkout via cargo. The TS CLI (@towles/tool, bun-global) was
# uninstalled at the ttr->tt cutover (2026-07-13, see towles-tool-rs
# docs/CUTOVER.md).
tt-update() {
  local repo="$HOME/code/p/towles-tool-rs-repos/towles-tool-rs-primary"
  echo "tt $(tt --version 2>/dev/null || echo 'not installed')"
  git -C "$repo" pull --ff-only || { echo "git pull failed" >&2; return 1; }
  cargo install --path "$repo/crates-cli/tt-cli" --force || { echo "install failed" >&2; return 1; }
  echo "tt $(tt --version)"
}
