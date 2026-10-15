import { defineModule } from "../../lib/module";

// sudo askpass — GUI password prompt for non-interactive sudo (e.g. Claude Code). Linux only.
export default defineModule({
  id: "sudo-askpass",
  bin: "zenity",
  install: { linux: { via: "apt", pkg: "zenity" } },
});
