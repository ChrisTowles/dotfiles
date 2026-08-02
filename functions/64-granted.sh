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
