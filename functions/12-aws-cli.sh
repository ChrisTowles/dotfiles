# aws-cli - AWS CLI configuration and completions

# Generate AWS CLI completions during setup
# AWS uses a completer binary, not a generated file
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v aws >/dev/null 2>&1; then
    echo ""
    echo "  ⚠⚠⚠  AWS CLI is NOT installed  ⚠⚠⚠"
    echo ""
    echo "  Install it manually from:"
    echo "  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    echo ""
  else
    if command -v aws_completer >/dev/null; then
      echo " Generating AWS CLI completions..."
      mkdir -p ~/.zsh/completions
      echo "autoload -Uz bashcompinit && bashcompinit\ncomplete -C aws_completer aws" > ~/.zsh/completions/_aws
    fi
  fi
fi

# AWS aliases
# alias awsp='aws --profile'
