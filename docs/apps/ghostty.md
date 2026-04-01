# Ghostty

## Known Issues

### cmd+click URLs don't work in tmux

When tmux has `mouse on`, it captures mouse events before Ghostty can handle them. Use **Cmd+Shift+Click** to open URLs inside tmux. Shift tells Ghostty to bypass tmux's mouse capture.

Plain Cmd+Click works fine outside tmux. Making it work inside tmux is an open feature request: https://github.com/ghostty-org/ghostty/issues/11573

### Right-click menu broken in tmux

The tmux right-click context menu follows the cursor and can't be used. This is a Ghostty bug where the right mouse button release event isn't properly sent to tmux: https://github.com/ghostty-org/ghostty/discussions/5362

Disabled in tmux.conf with `unbind -n MouseDown3Pane`.

## Install - PopOs Linux

Following notes at https://ghostty.org/docs/install/build to build from source

I tried the multiple https://github.com/mkasberg/ghostty-ubuntu/releases but found none worked on Pop_OS 22.04.
sudo zig build -p /usr/local -Doptimize=ReleaseFast -Dapp-runtime=glfw

```bash
sudo zig build -p /usr/bin/ -Doptimize=ReleaseFast  -Dapp-runtime=glfw
```

needed the `-Dapp-runtime=glfw` flag to be set to run on popOS but thats a temparary fix.


