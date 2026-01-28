# Slack

Team communication app. Use native .deb package, not Flatpak.

## Installation (Pop!_OS Cosmic)

```bash
./fix-slack-tray.sh
```

This script:
- Downloads latest Slack from official API
- Installs via apt
- Fixes system tray icon for Cosmic/Wayland

## Manual Installation

```bash
SLACK_API="https://slack.com/api/desktop.latestRelease?platform=linux&variant=deb&arch=x64"
wget -O /tmp/slack.deb $(curl -s "$SLACK_API" | jq -r .download_url)
sudo apt install -y /tmp/slack.deb
rm /tmp/slack.deb
```

## Notes

- Requires `jq` (`sudo apt install jq`)
- The .deb install adds Slack's apt repo for future updates
- API endpoint is undocumented and may change
- Cosmic tray fix tracked at [cosmic-epoch#2733](https://github.com/pop-os/cosmic-epoch/issues/2733)
