# zsh-server.zsh
# HTTP server and development server utilities (optional module)

# pnpm i live-server -g
function serve() {
  if [[ -z $1 ]]; then
    live-server dist
  else
    live-server $1
  fi
}

# pnpm i http-server -g
alias host="http-server -P http://localhost:8080? dist" # proxy to self for vue routing

zsh_debug_section "Server utilities setup"