import { existsSync, readFileSync } from "node:fs";
import { defineModule } from "../../lib/module";

const EXTENSIONS = [
  "anthropic.claude-code",
  "GitHub.copilot",
  "chris-towles.markdown-paste-image",
  "antfu.file-nesting",
  "antfu.where-am-i",
  "antfu.smart-clicks",
  "moshfeu.compare-folders",
  "Vue.volar",
  "ms-python.python",
  "rust-lang.rust-analyzer",
];
const FONT = "FiraCode Nerd Font";
const USER = "config:Code - Insiders/User";

// VS Code Insiders
export default defineModule({
  id: "vscode",
  needs: ["nerd-fonts"],
  bin: "code-insiders",
  install: {
    linux: {
      via: "apt",
      pkg: "code-insiders",
      repo: {
        name: "vscode",
        key: "https://packages.microsoft.com/keys/microsoft.asc",
        keyring: "/etc/apt/keyrings/microsoft.gpg",
        dearmor: true,
        line: "deb [arch={arch} signed-by={keyring}] https://packages.microsoft.com/repos/code stable main",
      },
    },
    darwin: { via: "brew", pkg: "visual-studio-code-insiders", cask: true, app: "Visual Studio Code - Insiders" },
    win32: { via: "winget", id: "Microsoft.VisualStudioCode.Insiders" },
  },
  // --wait makes VS Code block until the tab is closed, which tools that use
  // $EDITOR need (git commit, claude code ctrl+g prompt editing, …)
  env: { EDITOR: "code-insiders --wait", VISUAL: "code-insiders --wait" },
  aliases: { code: "code-insiders" },
  links: [
    { from: "linux/keybindings.json", to: { linux: `${USER}/keybindings.json` } },
    { from: "mac/keybindings.json", to: { darwin: `${USER}/keybindings.json` } },
    { from: "win/keybindings.json", to: { win32: `${USER}/keybindings.json` } },
  ],
  async setup(ctx) {
    const have = new Set((await ctx.read(["code-insiders", "--list-extensions"])).stdout.toLowerCase().split(/\s+/));
    for (const ext of EXTENSIONS) if (!have.has(ext.toLowerCase())) await ctx.exec(["code-insiders", "--install-extension", ext, "--force"]);

    // settings.json is VS Code's own (it writes to it), so merge our keys instead of linking it
    const file = ctx.resolve(`${USER}/settings.json`);
    let settings: Record<string, unknown> = {};
    if (existsSync(file)) {
      try {
        settings = JSON.parse(readFileSync(file, "utf8"));
      } catch {
        // Comments or trailing commas: never overwrite the user's file with just our keys
        return ctx.notice(`VS Code settings.json is not plain JSON — set the font to "${FONT}" by hand: ${file}`);
      }
    }
    const next = { ...settings, "editor.fontFamily": FONT, "terminal.integrated.fontFamily": FONT, "window.nativeTabs": true };
    if (JSON.stringify(next) !== JSON.stringify(settings)) await ctx.write(file, `${JSON.stringify(next, null, 2)}\n`);
  },
});
