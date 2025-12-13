# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ctowles/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/ctowles/.fzf/bin"
fi

# Cache fzf zsh config to avoid module loading issues with process substitution
_fzf_cache="$HOME/.fzf-zsh-cache.zsh"
if [[ ! -f "$_fzf_cache" ]] || [[ $(fzf --version) != $(head -1 "$_fzf_cache" 2>/dev/null | sed 's/^# //') ]]; then
  echo "# $(fzf --version)" > "$_fzf_cache"
  fzf --zsh >> "$_fzf_cache"
fi
source "$_fzf_cache"
unset _fzf_cache
