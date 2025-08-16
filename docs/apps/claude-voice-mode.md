# Claude Voice Mode Quick Start Guide

🎤 **Voice conversations with Claude Code** - Transform text chat into natural speech interactions using local AI models and cloud fallbacks.

[![VoiceMode](https://img.shields.io/badge/VoiceMode-v2.22.3-blue)](https://github.com/mbailey/voicemode)
[![Claude Code](https://img.shields.io/badge/Claude_Code-MCP-green)](https://docs.anthropic.com/claude-code)

## 🚀 Quick Installation

### Prerequisites
- **Linux/macOS/WSL** - Native audio support
- **Python 3.10+** - Required for voice services  
- **UV package manager** - `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Optional: NVIDIA GPU** - For faster local TTS

### One-Line Install
```bash
claude mcp add voice-mode -- uvx voice-mode
```

That's it! Voice Mode is now integrated with Claude Code.

## ⚡ Configuration Options

### Option 1: Hybrid Setup (Recommended)
**Local STT + Cloud TTS** - Best balance of speed and reliability

```bash
# 1. Install local Whisper for speech-to-text
cd ~/.voicemode/whisper.cpp && make
# 2. Set OpenAI API key for text-to-speech
# 3. Configure English language detection
```

**Performance**: ~20-25s conversation cycles  
**Cost**: $0.02/minute for TTS  
**Reliability**: High (cloud fallback)

### Option 2: Full Local (GPU Required)
**Local STT + Local TTS** - Maximum speed and privacy

```bash
# Install Kokoro TTS with GPU acceleration (Python 3.10 required)
cd ~/.voicemode/services/kokoro
python3.10 -m venv .venv-3.10
source .venv-3.10/bin/activate
./start-gpu.sh  # Downloads ~2GB CUDA packages
```

**Performance**: ~10-15s conversation cycles  
**Cost**: Free after setup  
**Requirements**: NVIDIA GPU, 3GB disk space

### Option 3: Cloud Only
**Cloud STT + Cloud TTS** - Zero setup, highest latency

```bash
# Just set OpenAI API key - no local installation needed
```

**Performance**: ~30-40s conversation cycles  
**Cost**: $0.06/minute total  
**Requirements**: Internet connection only

## 🔧 Essential Configuration

### 1. Set API Key (Required for Cloud Services)
Through Claude Code interface:
- Use `update_config` tool
- Set `OPENAI_API_KEY` to your API key

### 2. Fix Language Detection (Critical)
**Problem**: Whisper may transcribe English as Chinese/Japanese  
**Solution**: Set explicit language
- Use `update_config` tool  
- Set `VOICEMODE_WHISPER_LANGUAGE` to `"en"`
- Restart Whisper service with `service` tool

### 3. Verify Audio Setup
```bash
# Check audio dependencies automatically
# Use check_audio_dependencies tool through Claude Code
```

## 🎯 Start Your First Conversation

```python
# In Claude Code, use the converse tool:
# "Hello! Let's test voice conversation."
```

The system will:
1. **Speak** your message using TTS
2. **Listen** for your response via microphone  
3. **Transcribe** your speech to text
4. **Continue** the conversation naturally

## 🛠️ Service Management

All service management is done through Claude Code's voice-mode tools:

| Action | Tool Usage |
|--------|------------|
| **Check Status** | Use `service` tool with `action="status"` |
| **Start Service** | Use `service` tool with `action="start"` |
| **Stop Service** | Use `service` tool with `action="stop"` |
| **View Logs** | Use `service` tool with `action="logs"` |
| **Download Models** | Use `download_model` tool |

## 🐛 Common Issues & Solutions

### ❌ "All TTS providers failed"
**Cause**: No working TTS service  
**Fix**: Set OpenAI API key or install local Kokoro

### ❌ Whisper installation fails with CUDA errors  
**Cause**: Installer incorrectly detects GPU requirements  
**Fix**: Manual build with `cd ~/.voicemode/whisper.cpp && make`

### ❌ Kokoro fails with spacy compilation errors
**Cause**: Python 3.13 compatibility issue  
**Fix**: Use Python 3.10 virtual environment

### ❌ Speech transcribed in wrong language
**Cause**: Auto-detection defaulting to Chinese/Japanese  
**Fix**: Set `VOICEMODE_WHISPER_LANGUAGE="en"` and restart Whisper

### ❌ Audio device not found
**Cause**: Missing audio drivers or permissions  
**Fix**: Install `libasound2-dev portaudio19-dev` on Linux

## 📊 Performance Comparison

| Configuration | Conversation Cycle | Setup Time | Cost | Privacy |
|---------------|-------------------|------------|------|---------|
| **Hybrid** | 20-25s | 10 min | $0.02/min | Medium |
| **Full Local** | 10-15s | 30 min | Free | High |
| **Cloud Only** | 30-40s | 2 min | $0.06/min | Low |

## 🎤 Available Voices

### Local (Kokoro) - 67 voices
- `af_sky` - Clear female (recommended)
- `af_sarah` - Warm female  
- `am_adam` - Professional male

### Cloud (OpenAI) - 6 voices  
- `alloy` - Balanced neutral
- `nova` - Warm female
- `echo` - Clear male

## 📚 Advanced Features

### Voice Commands
```python
# Specify voice and provider
converse("Hello", voice="nova", tts_provider="openai")

# Adjust listening duration  
converse("Tell me more", listen_duration=60)

# Disable response waiting
converse("Goodbye!", wait_for_response=False)
```

### Multi-language Support
```python
# Spanish with appropriate voice
converse("¡Hola!", voice="ef_dora", tts_provider="kokoro")

# French with native voice
converse("Bonjour!", voice="ff_siwis", tts_provider="kokoro")
```

## 🔗 Resources

- **Documentation**: [VoiceMode GitHub](https://github.com/mbailey/voicemode)
- **Claude Code**: [Official Docs](https://docs.anthropic.com/claude-code)
- **Support**: [GitHub Issues](https://github.com/mbailey/voicemode/issues)

---

**💡 Pro Tip**: Start with the hybrid setup using OpenAI TTS and local Whisper. Once comfortable, upgrade to full local with Kokoro GPU for maximum speed and privacy.

**🔒 Privacy Note**: Local models keep all voice data on your machine. Cloud services process audio on external servers.