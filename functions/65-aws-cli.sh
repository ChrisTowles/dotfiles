# aws-cli - AWS CLI and SAM CLI installation, configuration and completions

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  # Install AWS CLI
  if ! command -v aws >/dev/null 2>&1; then
    echo "Installing AWS CLI..."
    case "$(uname)" in
      Darwin)
        curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o /tmp/AWSCLIV2.pkg
        sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
        rm -f /tmp/AWSCLIV2.pkg
        ;;
      Linux)
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
        unzip -qo /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install
        rm -rf /tmp/awscliv2.zip /tmp/aws
        ;;
    esac
  fi

  # Install AWS SAM CLI
  if ! command -v sam >/dev/null 2>&1; then
    echo "Installing AWS SAM CLI..."
    case "$(uname)" in
      Darwin)
        curl -fsSL "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-macos-x86_64.pkg" -o /tmp/aws-sam-cli.pkg
        sudo installer -pkg /tmp/aws-sam-cli.pkg -target /
        rm -f /tmp/aws-sam-cli.pkg
        ;;
      Linux)
        curl -fsSL "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o /tmp/aws-sam-cli.zip
        unzip -qo /tmp/aws-sam-cli.zip -d /tmp/sam-installation
        sudo /tmp/sam-installation/install
        rm -rf /tmp/aws-sam-cli.zip /tmp/sam-installation
        ;;
    esac
  fi

  # Generate AWS CLI completions
  if command -v aws_completer >/dev/null; then
    echo " Generating AWS CLI completions..."
    printf 'autoload -Uz bashcompinit && bashcompinit\ncomplete -C aws_completer aws\n' > ~/.zsh/completions/_aws
  fi
fi

# AWS aliases
# alias awsp='aws --profile'
alias assumef='assume --no-cache'

# Regenerate every local AWS profile from SSO (granted.dev).
# Backs up ~/.aws/config, then repopulates it with every account/role the SSO
# session grants, pruning generated profiles that no longer exist.
#
# Usage: granted-populate [sso-start-url]
#   Start URL / region resolve in order: argument, $AWS_SSO_START_URL /
#   $AWS_SSO_REGION (set these in ~/.zshrc_local.sh), then the first
#   sso_start_url / sso_region already in ~/.aws/config.
granted-populate() {
  if ! command -v granted >/dev/null 2>&1; then
    echo "granted not installed - see https://granted.dev" >&2
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

  local -a region_arg
  [ -n "$sso_region" ] && region_arg=(--sso-region "$sso_region")

  echo "Populating profiles from $start_url${sso_region:+ ($sso_region)}..."
  granted sso populate --prune "${region_arg[@]}" "$start_url"
}
