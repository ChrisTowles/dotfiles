import { appendFileSync, existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { defineModule } from "../../lib/module";
import { out } from "../../lib/helpers";

/** The justfile `just` would use from `dir`: walks up, matching justfile/.justfile in any case. */
export function justFile(dir = process.cwd()): string | undefined {
  for (;;) {
    const hit = readdirSync(dir).find((f) => /^\.?justfile$/i.test(f));
    if (hit) return join(dir, hit);
    const up = dirname(dir);
    if (up === dir) return;
    dir = up;
  }
}

// just - command runner (https://just.systems)
export default defineModule({
  id: "just",
  needs: ["rust"],
  install: {
    linux: { via: "cargo", crate: "just", locked: true },
    darwin: { via: "brew", pkg: "just" },
    win32: { via: "winget", id: "Casey.Just" },
  },
  completions: [
    { shell: "zsh", argv: ["just", "--completions", "zsh"], name: "_just" },
    { shell: "pwsh", argv: ["just", "--completions", "powershell"], name: "just" },
  ],
  aliases: { jn: "ttd just-new" },
  commands: {
    "just-file": {
      desc: "Print the justfile in effect for the current dir",
      async run() {
        const f = justFile();
        if (!f) return 1;
        console.log(f);
      },
    },
    "just-new": {
      desc: "Append a recipe to the justfile (creates ./justfile if none); no command opens it in $EDITOR",
      args: '[-d "doc"] <name> [command…]',
      async run(ctx, argv) {
        let doc = "";
        if (argv[0] === "-d") [, doc, ...argv] = argv;
        const [name, ...body] = argv;
        if (!name) return console.error('usage: jn [-d "doc comment"] <name> [command...]'), 1;
        let file = justFile();
        if (!file) {
          file = join(process.cwd(), "justfile");
          console.log(` Creating ${file}`);
          writeFileSync(file, "");
        }
        const summary = await out(ctx, ["just", "--justfile", file, "--summary"]);
        if (summary.split(/\s+/).includes(name)) return console.error(`Recipe '${name}' already exists in ${file}`), 1;
        const text = existsSync(file) ? readFileSync(file, "utf8") : "";
        // Blank line before the new recipe, unless the file is empty or ends with one
        const sep = text && !text.endsWith("\n\n") ? (text.endsWith("\n") ? "\n" : "\n\n") : "";
        const cmd = body.join(" ") || `echo "TODO: ${name}"`;
        appendFileSync(file, `${sep}${doc ? `# ${doc}\n` : ""}${name}:\n    ${cmd}\n`);
        await ctx.exec(["just", "--justfile", file, "--color", "always", "--show", name]);
        if (!body.length && process.env.EDITOR) Bun.spawn([...process.env.EDITOR.split(" "), file], { stdio: ["ignore", "ignore", "ignore"] }).unref();
      },
    },
  },
});
