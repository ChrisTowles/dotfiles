# Claude Desktop

Installation guide for the official Claude Desktop Linux beta from Anthropic, distributed via Anthropic's own apt repository.

## Installation

Add the apt repository and install:

```bash
# Add the GPG key
sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list

# Update and install
sudo apt update && sudo apt install claude-desktop
```

Updates come through normal `sudo apt update && sudo apt upgrade`.

Launch from the applications menu, or run `claude-desktop` from a terminal.

### Verify GPG key (optional)

```bash
gpg --show-keys /usr/share/keyrings/claude-desktop-archive-keyring.asc
```

Should show fingerprint: `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`

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

- Ubuntu 22.04+ or Debian 12+, x86_64 or arm64
- Computer Use and dictation are not yet available on Linux
