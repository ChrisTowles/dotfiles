# Plannotator - Claude Code planning/annotation tool
# https://plannotator.ai

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v plannotator >/dev/null 2>&1; then
    echo " Installing plannotator..."
    curl -fsSL https://plannotator.ai/install.sh | bash
  fi
fi
