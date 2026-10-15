import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { defineModule } from "../../lib/module";

// i / ii — jump to project directories under ~/code/{p,w,f}
export default defineModule({
  id: "nav",
  async setup(ctx) {
    if (!ctx.dryRun) for (const d of ["p", "w", "f"]) mkdirSync(join(ctx.home, "code", d), { recursive: true });
  },
});
