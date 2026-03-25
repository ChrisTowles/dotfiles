# ttyd - Share terminal over HTTP (used by AgentBoard for interactive attach)

# Setup: install ttyd
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v ttyd >/dev/null 2>&1; then
    echo " Installing ttyd..."
    case "$(uname -s)" in
      Darwin) brew install ttyd ;;
      Linux) sudo apt install -y ttyd ;;
    esac
  fi
fi
