#!/usr/bin/env bash
# git-push.sh — push to this repo, handling gh account switching on macOS
set -euo pipefail

if [[ "$(uname -s)" == "Darwin" ]]; then
  gh auth switch --user ChrisTowles
  git push "$@"
  gh auth switch --user 212787373_aero
else
  git push "$@"
fi
