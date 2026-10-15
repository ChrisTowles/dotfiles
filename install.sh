#!/usr/bin/env bash
# install.sh - Bootstrap dotfiles on a fresh Linux or macOS machine
# Usage: curl -fsSL https://raw.githubusercontent.com/ChrisTowles/dotfiles/main/install.sh | bash
# Installs Bun (the only prerequisite), then runs bootstrap.ts, which does the rest.
set -euo pipefail

RAW="https://raw.githubusercontent.com/ChrisTowles/dotfiles/main"

if ! command -v bun >/dev/null 2>&1 && [[ ! -x "$HOME/.bun/bin/bun" ]]; then
  # bun's installer needs curl and unzip
  if [[ "$(uname -s)" == "Linux" ]] && ! command -v unzip >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq unzip curl
  fi
  curl -fsSL https://bun.sh/install | bash
fi
export PATH="$HOME/.bun/bin:$PATH"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$RAW/bootstrap.ts" -o "$tmp/bootstrap.ts"
bun run "$tmp/bootstrap.ts"
