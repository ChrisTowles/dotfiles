# Bambu Studio setup (Linux only — installed via Flatpak/Flathub)
# https://flathub.org/apps/com.bambulab.BambuStudio

_BAMBU_APP_ID="com.bambulab.BambuStudio"

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  case "$(uname -s)" in
    Linux)
      if command -v flatpak >/dev/null 2>&1; then
        if ! flatpak remote-list --user 2>/dev/null | grep -q '^flathub'; then
          echo " Adding Flathub remote..."
          flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi

        if flatpak info --user "$_BAMBU_APP_ID" &>/dev/null; then
          echo " Updating Bambu Studio..."
        else
          echo " Installing Bambu Studio..."
        fi
        flatpak install --user -y flathub "$_BAMBU_APP_ID"

        # Explicit default handlers so files (e.g. downloaded from MakerWorld)
        # open in Bambu Studio even if another slicer is later installed.
        xdg-mime default "$_BAMBU_APP_ID.desktop" \
          model/stl model/3mf model/step \
          application/vnd.ms-3mfdocument application/prs.wavefront-obj

        # Fix COSMIC panel favorites: replace old non-Flatpak entry with Flatpak app ID,
        # then restart the panel so the icon appears immediately.
        if [[ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]]; then
          local favorites_file="$HOME/.config/cosmic/com.system76.CosmicAppList/v1/favorites"
          if [[ -f "$favorites_file" ]]; then
            if grep -q '"BambuStudio"' "$favorites_file" && ! grep -q "\"$_BAMBU_APP_ID\"" "$favorites_file"; then
              sed -i "s/\"BambuStudio\"/\"$_BAMBU_APP_ID\"/" "$favorites_file"
              echo "  Updated COSMIC favorites: BambuStudio → $_BAMBU_APP_ID"
            elif ! grep -q "\"$_BAMBU_APP_ID\"" "$favorites_file"; then
              sed -i "s/]$/    \"$_BAMBU_APP_ID\",\n]/" "$favorites_file"
              echo "  Added $_BAMBU_APP_ID to COSMIC panel favorites"
            fi
          fi
          if pgrep -x cosmic-panel >/dev/null 2>&1; then
            pkill -x cosmic-panel
            echo "  Restarted cosmic-panel to refresh icons"
          fi
        fi
      else
        echo " flatpak not found, skipping Bambu Studio install"
      fi
      ;;
  esac
fi
