import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { ALL_OS, type Module, type ModuleDef, type OS } from "./types";
import { REPO, pickOS } from "./platform";

/** Identity helper that gives a module file its types. */
export function defineModule(def: ModuleDef): ModuleDef {
  return def;
}

/** The OSes a module runs on: explicit `os`, else the keys of `install`, else all three. */
export function osOf(m: ModuleDef): OS[] {
  if (m.os) return m.os;
  if (m.install) return ALL_OS.filter((os) => pickOS(m.install!, os) !== undefined);
  return ALL_OS;
}

export async function loadModules(repo = REPO): Promise<Module[]> {
  const files = [...new Bun.Glob("modules/*/module.ts").scanSync(repo)].sort();
  const mods = await Promise.all(
    files.map(async (rel) => {
      const file = join(repo, rel);
      const def = (await import(file)).default as ModuleDef;
      if (!def?.id) throw new Error(`${rel}: default export is not a module`);
      const dir = dirname(file);
      if (def.id !== dir.split(/[\\/]/).pop()) throw new Error(`${rel}: id "${def.id}" must match its folder`);
      return { ...def, dir };
    }),
  );
  return mods;
}

/** A module's verbatim shell snippet: init.<os>.<ext> wins over init.<ext>. */
export function snippetPath(m: Module, ext: "zsh" | "ps1", os: OS): string | undefined {
  return [`init.${os}.${ext}`, `init.${ext}`].map((f) => join(m.dir, f)).find((p) => existsSync(p));
}
