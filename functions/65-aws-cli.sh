# aws-cli - AWS CLI configuration and completions

# Generate AWS CLI completions during setup
# AWS uses a completer binary, not a generated file
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v aws >/dev/null 2>&1; then
    DOTFILES_SETUP_MESSAGES+=("AWS CLI not installed — install manually: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html")
  else
    if command -v aws_completer >/dev/null; then
      echo " Generating AWS CLI completions..."
      mkdir -p ~/.zsh/completions
      printf 'autoload -Uz bashcompinit && bashcompinit\ncomplete -C aws_completer aws\n' > ~/.zsh/completions/_aws
    fi
  fi
fi

# AWS aliases
# alias awsp='aws --profile'
alias assumef='assume --no-cache'
