# gws - Google Workspace CLI (Linux only)
# https://github.com/googleworkspace/cli
# Requires: gcloud CLI (Google Cloud SDK)

[[ "$(uname -s)" != "Linux" ]] && return

# PATH for gcloud
_gcloud_sdk_dir="$HOME/google-cloud-sdk"
if [[ -d "$_gcloud_sdk_dir/bin" ]]; then
  case ":$PATH:" in
    *":$_gcloud_sdk_dir/bin:"*) ;;
    *) export PATH="$_gcloud_sdk_dir/bin:$PATH" ;;
  esac
fi

# Setup: install gcloud SDK
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v gcloud >/dev/null 2>&1; then
    echo " Installing Google Cloud SDK..."
    if [[ ! -d "$HOME/google-cloud-sdk" ]]; then
      curl -fsSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz | tar -xz -C ~
      ~/google-cloud-sdk/install.sh --quiet --path-update=false --command-completion=false
    fi
  fi
fi

# Setup: install gws via cargo
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v gws >/dev/null 2>&1; then
    echo " Installing gws (Google Workspace CLI)..."
    cargo install --git https://github.com/googleworkspace/cli --locked
  fi

  DOTFILES_SETUP_MESSAGES+=("Run 'gws auth setup' to configure Google Workspace CLI authentication")
fi

# gcloud completions
[[ -f "$_gcloud_sdk_dir/completion.zsh.inc" ]] && source "$_gcloud_sdk_dir/completion.zsh.inc"
