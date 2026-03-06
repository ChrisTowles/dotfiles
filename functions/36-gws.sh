# gws - Google Workspace CLI
# https://github.com/googleworkspace/cli
# Requires: gcloud CLI (Google Cloud SDK)

# Setup: install gcloud SDK
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v gcloud >/dev/null 2>&1; then
    echo " Installing Google Cloud SDK..."
    if [[ "$(uname)" == "Darwin" ]]; then
      brew install google-cloud-sdk
    else
      if [[ ! -d "$HOME/google-cloud-sdk" ]]; then
        curl -fsSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz | tar -xz -C ~
        ~/google-cloud-sdk/install.sh --quiet --path-update=false --command-completion=false
      fi
    fi
  fi
fi

# PATH for gcloud (Linux manual install)
if [[ -d "$HOME/google-cloud-sdk/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/google-cloud-sdk/bin:"*) ;;
    *) export PATH="$HOME/google-cloud-sdk/bin:$PATH" ;;
  esac
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
[[ -f ~/google-cloud-sdk/completion.zsh.inc ]] && source ~/google-cloud-sdk/completion.zsh.inc
