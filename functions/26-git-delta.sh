# delta - Syntax-highlighted git diffs
# https://github.com/dandavison/delta

# Setup: install delta and configure git to use it
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v delta >/dev/null 2>&1; then
    echo " Installing delta..."
    cargo install git-delta
  fi

  # Configure git to use delta as pager
  if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global merge.conflictstyle zdiff3
    echo " Git configured to use delta"
  fi
fi

# diff two files with syntax highlighting: dif file1 file2
if command -v delta >/dev/null 2>&1; then
  alias dif='delta'
fi
