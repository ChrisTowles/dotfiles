# granted - AWS SSO profile switcher (https://granted.dev)

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v granted >/dev/null 2>&1; then
    echo " Installing granted..."
    case "$(uname -s)" in
      Darwin)
        brew tap common-fate/granted
        brew install granted
        ;;
      Linux)
        rm -f /tmp/granted_*_linux_x86_64.tar.gz(N)
        gh release download --repo common-fate/granted --pattern "granted_*_linux_x86_64.tar.gz" -D /tmp
        tar xzf /tmp/granted_*_linux_x86_64.tar.gz -C /tmp assume assumego granted
        sudo install /tmp/granted /tmp/assume /tmp/assumego /usr/local/bin/
        rm -f /tmp/granted /tmp/assume /tmp/assumego /tmp/granted_*_linux_x86_64.tar.gz(N)
        ;;
    esac
  fi

  # granted writes its own completions under ~/.granted/zsh_autocomplete/<cmd>/_<cmd>
  # rather than to stdout, so generate then copy into the shared completions dir
  if command -v granted >/dev/null 2>&1; then
    echo " Generating granted completions..."
    granted completion -s zsh >/dev/null 2>&1
    cp -f ~/.granted/zsh_autocomplete/granted/_granted ~/.zsh/completions/_granted 2>/dev/null
    cp -f ~/.granted/zsh_autocomplete/assume/_assume ~/.zsh/completions/_assume 2>/dev/null
  fi
fi

# `assume` must be sourced, not executed — it exports AWS_* into the current shell
alias assume="source assume"
alias assumef="assume --no-cache"

# Regenerate every local AWS profile from SSO.
# Backs up ~/.aws/config, then repopulates it with every account/role the SSO
# session grants, pruning generated profiles that no longer exist.
#
# Usage: granted-populate [sso-start-url]
#   Start URL / region resolve in order: argument, $AWS_SSO_START_URL /
#   $AWS_SSO_REGION (set these in ~/.zshrc_local.sh), then the first
#   sso_start_url / sso_region already in ~/.aws/config.
granted-populate() {
  if ! command -v granted >/dev/null 2>&1; then
    echo "granted not installed - run: DOTFILES_SETUP=1 exec zsh" >&2
    return 1
  fi

  local aws_config="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
  local start_url="${1:-$AWS_SSO_START_URL}"
  local sso_region="$AWS_SSO_REGION"

  if [ -z "$start_url" ] && [ -f "$aws_config" ]; then
    start_url=$(awk -F'=' '/^[[:space:]]*sso_start_url[[:space:]]*=/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' "$aws_config")
  fi
  if [ -z "$sso_region" ] && [ -f "$aws_config" ]; then
    sso_region=$(awk -F'=' '/^[[:space:]]*sso_region[[:space:]]*=/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' "$aws_config")
  fi

  if [ -z "$start_url" ]; then
    echo "No SSO start URL found. Pass one as an argument or set AWS_SSO_START_URL in ~/.zshrc_local.sh" >&2
    return 1
  fi

  if [ -f "$aws_config" ]; then
    local backup="$aws_config.bak.$(date +%Y%m%d%H%M%S)"
    cp "$aws_config" "$backup" || return 1
    echo "Backed up $aws_config -> $backup"
  fi

  # zsh does not word-split ${var:+...}, so build the optional flag as an array
  local -a region_arg
  [ -n "$sso_region" ] && region_arg=(--sso-region "$sso_region")

  echo "Populating profiles from $start_url${sso_region:+ ($sso_region)}..."
  granted sso populate --prune "${region_arg[@]}" "$start_url"
}
