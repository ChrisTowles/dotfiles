# Bambu Studio on Linux

## Install via GitHub AppImage

```bash
./install/bambu-studio.sh
```

Downloads the latest **stable** `ubuntu24.04` AppImage from the official
[bambulab/BambuStudio](https://github.com/bambulab/BambuStudio) releases,
installs it to `~/.local/bin/BambuStudio.AppImage`, and creates an app-menu
launcher (`~/.local/share/applications/BambuStudio.desktop`) with the bundled
icon. Removes any old Flatpak installation.

### Install the beta

Bambu ships "Public Beta" builds as GitHub pre-releases (often ahead of stable):

```bash
BAMBU_PRERELEASE=1 ./install/bambu-studio.sh
```

### Update

Re-run `./install/bambu-studio.sh` — it always fetches the newest release and
overwrites the installed AppImage.

### Uninstall

```bash
rm ~/.local/bin/BambuStudio.AppImage \
   ~/.local/share/applications/BambuStudio.desktop \
   ~/.local/share/icons/bambu-studio.png
```
