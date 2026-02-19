# Slack Desktop setup
# https://slack.com

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v slack >/dev/null 2>&1 && [[ ! -d "/Applications/Slack.app" ]]; then
    echo " Installing Slack..."
    case "$(uname -s)" in
      Darwin) brew install --cask slack ;;
      Linux)
        SLACK_URL=$(curl -s "https://slack.com/api/desktop.latestRelease?platform=linux&variant=deb&arch=x64" | jq -r .download_url)
        if [[ -z "$SLACK_URL" || "$SLACK_URL" == "null" ]]; then
          echo " Failed to fetch Slack download URL"
          return 1
        fi
        curl -fL "$SLACK_URL" -o /tmp/slack.deb
        sudo apt install -y /tmp/slack.deb
        rm -f /tmp/slack.deb
        ;;
    esac
  fi
fi
