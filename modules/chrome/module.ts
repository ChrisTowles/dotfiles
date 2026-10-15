import { appInstalled } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Google Chrome (https://www.google.com/chrome/)
export default defineModule({
  id: "chrome",
  installed: appInstalled({ bins: ["google-chrome", "google-chrome-stable"], mac: "Google Chrome", winget: "Google.Chrome" }),
  install: {
    linux: {
      via: "apt",
      pkg: "google-chrome-stable",
      repo: {
        name: "google-chrome",
        key: "https://dl.google.com/linux/linux_signing_key.pub",
        keyring: "/etc/apt/keyrings/google-chrome.gpg",
        dearmor: true,
        line: "deb [arch={arch} signed-by={keyring}] https://dl.google.com/linux/chrome/deb/ stable main",
      },
    },
    darwin: [
      { via: "brew", pkg: "google-chrome", cask: true },
      { via: "brew", pkg: "defaultbrowser" },
    ],
    win32: { via: "winget", id: "Google.Chrome" },
  },
  async setup(ctx) {
    if (ctx.os === "darwin" && ctx.has("defaultbrowser")) await ctx.exec(["defaultbrowser", "chrome"]);
  },
});
