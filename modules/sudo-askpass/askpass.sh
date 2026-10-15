#!/bin/sh
# GUI password prompt for sudo -A (non-interactive sudo, e.g. from Claude Code)
exec zenity --password --title="sudo password"
