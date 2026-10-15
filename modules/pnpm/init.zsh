# Complete package.json script names for nr (@antfu/ni script runner)
_nr_scripts() {
  [[ -f package.json ]] || return 0
  local -a scripts
  # _describe splits entries on the first unescaped colon, so escape colons in
  # script names (claude:setup) and strip them from the command shown as the desc
  scripts=(${(f)"$(jq -r '.scripts // {} | to_entries[] | (.key | gsub(":"; "\\:")) + ":" + (.value | gsub(":"; " "))' package.json 2>/dev/null)"})
  _describe -t scripts 'package.json script' scripts
}
compdef _nr_scripts nr
