import type { ModuleDef, OS } from "./types";
import { osOf } from "./module";

/**
 * Topological order of the modules that run on `os`.
 * An unknown need or a cycle is an error. A need that is off on this OS is dropped.
 * Ties break by id, so the order is stable.
 */
export function order<M extends ModuleDef>(mods: M[], os: OS): M[] {
  const ids = new Set(mods.map((m) => m.id));
  if (ids.size !== mods.length) throw new Error("duplicate module id");
  for (const m of mods)
    for (const n of m.needs ?? []) if (!ids.has(n)) throw new Error(`${m.id} needs unknown module "${n}"`);

  const live = mods.filter((m) => osOf(m).includes(os));
  const liveIds = new Set(live.map((m) => m.id));
  const byId = new Map(live.map((m) => [m.id, m]));
  const indegree = new Map(live.map((m) => [m.id, (m.needs ?? []).filter((n) => liveIds.has(n)).length]));
  const dependents = new Map<string, string[]>();
  for (const m of live)
    for (const n of m.needs ?? []) if (liveIds.has(n)) dependents.set(n, [...(dependents.get(n) ?? []), m.id]);

  const ready = live.filter((m) => indegree.get(m.id) === 0).map((m) => m.id).sort();
  const out: M[] = [];
  while (ready.length) {
    const id = ready.shift()!;
    out.push(byId.get(id)!);
    for (const d of dependents.get(id) ?? []) {
      indegree.set(d, indegree.get(d)! - 1);
      if (indegree.get(d) === 0) {
        ready.push(d);
        ready.sort();
      }
    }
  }
  if (out.length !== live.length) {
    const stuck = live.filter((m) => !out.includes(m)).map((m) => m.id);
    throw new Error(`dependency cycle among: ${stuck.join(", ")}`);
  }
  return out;
}
