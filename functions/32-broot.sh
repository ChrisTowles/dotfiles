# broot - Tree view + fuzzy search in one navigator
# https://dystroy.org/broot

# broot checks BROOT_CONFIG_DIR before any platform default (src/conf/mod.rs:42),
# so one env var avoids hardcoding macOS's Application Support path alongside
# Linux's ~/.config.
export BROOT_CONFIG_DIR="$DOTFILES_DIR/config/broot"

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v broot >/dev/null 2>&1; then
    echo " Installing broot..."
    case "$(uname -s)" in
      Darwin) brew install broot ;;
      Linux)  cargo install --locked broot ;;
    esac
  fi

  # On its FIRST run broot installs its own `br` function by appending a
  # `source .../launcher/bash/br` line to ~/.zshrc and ~/.bashrc - real files
  # outside this repo, which is exactly the kind of unmanaged edit dotfiles
  # exists to prevent. Declaring the launcher already installed suppresses it;
  # the `br` below is our copy, in git.
  broot --set-install-state installed >/dev/null 2>&1
fi

# `br` instead of `broot`: --outcmd has broot write a shell command (usually a
# cd) to a file, which the parent shell then evals - the reason broot ships an
# `--install` that generates this exact function. Written out here rather than
# generated so it lives in git with everything else.
function br() {
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
