# towles-tool-tmux (ttt) — legacy tmux AgentBoard, kept as a reference example
# https://github.com/ChrisTowles/towles-tool (archived; superseded by towles-tool-rs)

# ttt-update - Pull and relink the legacy TS CLI (@towles/tool, bun-global,
# bin renamed tt -> ttt post-cutover) from the primary checkout via `bun
# link`. Provides `ttt agentboard` (tmux sidebar TUI) — `tt agentboard`
# (Rust) only manages the watched-repo list, it has no tmux TUI. See
# functions/19-tt.sh for the daily-driver `tt` CLI.
ttt-update() {
  local repo="$HOME/code/p/towles-tool-cli-repos/towles-tool-primary"
  echo "ttt $(ttt --version 2>/dev/null || echo 'not installed')"
  git -C "$repo" pull --ff-only || { echo "git pull failed" >&2; return 1; }
  (cd "$repo" && bun install && bun link) || { echo "install failed" >&2; return 1; }
  echo "ttt $(ttt --version)"
}
