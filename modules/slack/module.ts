import { defineModule } from "../../lib/module";

// Slack Desktop (https://slack.com)
export default defineModule({
  id: "slack",
  install: {
    linux: {
      via: "deb",
      pkg: "slack-desktop",
      url: async () => {
        const res = await fetch("https://slack.com/api/desktop.latestRelease?platform=linux&variant=deb&arch=x64");
        return ((await res.json()) as { download_url?: string }).download_url ?? "";
      },
    },
    darwin: { via: "brew", pkg: "slack", cask: true, app: "Slack" },
    win32: { via: "winget", id: "SlackTechnologies.Slack" },
  },
});
