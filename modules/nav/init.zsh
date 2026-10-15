# i p -> cd ~/code/p, i p dotfiles -> cd ~/code/p/dotfiles
i() {
  cd ~/code/"$1"${2:+/"$2"} || return
}

# Tab completion for i() - completes first arg as ~/code/ subdirs, second arg as project within
_i_complete() {
  if (( CURRENT == 2 )); then
    local -a dirs
    dirs=( ~/code/*(N/:t) )
    _describe 'code directory' dirs
  elif (( CURRENT == 3 )); then
    local base_dir="$HOME/code/${words[2]}"
    if [[ -d "$base_dir" ]]; then
      local -a projects
      projects=( "$base_dir"/*(N/:t) )
      _describe 'project' projects
    fi
  fi
}
compdef _i_complete i

# ii - fuzzy jump into a project directory under ~/code: ii [query]
ii() {
  local dir preview_cmd
  if command -v eza >/dev/null 2>&1; then
    preview_cmd="eza -la --icons --color=always $HOME/code/{}"
  else
    preview_cmd="ls -la $HOME/code/{}"
  fi
  # ~/code/*/*(N/) == ~/code/<p|w|f>/<project>; trim the prefix so fzf shows "p/dotfiles"
  local -a projects
  projects=( ~/code/*/*(N/) )
  dir=$(print -rl -- ${projects#$HOME/code/} | fzf --query "$*" --preview "$preview_cmd")
  [[ -n "$dir" ]] && cd ~/code/"$dir"
}
