import { existsSync } from "node:fs";
import { join } from "node:path";
import { defineModule } from "../../lib/module";

// gws - Google Workspace CLI (https://github.com/googleworkspace/cli). Needs the
// gcloud SDK, installed to ~/google-cloud-sdk. Linux only.
export default defineModule({
  id: "gws",
  needs: ["rust"],
  install: { linux: { via: "cargo", crate: "gws", git: "https://github.com/googleworkspace/cli", locked: true } },
  path: ["~/google-cloud-sdk/bin"],
  async setup(ctx) {
    const sdk = join(ctx.home, "google-cloud-sdk");
    if (!ctx.has("gcloud") && !existsSync(sdk)) {
      ctx.log("installing Google Cloud SDK");
      const url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz";
      await ctx.exec(["sh", "-c", `curl -fsSL ${url} | tar -xz -C "${ctx.home}"`]);
      await ctx.exec([join(sdk, "install.sh"), "--quiet", "--path-update=false", "--command-completion=false"]);
    }
    ctx.notice("Run 'gws auth setup' to configure Google Workspace CLI authentication");
  },
});
