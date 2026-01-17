#!/usr/bin/env bash
# Install Bambu Studio AppImage with desktop integration
set -euo pipefail

APP_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/.local/bin"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$APP_DIR" "$BIN_DIR" "$ICON_DIR"

# Install dependency (Pop!_OS / Ubuntu 22.04)
if ! dpkg -s libwebkit2gtk-4.1-0 &>/dev/null; then
    echo "Installing libwebkit2gtk-4.1-0..."
    sudo apt install -y libwebkit2gtk-4.1-0
fi

# Get latest Ubuntu 22.04 AppImage URL
echo "Fetching latest release..."
APPIMAGE_URL=$(curl -s https://api.github.com/repos/bambulab/BambuStudio/releases/latest \
    | jq -r '.assets[] | select(.name | test("ubuntu-22.04.*AppImage$")) | .browser_download_url' \
    | head -1)

if [[ -z "$APPIMAGE_URL" ]]; then
    echo "Error: Could not find AppImage URL"
    exit 1
fi

FILENAME=$(basename "$APPIMAGE_URL")
APPIMAGE_PATH="$BIN_DIR/BambuStudio.AppImage"

echo "Downloading $FILENAME..."
curl -L "$APPIMAGE_URL" -o "$APPIMAGE_PATH"
chmod +x "$APPIMAGE_PATH"

# Extract icon from AppImage
echo "Extracting icon..."
cd /tmp
"$APPIMAGE_PATH" --appimage-extract BambuStudio.png 2>/dev/null || true
if [[ -f squashfs-root/BambuStudio.png ]]; then
    cp squashfs-root/BambuStudio.png "$ICON_DIR/bambu-studio.png"
    rm -rf squashfs-root
fi

# Create desktop entry
cat > "$APP_DIR/bambu-studio.desktop" << EOF
[Desktop Entry]
Name=Bambu Studio
Comment=3D Printing Slicer for Bambu Lab printers
Exec=$APPIMAGE_PATH %F
Icon=$ICON_DIR/bambu-studio.png
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;Engineering;
MimeType=model/stl;application/vnd.ms-3mfdocument;
EOF

echo "Done! Bambu Studio installed to $APPIMAGE_PATH"
echo "Desktop entry created - should appear in app menu"
