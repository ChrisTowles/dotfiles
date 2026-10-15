import { defineModule } from "../../lib/module";

// Bitwarden CLI (https://bitwarden.com/help/cli/). Linux only — on macOS it is
// installed by hand (`brew install bitwarden-cli`).
export default defineModule({
  id: "bitwarden",
  needs: ["gh"],
  bin: "bw",
  install: {
    // bitwarden/clients ships browser/desktop/web releases from one repo, so take the
    // newest cli-v* tag; the exact asset name keeps the arm64 and -oss builds out
    linux: { via: "gh-release", repo: "bitwarden/clients", tag: "cli-v*", asset: "bw-linux-{version}.zip", bins: ["bw"] },
  },
  completions: [{ shell: "zsh", argv: ["bw", "completion", "--shell", "zsh"], name: "_bw" }],
});
