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

        # Refresh the COSMIC panel so a fresh install's icon shows immediately.
        if [[ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]] && pgrep -x cosmic-panel >/dev/null 2>&1; then
          pkill -x cosmic-panel
        fi
      else
        echo " flatpak not found, skipping Bambu Studio install"
      fi
      ;;
  esac
fi
