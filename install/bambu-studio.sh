#!/bin/bash
set -euo pipefail

# Install BambuStudio from the official GitHub AppImage release.
#
# Defaults to the latest *stable* release. To install the latest public beta
# (a GitHub pre-release) instead, run:
#   BAMBU_PRERELEASE=1 ./install/bambu-studio.sh

REPO="bambulab/BambuStudio"
UBUNTU="ubuntu24.04"                       # Pop!_OS 24.04 / noble base
APPIMAGE="$HOME/.local/bin/BambuStudio.AppImage"
# Named BambuStudio.desktop (matches StartupWMClass) so dock pins resolve to it.
DESKTOP="$HOME/.local/share/applications/BambuStudio.desktop"
ICON="$HOME/.local/share/icons/bambu-studio.png"

mkdir -p "$(dirname "$APPIMAGE")" "$(dirname "$DESKTOP")" "$(dirname "$ICON")"

# Remove the old Flatpak install if present (we now manage the AppImage directly).
if command -v flatpak &>/dev/null && flatpak info com.bambulab.BambuStudio &>/dev/null; then
  echo "Removing old Flatpak installation..."
  flatpak uninstall -y com.bambulab.BambuStudio
fi

# Pick the newest release tag. `gh release download` defaults to the latest
# stable release; opt into the newest pre-release with BAMBU_PRERELEASE=1.
if [[ "${BAMBU_PRERELEASE:-0}" == "1" ]]; then
  TAG="$(gh release list --repo "$REPO" --limit 20 \
    --json tagName,isPrerelease --jq 'map(select(.isPrerelease))[0].tagName')"
  echo "Installing latest pre-release: $TAG"
  DL_TAG=(--tag "$TAG")
else
  echo "Installing latest stable release..."
  DL_TAG=()
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

gh release download "${DL_TAG[@]}" --repo "$REPO" \
  --pattern "BambuStudio_${UBUNTU}-*.AppImage" --dir "$TMP" --clobber

SRC="$(echo "$TMP"/BambuStudio_${UBUNTU}-*.AppImage)"
install -m 755 "$SRC" "$APPIMAGE"
echo "Installed $(basename "$SRC") -> $APPIMAGE"

# Extract the bundled icon for menu integration (best-effort).
( cd "$TMP" && "$APPIMAGE" --appimage-extract 'usr/share/icons/**/*.png' &>/dev/null || true
  cd "$TMP" && "$APPIMAGE" --appimage-extract '*.png' &>/dev/null || true )
FOUND_ICON="$(find "$TMP/squashfs-root" -name '*.png' 2>/dev/null | sort -r | head -1 || true)"
[[ -n "$FOUND_ICON" ]] && cp "$FOUND_ICON" "$ICON"

# Desktop launcher.
cat > "$DESKTOP" <<EOF
[Desktop Entry]
Name=Bambu Studio
Comment=3D printing slicer for Bambu Lab printers
Exec=$APPIMAGE %F
Icon=${ICON}
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;Engineering;
MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;
StartupWMClass=BambuStudio
EOF

update-desktop-database "$(dirname "$DESKTOP")" &>/dev/null || true

echo "Done. Run with: $APPIMAGE  (or launch 'Bambu Studio' from your app menu)"
