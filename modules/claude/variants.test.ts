import { describe, expect, test } from "bun:test";
import { rootSlotFlags, scopeAgents } from "./variants";

describe("rootSlotFlags", () => {
  test("root slot: remote control", () => {
    expect(rootSlotFlags([], true)).toEqual(["--remote-control"]);
    expect(rootSlotFlags(["--resume"], true)).toEqual(["--remote-control"]);
  });

  test("outside the root slot: nothing", () => {
    expect(rootSlotFlags([], false)).toEqual([]);
  });

  test("subcommands take no flags", () => {
    expect(rootSlotFlags(["agents"], true)).toEqual([]);
  });
});

describe("scopeAgents", () => {
  test("agents is scoped to the repo", () => {
    expect(scopeAgents(["agents"], "/r")).toEqual(["agents", "--cwd", "/r"]);
    expect(scopeAgents(["agents", "--json"], "/r")).toEqual(["agents", "--cwd", "/r", "--json"]);
  });

  test("an explicit --cwd wins", () => {
    expect(scopeAgents(["agents", "--cwd", "/x"], "/r")).toEqual(["agents", "--cwd", "/x"]);
  });
});
