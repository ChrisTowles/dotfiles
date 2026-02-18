# delta - Syntax-highlighted git diffs
# https://github.com/dandavison/delta

# Setup: install delta and configure git to use it
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v delta >/dev/null 2>&1; then
    echo " Installing delta..."
    case "$(uname -s)" in
      Darwin) brew install git-delta ;;
      Linux)
        DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
        sudo apt install -y /tmp/delta.deb
        rm -f /tmp/delta.deb
        ;;
    esac
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
