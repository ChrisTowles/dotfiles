import { appInstalled } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Handy — free, offline speech-to-text (https://github.com/cjpais/Handy)
export default defineModule({
  id: "handy",
  needs: ["gh"],
  os: ["linux", "darwin", "win32"],
  installed: appInstalled({ bins: ["handy"], mac: "Handy", winget: "cjpais.Handy" }),
  install: {
    darwin: { via: "brew", pkg: "handy", cask: true },
    win32: { via: "winget", id: "cjpais.Handy" },
  },
  async setup(ctx) {
    if (ctx.os !== "linux") return;
    // wtype: Wayland text-input backend (Handy falls back to unreliable enigo without it).
    // libgtk-layer-shell0: runtime dep Handy links against on Linux.
    await ctx.sudo(["apt-get", "install", "-y", "-qq", "wtype", "libgtk-layer-shell0"]);
    if (ctx.has("handy")) return;
    const tmp = "/tmp/ttd-handy";
    await ctx.exec(["gh", "release", "download", "--repo", "cjpais/Handy", "--pattern", "*_amd64.deb", "-D", tmp, "--clobber"]);
    await ctx.exec(["sh", "-c", `sudo apt install -y ${tmp}/Handy_*_amd64.deb; rm -rf ${tmp}`]);
  },
});
