import { join } from "node:path";
import { defineModule } from "../../lib/module";

const DESKTOP = (name: string, comment: string, exec: string) => `[Desktop Entry]
Name=${name}
Comment=${comment}
Exec=${exec}
Type=Application
X-GNOME-Autostart-enabled=true
`;

// Clipboard history on Ctrl+`:
//   Linux   cliphist + wofi picker with image previews (the COSMIC shortcut is in the popos module)
//   macOS   Maccy
//   Windows the built-in Win+V history; PowerToys Keyboard Manager maps Ctrl+` → Win+V
export default defineModule({
  id: "clipboard",
  needs: ["gh"],
  bin: "cliphist",
  install: {
    linux: [
      { via: "apt", pkg: ["wl-clipboard", "wofi", "xdg-utils", "wtype", "gawk", "imagemagick", "ripgrep"] },
      { via: "gh-release", repo: "sentriz/cliphist", asset: "*-linux-amd64", bins: ["cliphist"] },
    ],
    darwin: { via: "brew", pkg: "maccy", cask: true, app: "Maccy" },
    win32: { via: "winget", id: "Microsoft.PowerToys" },
  },
  // PowerToys rewrites this file when you edit remaps in its UI; `ttd doctor` flags a replaced link
  links: [{ from: "powertoys/default.json", to: { win32: "data:Microsoft/PowerToys/Keyboard Manager/default.json" } }],
  aliases: {
    // Picker with image previews (Ctrl+` via the COSMIC shortcut, or run by hand)
    "cliphist-pick": { zsh: "cliphist-wofi-img | wl-copy" },
    "cliphist-delete": { zsh: "cliphist list | wofi --dmenu | cliphist delete" },
  },
  async setup(ctx) {
    if (ctx.os !== "linux") return;
    if (!(await Bun.file("/usr/local/bin/cliphist-wofi-img").exists())) {
      // Official contrib script, patched: upstream calls `magick` (ImageMagick 7), Ubuntu ships `convert` (6)
      const res = await fetch("https://raw.githubusercontent.com/sentriz/cliphist/master/contrib/cliphist-wofi-img");
      const tmp = "/tmp/cliphist-wofi-img";
      await ctx.write(tmp, (await res.text()).replaceAll("magick - -resize", "convert - -resize"));
      await ctx.sudo(["install", "-m", "0755", tmp, "/usr/local/bin/cliphist-wofi-img"]);
    }
    const autostart = join(ctx.home, ".config", "autostart");
    await ctx.write(join(autostart, "cliphist.desktop"), DESKTOP("Cliphist", "Clipboard history for Wayland (text)", "wl-paste --watch cliphist store"));
    await ctx.write(
      join(autostart, "cliphist-image.desktop"),
      DESKTOP("Cliphist Image", "Clipboard history for Wayland (images)", "wl-paste --type image --watch cliphist store"),
    );
  },
});
