#!/bin/bash
# Install/update Slack on Pop!_OS
set -e

echo "Fetching latest Slack version..."
SLACK_API="https://slack.com/api/desktop.latestRelease?platform=linux&variant=deb&arch=x64"
SLACK_URL=$(curl -s "$SLACK_API" | jq -r .download_url)
SLACK_VERSION=$(curl -s "$SLACK_API" | jq -r .version)

if [ -z "$SLACK_URL" ] || [ "$SLACK_URL" = "null" ]; then
    echo "Failed to fetch Slack download URL"
    exit 1
fi

echo "Downloading Slack ${SLACK_VERSION}..."
wget -q --show-progress -O /tmp/slack.deb "$SLACK_URL"

echo "Installing Slack..."
sudo apt install -y /tmp/slack.deb
rm /tmp/slack.deb

echo "Resetting desktop entry..."
sudo tee /usr/share/applications/slack.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Slack
StartupWMClass=Slack
Comment=Slack Desktop
GenericName=Slack Client for Linux
Exec=/usr/bin/slack %U
Icon=/usr/share/pixmaps/slack.png
Type=Application
StartupNotify=true
Categories=GNOME;GTK;Network;InstantMessaging;
MimeType=x-scheme-handler/slack;
EOF

update-desktop-database
pkill slack 2>/dev/null || true

echo "Done! Slack ${SLACK_VERSION} installed."
