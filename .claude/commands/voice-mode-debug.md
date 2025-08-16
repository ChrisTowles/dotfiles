
You are going to debug the current state of the voice mode and its mcp tools.

## Install

Context read https://github.com/mbailey/voicemode


## Current config
cat ~/.voicemode/.voicemode.env

## Local TTS

```bash

cd ~/.voicemode/services/kokoro
 # linux
 ./start-gpu.sh


# macOS
./start-gpu_mac.sh
```

Setting the Kokoro service with web interface

Visit http://0.0.0.0:8880/web/


![](../images/2025-08-16-test-local-kokoro.png)

## Local STT 

https://github.com/ggml-org/whisper.cpp

Whisper download larger local model

### If models are needing to be redownloaded

```bash

cd ~/.voicemode/whisper.cpp

# base.en
sh ./models/download-ggml-model.sh base.en

# Larger V2
sh ./models/download-ggml-model.sh large-v2 
```


Careful, if you cancel the download halfway through, I had to manually delete the file and redownload it. Due to it not validating the file had completed.

### Build project

```bash
# build the project
cmake -B build
cmake --build build -j --config Release

```
### Test Whishper.cpp

```bash
cd ~/.voicemode/whisper.cpp
# transcribe an audio file
./build/bin/whisper-cli -m ~/.voicemode/whisper.cpp/models/ggml-base.en.bin -f samples/jfk.wav
# output: And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.
```
