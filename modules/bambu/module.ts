import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { defineModule } from "../../lib/module";

const APP = "com.bambulab.BambuStudio";

// Bambu Studio (Linux only — Flatpak from Flathub). https://flathub.org/apps/com.bambulab.BambuStudio
export default defineModule({
  id: "bambu",
  install: { linux: { via: "flatpak", id: APP } },
  async setup(ctx) {
    // Explicit default handlers so downloaded models open in Bambu Studio even if another slicer is installed later
    await ctx.exec(["xdg-mime", "default", `${APP}.desktop`, "model/stl", "model/3mf", "model/step", "application/vnd.ms-3mfdocument", "application/prs.wavefront-obj"]);

    // COSMIC panel favorites: replace the old non-Flatpak entry with the Flatpak app id
    if (process.env.XDG_CURRENT_DESKTOP !== "COSMIC") return;
    const fav = join(ctx.home, ".config", "cosmic", "com.system76.CosmicAppList", "v1", "favorites");
    if (!existsSync(fav)) return;
    const text = readFileSync(fav, "utf8");
    if (text.includes(`"${APP}"`)) return;
    const fixed = text.includes('"BambuStudio"') ? text.replace('"BambuStudio"', `"${APP}"`) : text.replace(/]\s*$/, `    "${APP}",\n]`);
    await ctx.write(fav, fixed);
    ctx.log(`added ${APP} to COSMIC panel favorites`);
    await ctx.read(["pkill", "-x", "cosmic-panel"]);
  },
});
