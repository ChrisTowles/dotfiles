import { join } from "node:path";
import { sudoCopyIfChanged } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Kernel tuning: higher inotify limits for dev tooling (VS Code, file watchers)
export default defineModule({
  id: "sysctl",
  os: ["linux"],
  async setup(ctx) {
    if (await sudoCopyIfChanged(ctx, join(ctx.dir, "90-dotfiles.conf"), "/etc/sysctl.d/90-dotfiles.conf"))
      await ctx.sudo(["sysctl", "--system", "-q"]);
  },
});
