#!/usr/bin/env bun

import { readFileSync, writeFileSync, mkdirSync } from "fs";
import { dirname, join } from "path";

const font = process.argv[2] || "FiraCode Nerd Font";

let settingsFile: string;
if (process.platform === "darwin") {
  settingsFile = join(process.env.HOME!, "Library", "Application Support", "Code - Insiders", "User", "settings.json");
} else {
  settingsFile = join(process.env.HOME!, ".config", "Code - Insiders", "User", "settings.json");
}

mkdirSync(dirname(settingsFile), { recursive: true });

let settings: Record<string, any> = {};
try {
  settings = JSON.parse(readFileSync(settingsFile, "utf8"));
} catch {}

settings["editor.fontFamily"] = font;
settings["terminal.integrated.fontFamily"] = font;

writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + "\n");
