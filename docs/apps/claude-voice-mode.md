# VoiceMode

https://github.com/mbailey/voicemode

## Installation

### Download and prepare installer

```bash
curl -O https://getvoicemode.com/install.sh
```

**Note**: The installer script requires interactive terminal access (`/dev/tty`) which may not work in all environments. If you encounter `/dev/tty` errors, you may need to run the installation manually.

### Manual Installation Steps

If the automatic installer doesn't work, follow these steps:

1. **Install missing system dependencies** (Ubuntu/WSL2):
```bash
sudo apt update
# Install core dependencies first
sudo apt install -y nodejs npm portaudio19-dev libasound2-dev cmake python3-dev

# Handle PulseAudio conflicts by installing without recommended packages
sudo apt install -y --no-install-recommends libasound2-plugins pulseaudio-utils

# Alternative if conflicts persist:
# sudo apt install -y nodejs npm portaudio19-dev libasound2-dev cmake python3-dev
```

2. **Configure Voice Mode with Claude Code**:
```bash
claude mcp add voice-mode -- uvx voice-mode
```

3. **Install Voice Mode services**:
```bash
uvx voice-mode whisper install
uvx voice-mode kokoro install  
uvx voice-mode livekit install
```

### Installation Notes

- The installer detected Ubuntu 22.04 on x86_64 (WSL2)
- UV/UVX is already installed
- Python 3.12.11 is available
- Some system dependencies were missing: nodejs, npm, portaudio19-dev, libasound2-dev
- Voice Mode configuration was skipped during automated install

### Troubleshooting

**PulseAudio conflicts**: If you encounter dependency conflicts with PulseAudio packages, try:
1. Skip PulseAudio packages initially and install core dependencies only
2. Use `--no-install-recommends` flag to avoid conflicting packages
3. Install PulseAudio separately if needed for audio functionality

**Missing ALSA headers**: The error `alsa/asoundlib.h: No such file or directory` indicates missing ALSA development headers. Install with:
```bash
sudo apt install -y libasound2-dev
```