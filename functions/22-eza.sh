################################################
#   eza (modern ls replacement)
################################################

# Setup: install eza
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v eza >/dev/null 2>&1; then
    echo " Installing eza..."
    cargo install eza
  fi

  # cargo install doesn't ship completions — fetch from the eza repo
  echo " Fetching eza completions..."
  curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza \
    -o ~/.zsh/completions/_eza || true
fi

if command -v eza >/dev/null 2>&1; then
  # Long list with hidden files, dirs first, git status column
  # --icons=auto only emits icons on a tty, so piped output stays clean
  alias ls='eza -la --group-directories-first --git --icons=auto'

  # Tree view with optional depth: lt [depth] (default 2)
  lt() {
    eza --tree --level="${1:-2}" --group-directories-first --icons=auto --git-ignore
  }
else
  alias ls='ls -al'
fi

# Fuzzy-filter files under the current dir, open pick in $EDITOR: lsf [query]
lsf() {
  local file preview_cmd
  if command -v bat >/dev/null 2>&1; then
    preview_cmd='bat --color=always --style=numbers --line-range=:200 {}'
  else
    preview_cmd='head -100 {}'
  fi
  if command -v fd >/dev/null 2>&1; then
    file=$(fd --type f --hidden --follow ${=_FD_EXCLUDES} | fzf --query "$*" --preview "$preview_cmd")
  else
    file=$(find . -type f 2>/dev/null | fzf --query "$*" --preview "$preview_cmd")
  fi
  # ${(z)...}: $EDITOR carries flags ("code-insiders --wait"); zsh doesn't
  # word-split unquoted params, so it would be run as one command name.
  [[ -n "$file" ]] && ${(z)EDITOR} "$file" >/dev/null 2>&1 &
}
