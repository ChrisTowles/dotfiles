# sudo askpass — GUI password prompt for non-interactive sudo (e.g. Claude Code)
# Only active on Linux with a display server and zenity installed

if [[ "$_DOTFILES_OS" == "Linux" ]] && [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]] && command -v zenity >/dev/null 2>&1; then
  export SUDO_ASKPASS="${0:a:h}/../config/sudo-askpass.sh"
fi
