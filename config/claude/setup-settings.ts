#!/usr/bin/env bun

import { readFileSync, writeFileSync, mkdirSync } from "fs";
import { join, dirname } from "path";

const configSrc = dirname(Bun.main);
const settingsFile = join(process.env.HOME!, ".claude", "settings.json");

mkdirSync(dirname(settingsFile), { recursive: true });

let settings: Record<string, any> = {};
try {
  settings = JSON.parse(readFileSync(settingsFile, "utf8"));
} catch {}

settings.statusLine = {
  type: "command",
  command: `bun run ${configSrc}/statusline.ts`,
};

settings.hooks = {
  ...settings.hooks,
  Notification: [
    {
      matcher: "",
      hooks: [
        {
          type: "command",
          command: `bun run ${configSrc}/notify.ts`,
        },
      ],
    },
  ],
};

writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + "\n");
