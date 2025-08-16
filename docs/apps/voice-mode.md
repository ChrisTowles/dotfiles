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


### Install

See https://github.com/mbailey/voicemode

### Local TTS

Setting the Kokoro service with web interface

Visit http://0.0.0.0:8880/web/


![](../images/2025-08-16-test-local-kokoro.png)

### Local STT 

https://github.com/ggml-org/whisper.cpp

Whsiper download larger local model



```bash
cd ~/.voicemode/whisper.cpp
sh ./models/download-ggml-model.sh base.en

## Larger
sh ./models/download-ggml-model.sh large-v2 
```
Careful, if you cancel the download halfway through, I had to manually delete the file and redownload it. Due to it not validating the file had completed.

```bash
# build the project
cmake -B build
cmake --build build -j --config Release

# transcribe an audio file
./build/bin/whisper-cli -m ~/.voicemode/whisper.cpp/models/ggml-base.en.bin -f samples/jfk.wav
# output: And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.

# transcribe a with larger model
./build/bin/whisper-cli -m ~/.voicemode/whisper.cpp/models/ggml-large-v2.bin -f samples/jfk.wav
# output: And so, my fellow Americans, ask not what your country can do for you, ask what you can do for your country.

```


## 🎯 Start Your First Conversation

```python
claude "converse tell me a joke"
```

The system will:
1. **Speak** your message using TTS
2. **Listen** for your response via microphone  
3. **Transcribe** your speech to text
4. **Continue** the conversation naturally

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


### ❌ Audio device not found
**Cause**: Missing audio drivers or permissions  
**Fix**: Install `libasound2-dev portaudio19-dev` on Linux


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


## 🔗 Resources

- **Documentation**: [VoiceMode GitHub](https://github.com/mbailey/voicemode)
- **Claude Code**: [Official Docs](https://docs.anthropic.com/claude-code)
- **Support**: [GitHub Issues](https://github.com/mbailey/voicemode/issues)

---

**💡 Pro Tip**: Start with the hybrid setup using OpenAI TTS and local Whisper. Once comfortable, upgrade to full local with Kokoro GPU for maximum speed and privacy.

**🔒 Privacy Note**: Local models keep all voice data on your machine. Cloud services process audio on external servers.