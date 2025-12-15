#!/bin/zsh
# conf.d/50-server.zsh - HTTP server and development server utilities
# Note: serve function moved to functions/ directory

# http-server with proxy for SPA routing
alias host="http-server -P http://localhost:8080? dist"

zsh_debug_section "Server utilities setup"
