# Claude Desktop

Installation guide for Claude Desktop on PopOS/Debian-based Linux systems.

## Installation

### Method 1: Pre-built .deb Package (Recommended)

Download the latest release from [claude-desktop-debian releases](https://github.com/aaddrick/claude-desktop-debian/releases):

```bash

echo "Fetching latest release info..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest")
VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | contains(\"${ARCH}.deb\")) | .browser_download_url")

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find .deb package for ${ARCH}"
    exit 1
fi

echo "Latest version: ${VERSION}"
echo "Downloading from: ${DOWNLOAD_URL}"

cd "$TEMP_DIR"
curl -L -o "claude-desktop_${VERSION}_${ARCH}.deb" "$DOWNLOAD_URL"

echo "Installing..."
sudo dpkg -i "claude-desktop_${VERSION}_${ARCH}.deb"

echo "Fixing dependencies if needed..."
sudo apt --fix-broken install -y

echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✓ Claude Desktop ${VERSION} installed successfully"

```


## Configuration

### MCP Settings Location

```bash
~/.config/Claude/claude_desktop_config.json
```

### Runtime Logs

```bash
$HOME/claude-desktop-launcher.log
```

## Requirements

- Debian-based Linux distribution (PopOS, Ubuntu, Debian, Linux Mint, MX Linux, etc.)
- Git (for building from source)
- Basic build tools (automatically installed by build script)
