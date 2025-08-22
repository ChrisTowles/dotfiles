#!/usr/bin/env bash

# confirmation_004.ogg - from https://kenney.nl/assets/interface-sounds
# has Creative Commons CC0

SOUND_PATH="$HOME/code/p/dotfiles/config/claude/confirmation_004.ogg"

ffplay -nodisp -autoexit -loglevel quiet "$SOUND_PATH"