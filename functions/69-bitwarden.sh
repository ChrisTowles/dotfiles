# bitwarden - password manager CLI (https://bitwarden.com/help/cli/)
# Linux only. On macOS install it yourself with `brew install bitwarden-cli`.

if [[ "$DOTFILES_SETUP" -eq 1 && "$(uname -s)" == "Linux" ]]; then
  if ! command -v bw >/dev/null 2>&1; then
    echo " Installing Bitwarden CLI..."
    # bitwarden/clients ships browser/desktop/web releases from the same repo,
    # so resolve the newest cli-v* tag rather than trusting "latest"
    _bw_tag=$(gh release list --repo bitwarden/clients --limit 60 \
      --json tagName --jq '[.[] | select(.tagName | startswith("cli-v"))][0].tagName')
    if [[ -z "$_bw_tag" ]]; then
      echo " Failed to resolve the latest Bitwarden CLI release"
    else
      # asset name is bw-linux-<version>.zip — match it exactly so the
      # arm64 and -oss variants don't get pulled in too
      _bw_zip="/tmp/bw-linux-${_bw_tag#cli-v}.zip"
      rm -f "$_bw_zip" /tmp/bw
      if gh release download "$_bw_tag" --repo bitwarden/clients \
          --pattern "bw-linux-${_bw_tag#cli-v}.zip" -D /tmp \
        && unzip -qo "$_bw_zip" bw -d /tmp; then
        sudo install /tmp/bw /usr/local/bin/bw
      else
        echo " Failed to install Bitwarden CLI from $_bw_tag"
      fi
      rm -f "$_bw_zip" /tmp/bw
    fi
    unset _bw_tag _bw_zip
  fi

  # Generate zsh completions
  if command -v bw >/dev/null 2>&1; then
    echo " Generating Bitwarden CLI completions..."
    bw completion --shell zsh > ~/.zsh/completions/_bw
  fi
fi
