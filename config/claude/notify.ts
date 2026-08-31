#!/usr/bin/env bun

// Plays a sound for a Claude Code hook event, picked by `hook_event_name` from
// the hook's stdin JSON (or argv[2], for trying one by hand):
//   Stop         → agent finished its turn
//   Notification → agent needs attention (permission prompt, idle, …)
//
// odyssey-trial-bow-sound.mp3 - https://www.myinstants.com/en/instant/odyssey-trial-bow-sound-20147/
// confirmation_004.ogg        - https://kenney.nl/assets/interface-sounds (CC0)

const SOUNDS: Record<string, string> = {
  Stop: "odyssey-trial-bow-sound.mp3",
  Notification: "confirmation_004.ogg",
};

async function eventName(): Promise<string> {
  if (process.argv[2]) return process.argv[2];
  try {
    return (await Bun.stdin.json()).hook_event_name ?? "Notification";
  } catch {
    return "Notification";
  }
}

const sound = `${import.meta.dir}/${SOUNDS[await eventName()] ?? SOUNDS.Notification}`;
const player = process.platform === "darwin" ? "afplay" : "paplay";

// Detach so the hook returns at once; Claude Code waits on Stop hooks before
// handing the prompt back, and the clip is a few seconds long.
Bun.spawn([player, sound], { stdio: ["ignore", "ignore", "ignore"] }).unref();
