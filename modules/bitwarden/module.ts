import { defineModule } from "../../lib/module";
import { out } from "../../lib/helpers";
import { install } from "../../lib/install";

// Bitwarden CLI (https://bitwarden.com/help/cli/). Linux only — on macOS it is
// installed by hand (`brew install bitwarden-cli`).
export default defineModule({
  id: "bitwarden",
  needs: ["gh"],
  bin: "bw",
  os: ["linux"],
  completions: [{ shell: "zsh", argv: ["bw", "completion", "--shell", "zsh"], name: "_bw" }],
  async setup(ctx) {
    if (ctx.has("bw")) return;
    // bitwarden/clients ships browser/desktop/web releases from the same repo,
    // so resolve the newest cli-v* tag rather than trusting "latest"
    const tag = await out(ctx, [
      "gh", "release", "list", "--repo", "bitwarden/clients", "--limit", "60",
      "--json", "tagName", "--jq", '[.[] | select(.tagName | startswith("cli-v"))][0].tagName',
    ]);
    if (!tag) {
      if (ctx.dryRun) return ctx.log("would install the newest cli-v* release (gh could not list releases)");
      throw new Error("could not resolve the latest Bitwarden CLI release");
    }
    // match bw-linux-<version>.zip exactly so the arm64 and -oss variants are not pulled in
    const code = await install(ctx, { via: "gh-release", repo: "bitwarden/clients", tag, asset: `bw-linux-${tag.slice(5)}.zip`, bins: ["bw"] });
    if (code !== 0) throw new Error(`install from ${tag} failed`);
  },
});
