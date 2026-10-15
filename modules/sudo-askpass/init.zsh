# Only with a display server: zenity needs one to draw the prompt
[[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]] && export SUDO_ASKPASS="$DOTFILES_DIR/modules/sudo-askpass/askpass.sh"
