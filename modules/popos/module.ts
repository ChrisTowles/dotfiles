import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { confirm, sudoCopyIfChanged } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// COSMIC custom shortcuts:
//   Ctrl+`        → cliphist picker (clipboard manager via wofi)
//   Ctrl+Shift+4  → cosmic-screenshot (like macOS Cmd+Shift+4)
const SHORTCUTS = `{
    (modifiers: [Ctrl], key: "grave"): Spawn("bash -c 'cliphist-wofi-img | wl-copy && sleep 0.1 && wtype -M ctrl -M shift -k v'"),
    (modifiers: [Ctrl, Shift], key: "4"): Spawn("cosmic-screenshot"),
}`;

const isPopOS = () => existsSync("/etc/os-release") && /pop/i.test(readFileSync("/etc/os-release", "utf8"));

// Pop!_OS / COSMIC desktop: keyd, screenshot and clipboard shortcuts, desktop helpers.
// The module is Linux-only; every step also checks for Pop!_OS.
export default defineModule({
  id: "popos",
  os: ["linux"],
  commands: {
    screenshot: { desc: "Interactive screenshot (COSMIC)", run: (ctx) => ctx.exec(["cosmic-screenshot", "--interactive"]) },
    "screenshot-full": {
      desc: "Full-screen screenshot to ~/Pictures/Screenshots",
      async run(ctx) {
        const dir = join(ctx.home, "Pictures", "Screenshots");
        mkdirSync(dir, { recursive: true });
        return ctx.exec(["cosmic-screenshot", "--interactive=false", "--save-dir", dir]);
      },
    },
    "cosmic-panel-reset": {
      // cosmic-panel is respawned by the session, so killing it just refreshes it
      desc: "Restart the COSMIC panel/dock (stale pins, missing icons)",
      async run(ctx) {
        if ((await ctx.read(["pgrep", "-x", "cosmic-panel"])).code !== 0) return console.error("cosmic-panel not running (is this a COSMIC session?)"), 1;
        console.log("Restarting cosmic-panel...");
        await ctx.read(["pkill", "-x", "cosmic-panel"]);
      },
    },
    "popos-restart-desktop": {
      desc: "Restart the display manager (logs you out)",
      async run(ctx) {
        console.log("This will restart the display manager and LOG YOU OUT.");
        if (!confirm("Are you sure?")) return 1;
        return ctx.sudo(["systemctl", "restart", "cosmic-greeter"]);
      },
    },
  },
  async setup(ctx) {
    if (!isPopOS()) return ctx.log("not Pop!_OS — skipped");

    // keyd: system-level key remapping. Swaps left Ctrl ↔ left Super so macOS muscle memory transfers (keyd.conf).
    if (!ctx.has("keyd")) {
      if ((await ctx.sudo(["apt-get", "install", "-y", "-qq", "keyd"])) !== 0) {
        ctx.log("keyd not in apt, building from source");
        const tmp = "/tmp/keyd-build";
        await ctx.exec(["rm", "-rf", tmp]);
        await ctx.exec(["git", "clone", "-q", "https://github.com/rvaiya/keyd", tmp]);
        await ctx.exec(["make", "-C", tmp]);
        await ctx.sudo(["make", "-C", tmp, "install"]);
        await ctx.exec(["rm", "-rf", tmp]);
      }
      await ctx.sudo(["systemctl", "enable", "--now", "keyd"]);
    }
    // /etc/keyd is root-owned, so the config is copied, not linked
    if (await sudoCopyIfChanged(ctx, join(ctx.dir, "keyd.conf"), "/etc/keyd/default.conf")) await ctx.sudo(["systemctl", "restart", "keyd"]);

    if (process.env.XDG_CURRENT_DESKTOP === "COSMIC") {
      const file = join(ctx.home, ".config", "cosmic", "com.system76.CosmicSettings.Shortcuts", "v1", "custom");
      if ((await Bun.file(file).text().catch(() => "")).trim() !== SHORTCUTS) {
        ctx.log("updating COSMIC custom shortcuts");
        await ctx.write(file, `${SHORTCUTS}\n`);
      }
    }
  },
});
