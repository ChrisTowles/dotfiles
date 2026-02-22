#!/usr/bin/env bun

/**
 * Register claude-stt from the local fork as a Claude Code plugin.
 *
 * Updates:
 * - known_marketplaces.json  (add marketplace entry)
 * - installed_plugins.json   (add plugin install record)
 * - settings.json            (enable the plugin)
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync, symlinkSync, lstatSync } from "fs";
import { join } from "path";

const claudeDir = join(process.env.HOME!, ".claude");
const pluginsDir = join(claudeDir, "plugins");
const marketplacesDir = join(pluginsDir, "marketplaces");
const cacheDir = join(pluginsDir, "cache");

const FORK_PATH = join(process.env.HOME!, "code", "f", "claude-stt");
const MARKETPLACE_NAME = "christowles-claude-stt";
const PLUGIN_NAME = "claude-stt";
const PLUGIN_KEY = `${PLUGIN_NAME}@${MARKETPLACE_NAME}`;
const PLUGIN_VERSION = "0.1.0";

function readJson(path: string): Record<string, any> {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch {
    return {};
  }
}

function writeJson(path: string, data: Record<string, any>): void {
  mkdirSync(join(path, ".."), { recursive: true });
  writeFileSync(path, JSON.stringify(data, null, 2) + "\n");
}

// 1. Symlink fork into marketplaces directory
const marketplacePath = join(marketplacesDir, MARKETPLACE_NAME);
mkdirSync(marketplacesDir, { recursive: true });

if (!existsSync(marketplacePath)) {
  symlinkSync(FORK_PATH, marketplacePath);
  console.log(`Symlinked marketplace: ${marketplacePath} -> ${FORK_PATH}`);
} else {
  // Check if it's already a symlink to the right place
  try {
    const stat = lstatSync(marketplacePath);
    if (stat.isSymbolicLink()) {
      console.log(`Marketplace symlink already exists: ${marketplacePath}`);
    } else {
      console.log(`Marketplace directory already exists: ${marketplacePath}`);
    }
  } catch {
    console.log(`Marketplace already exists: ${marketplacePath}`);
  }
}

// 2. Symlink fork into cache directory (plugin expects to run from its install path)
const cachePath = join(cacheDir, MARKETPLACE_NAME, PLUGIN_NAME, PLUGIN_VERSION);
mkdirSync(join(cacheDir, MARKETPLACE_NAME, PLUGIN_NAME), { recursive: true });

if (!existsSync(cachePath)) {
  symlinkSync(FORK_PATH, cachePath);
  console.log(`Symlinked cache: ${cachePath} -> ${FORK_PATH}`);
} else {
  console.log(`Cache path already exists: ${cachePath}`);
}

// 3. Update known_marketplaces.json
const knownPath = join(pluginsDir, "known_marketplaces.json");
const known = readJson(knownPath);
if (!known[MARKETPLACE_NAME]) {
  known[MARKETPLACE_NAME] = {
    source: {
      source: "github",
      repo: "ChrisTowles/claude-stt",
    },
    installLocation: marketplacePath,
    lastUpdated: new Date().toISOString(),
  };
  writeJson(knownPath, known);
  console.log("Registered marketplace in known_marketplaces.json");
} else {
  console.log("Marketplace already registered in known_marketplaces.json");
}

// 4. Update installed_plugins.json
const installedPath = join(pluginsDir, "installed_plugins.json");
const installed = readJson(installedPath);
installed.version = installed.version || 2;
installed.plugins = installed.plugins || {};

if (!installed.plugins[PLUGIN_KEY]) {
  installed.plugins[PLUGIN_KEY] = [
    {
      scope: "user",
      installPath: cachePath,
      version: PLUGIN_VERSION,
      installedAt: new Date().toISOString(),
      lastUpdated: new Date().toISOString(),
    },
  ];
  writeJson(installedPath, installed);
  console.log("Added plugin to installed_plugins.json");
} else {
  console.log("Plugin already in installed_plugins.json");
}

// 5. Enable in settings.json
const settingsPath = join(claudeDir, "settings.json");
const settings = readJson(settingsPath);
settings.enabledPlugins = settings.enabledPlugins || {};

if (!settings.enabledPlugins[PLUGIN_KEY]) {
  settings.enabledPlugins[PLUGIN_KEY] = true;
  writeJson(settingsPath, settings);
  console.log("Enabled plugin in settings.json");
} else {
  console.log("Plugin already enabled in settings.json");
}

console.log("claude-stt plugin registration complete.");
