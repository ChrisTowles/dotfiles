# HuggingFace CLI — model hub authentication for gated models

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v uv >/dev/null 2>&1; then
    if ! uv tool run --from huggingface_hub hf auth whoami &>/dev/null; then
      DOTFILES_SETUP_MESSAGES+=("Run 'hf-login' to authenticate with HuggingFace (needed for gated models)")
    fi
  fi
fi

hf-login() {
  uv tool run --from huggingface_hub hf auth login
}

hf-whoami() {
  uv tool run --from huggingface_hub hf auth whoami
}
