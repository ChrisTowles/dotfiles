import { appInstalled } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Slack Desktop (https://slack.com)
export default defineModule({
  id: "slack",
  installed: appInstalled({ bins: ["slack"], mac: "Slack", winget: "SlackTechnologies.Slack" }),
  install: {
    darwin: { via: "brew", pkg: "slack", cask: true },
    win32: { via: "winget", id: "SlackTechnologies.Slack" },
  },
  os: ["linux", "darwin", "win32"],
  async setup(ctx) {
    if (ctx.os !== "linux" || ctx.has("slack")) return;
    const res = await fetch("https://slack.com/api/desktop.latestRelease?platform=linux&variant=deb&arch=x64");
    const url = ((await res.json()) as { download_url?: string }).download_url;
    if (!url) throw new Error("could not fetch the Slack download URL");
    await ctx.exec(["curl", "-fL", url, "-o", "/tmp/slack.deb"]);
    await ctx.sudo(["apt", "install", "-y", "/tmp/slack.deb"]);
    await ctx.exec(["rm", "-f", "/tmp/slack.deb"]);
  },
});
