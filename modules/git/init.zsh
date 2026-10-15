# gwt - List worktrees across all repos found under cwd (fzf); selecting one cd's into it
# Run inside a repo to list just its worktrees, or in a parent dir (e.g. ~/code) to list all
gwt() {
  local git_dirs worktrees line
  git_dirs=$(find . -maxdepth 6 \( -name node_modules -o -name .cache \) -prune -o -name .git -print 2>/dev/null)
  [[ -z "$git_dirs" ]] && { echo "No git repositories found under $(pwd)"; return 1; }
  worktrees=$(echo "$git_dirs" | while IFS= read -r gitdir; do
    git -C "$(dirname "$gitdir")" worktree list 2>/dev/null
  done | sort -u)
  [[ -z "$worktrees" ]] && { echo "No worktrees found"; return 1; }
  line=$(echo "$worktrees" | fzf --header "Select worktree (ESC to cancel)")
  [[ -z "$line" ]] && { echo "Cancelled"; return 1; }
  cd "${line%% *}" || return 1
}
