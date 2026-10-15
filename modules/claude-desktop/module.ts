import { appInstalled } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Claude Desktop (https://support.claude.com/en/articles/10065433-install-claude-desktop)
export default defineModule({
  id: "claude-desktop",
  installed: async (ctx) =>
    ctx.os === "linux" ? (await ctx.read(["dpkg", "-s", "claude-desktop"])).code === 0 : appInstalled({ mac: "Claude", winget: "Anthropic.Claude" })(ctx),
  install: {
    linux: {
      via: "apt",
      pkg: "claude-desktop",
      repo: {
        name: "claude-desktop",
        key: "https://downloads.claude.ai/claude-desktop/key.asc",
        keyring: "/usr/share/keyrings/claude-desktop-archive-keyring.asc",
        line: "deb [signed-by={keyring}] https://downloads.claude.ai/claude-desktop/apt/stable stable main",
      },
    },
    darwin: { via: "brew", pkg: "claude", cask: true },
    win32: { via: "winget", id: "Anthropic.Claude" },
  },
});
