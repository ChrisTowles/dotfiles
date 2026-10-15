import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { PUSH_FILE, type CommandEntry } from "./emit";
import { fzf } from "./helpers";

/**
 * Bare `ttd`: pick a command in fzf. A command without args runs at once; one
 * with args is handed back to the shell wrapper, which puts it on the prompt.
 */
export async function pick(cmds: CommandEntry[], run: (name: string) => Promise<number>): Promise<number> {
  if (!Bun.which("fzf")) {
    console.error("ttd: the picker needs fzf — run `ttd help` for the list");
    return 1;
  }
  const width = Math.max(...cmds.map((c) => c.name.length + (c.args ? c.args.length + 1 : 0)));
  const rows = cmds.map((c) => `${c.name}\t${`${c.name}${c.args ? ` ${c.args}` : ""}`.padEnd(width)}  ${c.desc}`);
  const line = await fzf(rows, [
    "--delimiter=\t", "--with-nth=2", "--tiebreak=begin", "--layout=reverse", "--height=60%",
    "--border=rounded", "--info=inline", "--prompt=ttd > ",
    "--header=enter run · a command with args goes on the prompt",
    "--preview=ttd help {1}", "--preview-window=right,45%,wrap",
  ]);
  if (!line) return 130;
  const name = line.split("\t")[0];
  const entry = cmds.find((c) => c.name === name)!;
  if (entry.args) {
    mkdirSync(dirname(PUSH_FILE), { recursive: true });
    writeFileSync(PUSH_FILE, `ttd ${name} `);
    return 0;
  }
  console.log(`$ ttd ${name}`);
  return run(name);
}
