# Linux Setup Notes

Pop!_OS 24.04 LTS
Wayland

## Apps

- [Chrome](https://www.google.com/chrome/)
- [Warp Terminal](https://www.warp.dev/) - AI-powered terminal
- [VS Code Insiders](https://code.visualstudio.com/insiders/)
  - Login and sync with GitHub account
- [Claude Code](https://claude.ai/code) - `npm install -g @anthropic-ai/claude-code`
- [GitHub CLI](https://cli.github.com/) - `sudo apt install gh`

## Screenshot Shortcut

Change shortcut to take screenshot: Settings > Keyboard > Custom Shortcuts

![](docs/images/keybinding-set-take-screenshot.png)




sudo update-alternatives --set editor /usr/bin/code-insiders

## USB Switch Keyboard Fix

If using a USB switch (KVM), the keyboard may stop responding after extended uptime due to Linux USB autosuspend.

Disable autosuspend permanently via kernelstub (Pop!_OS):

```bash
sudo kernelstub -a "usbcore.autosuspend=-1"
```

Verify it was applied:

```bash
sudo kernelstub --print-config
# Should show usbcore.autosuspend=-1 in Kernel Boot Options
```

Takes effect after next reboot.