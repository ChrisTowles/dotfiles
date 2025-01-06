# ghostty install PopOs - Linux

Following notes at https://ghostty.org/docs/install/build to build from source

I tried the multiple https://github.com/mkasberg/ghostty-ubuntu/releases but found none worked on Pop_OS 22.04.
sudo zig build -p /usr/local -Doptimize=ReleaseFast -Dapp-runtime=glfw

```bash
sudo zig build -p /usr/bin/ -Doptimize=ReleaseFast  -Dapp-runtime=glfw
```

needed the `-Dapp-runtime=glfw` flag to be set to run on popOS but thats a temparary fix.


