import { existsSync } from "node:fs";
import { join } from "node:path";
import { withTmp } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// FiraCode Nerd Font, for Starship and terminal icons
export default defineModule({
  id: "nerd-fonts",
  needs: ["gh"],
  installed: (ctx) =>
    ctx.os === "linux"
      ? existsSync(join(ctx.home, ".local", "share", "fonts", "FiraCode"))
      : ctx.os === "darwin"
        ? existsSync(join(ctx.home, "Library", "Fonts", "FiraCodeNerdFont-Bold.ttf"))
        : existsSync(join(process.env.LOCALAPPDATA ?? "", "Microsoft", "Windows", "Fonts", "FiraCodeNerdFont-Bold.ttf")),
  install: {
    darwin: { via: "brew", pkg: "font-fira-code-nerd-font", cask: true },
    win32: { via: "winget", id: "DEVCOM.FiraCodeNerdFont" },
  },
  os: ["linux", "darwin", "win32"],
  commands: {
    "nerd-fonts-setup": { desc: "Install the FiraCode Nerd Font", run: (ctx) => ctx.exec(["ttd", "setup", "nerd-fonts"]) },
  },
  async setup(ctx) {
    if (ctx.os !== "linux") return;
    const dir = join(ctx.home, ".local", "share", "fonts", "FiraCode");
    if (existsSync(dir)) return;
    ctx.log("installing FiraCode Nerd Font");
    await withTmp("ttd-font-", async (tmp) => {
      const dl = ["gh", "release", "download", "--repo", "ryanoasis/nerd-fonts", "--pattern", "FiraCode.zip", "-D", tmp, "--clobber"];
      if ((await ctx.exec(dl)) !== 0) throw new Error("font download failed");
      await ctx.exec(["mkdir", "-p", dir]);
      await ctx.exec(["unzip", "-o", "-q", join(tmp, "FiraCode.zip"), "-d", dir]);
      await ctx.exec(["fc-cache", "-f"]);
    });
  },
});
