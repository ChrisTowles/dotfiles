import { defineModule } from "../../lib/module";

// PostgreSQL client (https://www.postgresql.org/docs/current/app-psql.html).
// macOS: Homebrew libpq is keg-only, so its bin dir goes on PATH.
export default defineModule({
  id: "psql",
  install: {
    linux: { via: "apt", pkg: "postgresql-client" },
    darwin: { via: "brew", pkg: "libpq" },
  },
  installed: (ctx) => ctx.has("psql") || (ctx.os === "darwin" && Bun.file("/opt/homebrew/opt/libpq/bin/psql").size > 0),
  path: [{ darwin: "/opt/homebrew/opt/libpq/bin" }],
});
