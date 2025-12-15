#!/bin/zsh
# conf.d/50-docker.zsh - Docker aliases and functions

command -v docker &>/dev/null || return 0

# Docker statistics and management
alias dstats='docker stats --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.BlockIO}}\t{{.NetIO}}\t{{.PIDs}}"'
alias docker_restart="osascript -e 'quit app \"Docker\"' && open -a Docker"
alias dlist='docker ps'
alias dlistAll='docker ps -a'
alias dkill='docker kill $(docker ps -q)'
alias ddel='docker rm $(docker ps -a -q)'
alias dimgdel='docker rmi $(docker images -q)'
alias dreset='docker-compose down; docker volume prune'

zsh_debug_section "Docker setup"
