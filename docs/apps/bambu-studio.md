# Bambu Studio on Linux

## AppImage (Recommended)

Better GPU performance than Flatpak, no sandbox issues.

```bash
# Run install script
./install/bambu-studio.sh
```

Installs to `~/.local/bin/BambuStudio.AppImage` with desktop entry.

### Manual update

Re-run `./install/bambu-studio.sh` to fetch latest version.

## Flatpak (Not recommended)

Known GPU/sandbox issues on NVIDIA systems.

```bash
flatpak install flathub com.bambulab.BambuStudio
flatpak run com.bambulab.BambuStudio
```

If needed, GPU overrides:
```bash
flatpak override --user --device=all com.bambulab.BambuStudio
flatpak override --user --env=__GLX_VENDOR_LIBRARY_NAME=nvidia com.bambulab.BambuStudio
```
