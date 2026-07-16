# Bambu Studio on Linux

## Install / Update

Managed by `functions/78-bambu-studio.sh`, which runs automatically as part of
setup:

```bash
DOTFILES_SETUP=1 exec zsh
```

Installs `com.bambulab.BambuStudio` from Flathub (`stable` branch), adding the
Flathub remote first if it isn't already configured. Re-running updates it in
place if already installed.

Also sets Bambu Studio as the default handler for `.stl`, `.3mf`, and `.step`
files (e.g. downloads from MakerWorld), and restarts the COSMIC panel so a
fresh install's icon shows up immediately.

Flathub only publishes a `stable` branch for this app — there's no Beta
channel available via Flatpak.

### Uninstall

```bash
flatpak uninstall -y com.bambulab.BambuStudio
```
