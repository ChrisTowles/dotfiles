import { describe, expect, test } from "bun:test";
import { join } from "node:path";
import { HOME, REPO, expandValue, pickOS, resolveTarget } from "./platform";

describe("resolveTarget", () => {
  test("config: is the native config dir", () => {
    expect(resolveTarget("config:lazygit/config.yml", "linux")).toBe(join(HOME, ".config", "lazygit", "config.yml"));
    expect(resolveTarget("config:lazygit/config.yml", "darwin")).toBe(join(HOME, "Library", "Application Support", "lazygit", "config.yml"));
  });
  test("xdg: is ~/.config on macOS too", () => {
    expect(resolveTarget("xdg:tmux/tmux.conf", "darwin")).toBe(join(HOME, ".config", "tmux", "tmux.conf"));
  });
  test("~ and {repo} expand", () => {
    expect(resolveTarget("~/.zshrc", "linux")).toBe(join(HOME, ".zshrc"));
    expect(expandValue("{repo}/modules/broot")).toBe(`${REPO}/modules/broot`);
    expect(expandValue("/abs/path")).toBe("/abs/path");
  });
});

describe("pickOS", () => {
  test("a per-OS map picks this OS", () => {
    expect(pickOS({ linux: "a", darwin: "b" }, "darwin")).toBe("b");
    expect(pickOS({ linux: "a" }, "win32")).toBeUndefined();
  });
  test("unix covers linux and darwin, and an OS key wins over it", () => {
    expect(pickOS({ unix: "u", win32: "w" }, "darwin")).toBe("u");
    expect(pickOS({ unix: "u", linux: "l" }, "linux")).toBe("l");
    expect(pickOS({ unix: "u" }, "win32")).toBeUndefined();
  });
  test("a plain value applies everywhere", () => {
    expect(pickOS("x", "win32")).toBe("x");
  });
});
