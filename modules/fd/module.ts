import { defineModule } from "../../lib/module";

// fd - fast find, used by fzf
export default defineModule({
  id: "fd",
  needs: ["rust"],
  // Probe with `fd --version`, not a PATH lookup: a broken npm fd-find shim
  // (postinstall never fetched the binary) once shadowed fd and passed the
  // existence check while failing every actual invocation.
  installed: async (ctx) => (await ctx.read(["fd", "--version"])).code === 0,
  install: {
    linux: { via: "cargo", crate: "fd-find" },
    darwin: { via: "cargo", crate: "fd-find" },
    win32: { via: "winget", id: "sharkdp.fd" },
  },
});
