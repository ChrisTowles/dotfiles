import { defineModule } from "../../lib/module";

// Handy — free, offline speech-to-text (https://github.com/cjpais/Handy)
export default defineModule({
  id: "handy",
  needs: ["gh"],
  install: {
    linux: [
      { via: "deb", pkg: "handy", gh: { repo: "cjpais/Handy", asset: "*_amd64.deb" } },
      // wtype: Wayland text-input backend (Handy falls back to unreliable enigo without it).
      // libgtk-layer-shell0: runtime dep Handy links against on Linux.
      { via: "apt", pkg: ["wtype", "libgtk-layer-shell0"] },
    ],
    darwin: { via: "brew", pkg: "handy", cask: true, app: "Handy" },
    win32: { via: "winget", id: "cjpais.Handy" },
  },
});
