# Claude Desktop

Installation guide for Claude Desktop on PopOS/Debian-based Linux systems using the [aaddrick/claude-desktop-debian](https://github.com/aaddrick/claude-desktop-debian) community package (includes Cowork support).

## Installation

Add the apt repository and install:

```bash
# Add the GPG key
curl -fsSL https://aaddrick.github.io/claude-desktop-debian/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/claude-desktop.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/claude-desktop.gpg arch=amd64,arm64] https://aaddrick.github.io/claude-desktop-debian stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list

# Update and install
sudo apt update
sudo apt install claude-desktop
```

Updates come through normal `sudo apt upgrade`.

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
