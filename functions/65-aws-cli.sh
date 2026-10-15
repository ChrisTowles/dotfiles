# aws-cli - AWS CLI installation and completions

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


  # Generate AWS CLI completions
  if command -v aws_completer >/dev/null; then
    echo " Generating AWS CLI completions..."
    printf 'autoload -Uz bashcompinit && bashcompinit\ncomplete -C aws_completer aws\n' > ~/.zsh/completions/_aws
  fi
fi

# AWS aliases
# alias awsp='aws --profile'
# `assume` / `assumef` live in 64-granted.sh
