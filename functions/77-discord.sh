# Discord setup (Linux only — intentionally not installed on macOS)
# https://discord.com

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  case "$(uname -s)" in
    Linux)
      # Discord on Linux doesn't auto-update — resolve the latest .deb URL on
      # every setup run and reinstall when the version differs.
      DISCORD_URL=$(curl -sILo /dev/null -w '%{url_effective}' "https://discord.com/api/download?platform=linux&format=deb")
      if [[ -z "$DISCORD_URL" || "$DISCORD_URL" != *.deb ]]; then
        echo " Failed to resolve Discord download URL"
      else
        DISCORD_LATEST=$(echo "$DISCORD_URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        DISCORD_INSTALLED=$(dpkg-query -W -f='${Version}' discord 2>/dev/null || true)
        if [[ "$DISCORD_INSTALLED" != "$DISCORD_LATEST" ]]; then
          if [[ -z "$DISCORD_INSTALLED" ]]; then
            echo " Installing Discord $DISCORD_LATEST..."
          else
            echo " Updating Discord $DISCORD_INSTALLED → $DISCORD_LATEST..."
          fi
          curl -fL "$DISCORD_URL" -o /tmp/discord.deb
          sudo apt install -y /tmp/discord.deb
          rm -f /tmp/discord.deb
        fi
      fi
      ;;
  esac
fi
