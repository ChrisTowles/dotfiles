import { defineModule } from "../../lib/module";

// Rust toolchain via rustup (https://rustup.rs). cargo installs the Rust CLIs
// (bat, fd, eza, delta, starship, …) on Linux and macOS.
export default defineModule({
  id: "rust",
  bin: "rustc",
  install: {
    unix: { via: "script", url: "https://sh.rustup.rs", args: ["-y", "--no-modify-path"] },
    win32: { via: "winget", id: "Rustlang.Rustup" },
  },
  path: ["~/.cargo/bin"],
  completions: [
    { shell: "zsh", argv: ["rustup", "completions", "zsh"], name: "_rustup" },
    { shell: "zsh", argv: ["rustup", "completions", "zsh", "cargo"], name: "_cargo" },
    { shell: "pwsh", argv: ["rustup", "completions", "powershell"], name: "rustup" },
  ],
});
