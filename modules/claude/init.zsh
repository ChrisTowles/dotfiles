# claude-prompts — browse the skills & prompt strings baked into the Claude Code
# binary. Extractor is modules/claude/dump-prompts.ts. Dumps land in
# ~/.cache/claude-prompts/<version>/ with a `latest` symlink, and are reused
# across runs — pass -f to re-extract.
claude-prompts() {
  local ts="$DOTFILES_DIR/modules/claude/dump-prompts.ts"
  (( $+commands[fzf] )) || { echo "claude-prompts: needs fzf" >&2; return 1; }

  # first line is the header, the rest are "<relpath>\t<display>" menu rows
  local menu
  menu=$(bun run "$ts" --list "$@") || return 1
  local header=${menu%%$'\n'*} rows=${menu#*$'\n'}
  [[ -n $rows && $rows != "$header" ]] || { echo "claude-prompts: nothing extracted" >&2; return 1; }

  local dir="$HOME/.cache/claude-prompts/latest"
  local opener; opener=$(command -v xdg-open || command -v open)
  local clip; clip=$(command -v pbcopy || command -v wl-copy)

  local pick
  # --with-nth=2 both displays and searches the second field; adding --nth on top
  # would index into the already-collapsed line and match nothing.
  pick=$(print -r -- "$rows" | fzf --ansi --delimiter=$'\t' --with-nth=2 \
    --layout=reverse --height=90% --border=rounded --info=inline --tiebreak=begin --cycle \
    --header="$header"$'\n''enter open · ctrl-r re-dump · ctrl-y copy · ctrl-o folder · ctrl-/ preview' \
    --preview='bat --style=plain --color=always --language=md '"$dir"'/{1} 2>/dev/null || cat '"$dir"'/{1}' \
    --preview-window=right,58%,wrap,border-left \
    --bind='ctrl-/:toggle-preview' \
    --bind="ctrl-r:reload(bun run ${ts} --list --force | tail -n +2)" \
    ${clip:+--bind="ctrl-y:execute-silent(printf %s $dir/{1} | $clip)+abort"} \
    ${opener:+--bind="ctrl-o:execute-silent($opener $dir)+abort"})
  [[ -n $pick ]] || return 0

  # $EDITOR may carry flags ("code-insiders --wait") — ${(z)} splits it into words
  local -a editor
  editor=(${(z)${EDITOR:-$VISUAL}})
  (( ${#editor} )) || editor=(vi)
  "${editor[@]}" "$dir/${pick%%$'\t'*}"
}
