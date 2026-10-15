import { join } from "node:path";
import { defineModule } from "../../lib/module";

export default defineModule({
  id: "pwsh",
  install: { win32: { via: "winget", id: "Microsoft.PowerShell" } },
  aliases: {
    ez: { pwsh: ". $PROFILE" },
    "ez-setup": { pwsh: "ttd setup; . $PROFILE" },
    "zsh-dotfiles-help": { pwsh: "ttd help" },
  },
  async setup(ctx) {
    // Developer Mode lets an unelevated process create file symlinks; every config link needs it.
    const dev = await ctx.read([
      "reg", "query", "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock", "/v", "AllowDevelopmentWithoutDevLicense",
    ]);
    if (!/0x1\b/.test(dev.stdout)) {
      ctx.notice("⚠️  Turn on Developer Mode (Settings > System > For developers), then re-run `ttd setup` — config links need it.");
    }
    // $PROFILE can sit under a OneDrive-redirected Documents folder, so ask pwsh where it is.
    const r = await ctx.read(["pwsh", "-NoProfile", "-Command", "$PROFILE.CurrentUserCurrentHost"]);
    const profile = r.stdout.trim();
    if (r.code !== 0 || !profile) throw new Error("could not resolve $PROFILE");
    ctx.link(join(ctx.dir, "profile.ps1"), profile);
  },
});
