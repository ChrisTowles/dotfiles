#!/bin/bash

input=$(cat)

user=$(whoami)
host=$(hostname -s)
current_dir="$(echo "$input" | jq -r '.workspace.current_dir')"
model="$(echo "$input" | jq -r '.model.display_name')"
style="$(echo "$input" | jq -r '.output_style.name')"

git_status=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo 'detached')
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git_status=" [${branch}*]"
    else
        git_status=" [${branch}]"
    fi
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


printf "${GREEN}%s@%s${NC}:${BLUE}%s${NC}%s ${YELLOW}%s${NC} (%s)" \
    "$user" "$host" "$(basename "$current_dir")" "$git_status" "$model" "$style"