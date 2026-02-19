#!/bin/bash
set -euo pipefail

# Install BambuStudio via Flatpak

APP_ID="com.bambulab.BambuStudio"

# Ensure Flatpak and Flathub are set up
if ! command -v flatpak &>/dev/null; then
  echo "Installing Flatpak..."
  sudo apt install -y flatpak
fi

if ! flatpak remotes | grep -q flathub; then
  echo "Adding Flathub repository..."
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Remove old .deb version if present
if dpkg -s bambustudio &>/dev/null; then
  echo "Removing old .deb installation..."
  sudo apt remove -y bambustudio
fi

# Install or update
if flatpak info "$APP_ID" &>/dev/null; then
  echo "Updating BambuStudio..."
  flatpak update -y "$APP_ID"
else
  echo "Installing BambuStudio..."
  flatpak install -y flathub "$APP_ID"
fi

echo "Done. Run with: flatpak run ${APP_ID}"
