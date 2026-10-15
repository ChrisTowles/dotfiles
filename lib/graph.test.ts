import { describe, expect, test } from "bun:test";
import { order } from "./graph";
import { loadModules } from "./module";
import type { ModuleDef } from "./types";

const m = (id: string, needs: string[] = [], os?: ModuleDef["os"]): ModuleDef => ({ id, needs, os });
const ids = (mods: ModuleDef[]) => mods.map((x) => x.id);

describe("order", () => {
  test("needs come first, ties break by id", () => {
    expect(ids(order([m("c", ["a"]), m("b"), m("a")], "linux"))).toEqual(["a", "b", "c"]);
    expect(ids(order([m("a", ["z"]), m("z")], "linux"))).toEqual(["z", "a"]);
  });
  test("modules off on this OS drop out, and so do needs on them", () => {
    expect(ids(order([m("a", ["w"]), m("w", [], ["win32"])], "linux"))).toEqual(["a"]);
  });
  test("an unknown need is an error", () => {
    expect(() => order([m("a", ["nope"])], "linux")).toThrow(/unknown module "nope"/);
  });
  test("a cycle is an error", () => {
    expect(() => order([m("a", ["b"]), m("b", ["a"])], "linux")).toThrow(/cycle/);
  });
  test("a duplicate id is an error", () => {
    expect(() => order([m("a"), m("a")], "linux")).toThrow(/duplicate/);
  });
  test("the real modules order on every OS", async () => {
    const mods = await loadModules();
    for (const os of ["linux", "darwin", "win32"] as const) expect(order(mods, os).length).toBeGreaterThan(20);
  });
});
