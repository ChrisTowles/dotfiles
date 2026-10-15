import { defineModule } from "../../lib/module";

// mise - polyglot tool version manager (https://mise.jdx.dev)
// Used for the JDK (Android builds) only. Node stays on fnm, so mise is not
// activated with --shims and does not fight over node.
export default defineModule({
  id: "mise",
  install: { linux: { via: "script", url: "https://mise.run" } },
  path: ["~/.local/bin"],
  completions: [{ shell: "zsh", argv: ["mise", "completion", "zsh"], name: "_mise" }],
  async setup(ctx) {
    ctx.log("JDK 21 (Temurin) for Android builds");
    await ctx.exec(["mise", "use", "-g", "java@temurin-21"]);
  },
});
