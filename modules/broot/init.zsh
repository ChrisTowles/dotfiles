# `br` instead of `broot`: --outcmd has broot write a shell command (usually a
# cd) to a file, which the parent shell then evals.
br() {
  local out code cmd
  out="$(mktemp -t broot-cmd.XXXXXX)"
  broot --outcmd "$out" "$@"
  code=$?
  if [[ $code -ne 0 ]]; then
    rm -f -- "$out"
    return $code
  fi
  cmd="$(<"$out")"
  rm -f -- "$out"
  [[ -n "$cmd" ]] && eval "$cmd"
}
