import { defineModule } from "../../lib/module";

// PostgreSQL client (https://www.postgresql.org/docs/current/app-psql.html).
// macOS: Homebrew libpq is keg-only, so its bin dir goes on PATH.
export default defineModule({
  id: "psql",
  install: {
    linux: { via: "apt", pkg: "postgresql-client" },
    darwin: { via: "brew", pkg: "libpq" },
  },
  path: [{ darwin: "/opt/homebrew/opt/libpq/bin" }],
});
