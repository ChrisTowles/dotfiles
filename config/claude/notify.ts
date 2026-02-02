#!/usr/bin/env bun

// confirmation_004.ogg - from https://kenney.nl/assets/interface-sounds
// has Creative Commons CC0

const SOUND_PATH = `${process.env.HOME}/code/p/dotfiles/config/claude/confirmation_004.ogg`;

if (process.platform === "darwin") {
  Bun.spawn(["afplay", SOUND_PATH]);
} else {
  Bun.spawn(["paplay", SOUND_PATH]);
}
