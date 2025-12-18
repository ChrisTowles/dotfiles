# serve - Start live-server for development

serve() {
  if [[ -z $1 ]]; then
    live-server dist
  else
    live-server $1
  fi
}
