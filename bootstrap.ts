#!/usr/bin/env bun
// Fresh-machine bootstrap, run by install.sh / install.ps1 once Bun is on PATH.
// Ensures git, clones the repo, installs its packages, and hands off to `ttd setup`.

import { existsSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const REPO_URL = "https://github.com/ChrisTowles/dotfiles.git";
const DIR = process.env.DOTFILES_DIR ?? join(homedir(), "code", "p", "dotfiles");
const os = process.platform;

const info = (m: string) => console.log(`\x1b[34m[info]\x1b[0m  ${m}`);
const ok = (m: string) => console.log(`\x1b[32m[ ok ]\x1b[0m  ${m}`);

function run(argv: string[], cwd?: string): void {
  const r = Bun.spawnSync(argv, { cwd, stdio: ["inherit", "inherit", "inherit"] });
  if (r.exitCode !== 0) {
    console.error(`\x1b[31m[error]\x1b[0m ${argv.join(" ")} exited ${r.exitCode}`);
    process.exit(1);
  }
}

if (os !== "linux" && os !== "darwin" && os !== "win32") throw new Error(`unsupported platform: ${os}`);
if (os === "linux" && process.arch !== "x64") throw new Error(`only x86_64 is supported on Linux (got ${process.arch})`);

if (Bun.which("git")) ok("git is installed");
else {
  info("installing git");
  if (os === "linux") run(["sh", "-c", "sudo apt-get update -qq && sudo apt-get install -y -qq git"]);
  else if (os === "darwin") run(["xcode-select", "--install"]); // Command Line Tools ship git
  else run(["winget", "install", "--id", "Git.Git", "--exact", "--silent", "--accept-package-agreements", "--accept-source-agreements"]);
}
if (os === "darwin" && !Bun.which("brew")) throw new Error("Homebrew is required on macOS. Install it from https://brew.sh");

if (existsSync(join(DIR, ".git"))) {
  info(`${DIR} exists, pulling`);
  run(["git", "-C", DIR, "pull", "--ff-only"]);
} else {
  info(`cloning to ${DIR}`);
  mkdirSync(dirname(DIR), { recursive: true });
  run(["git", "clone", REPO_URL, DIR]);
}

run([process.execPath, "install"], DIR);
info("running ttd setup");
run([process.execPath, join(DIR, "bin", "ttd.ts"), "setup"]);
ok(os === "win32" ? "done — open a new pwsh window" : "done — run: exec zsh");
