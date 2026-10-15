import { defineModule } from "../../lib/module";
import { out } from "../../lib/helpers";

// Discord (Linux only — intentionally not installed on macOS or Windows)
export default defineModule({
  id: "discord",
  os: ["linux"],
  async setup(ctx) {
    // Discord on Linux doesn't auto-update — resolve the latest .deb every run and reinstall when it differs
    const url = await out(ctx, ["curl", "-sILo", "/dev/null", "-w", "%{url_effective}", "https://discord.com/api/download?platform=linux&format=deb"]);
    if (!url.endsWith(".deb")) throw new Error("could not resolve the Discord download URL");
    const latest = url.match(/\d+\.\d+\.\d+/)?.[0];
    const current = await out(ctx, ["dpkg-query", "-W", "-f=${Version}", "discord"]);
    if (current === latest) return;
    ctx.log(current ? `updating Discord ${current} → ${latest}` : `installing Discord ${latest}`);
    await ctx.exec(["curl", "-fL", url, "-o", "/tmp/discord.deb"]);
    await ctx.sudo(["apt", "install", "-y", "/tmp/discord.deb"]);
    await ctx.exec(["rm", "-f", "/tmp/discord.deb"]);
  },
});
