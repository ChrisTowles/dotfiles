import { describe, expect, test } from "bun:test";
import { makeCtx } from "./ctx";
import { commandList, generate } from "./emit";
import { loadModules } from "./module";
import type { Module } from "./types";

const fake = (def: Partial<Module>): Module => ({ id: "x", dir: "/nonexistent", ...def }) as Module;

describe("generate", () => {
  test("zsh: env, path, aliases and command aliases", async () => {
    const mod = fake({
      env: { FOO: "it's" },
      path: ["/opt/bin"],
      aliases: { g: "lazygit", only: { pwsh: "x" } },
      commands: { hi: { desc: "d", run: async () => {} }, quiet: { desc: "d", alias: false, run: async () => {} } },
    });
    const text = await generate([mod], "zsh", makeCtx({ os: "linux" }));
    expect(text).toContain(`export FOO='it'\\''s'`);
    expect(text).toContain(`path=('/opt/bin' $path)`);
    expect(text).toContain(`alias g='lazygit'`);
    expect(text).not.toContain("alias only=");
    expect(text).toContain(`alias hi='ttd hi'`);
    expect(text).not.toContain("alias quiet=");
    expect(text).toContain("compdef _ttd ttd");
  });
  test("pwsh: aliases are functions that drop a built-in alias first", async () => {
    const text = await generate([fake({ aliases: { gc: "ttd git-ai-commit" } })], "pwsh", makeCtx({ os: "win32" }));
    expect(text).toContain("Remove-Item -Force -ErrorAction SilentlyContinue Alias:gc");
    expect(text).toContain("function global:gc { ttd git-ai-commit @args }");
  });
  test("an uninstalled module emits nothing", async () => {
    const mod = fake({ id: "nope", install: { linux: { via: "apt", pkg: "x" } }, bin: "definitely-not-on-path", aliases: { n: "nope" } });
    expect(await generate([mod], "zsh", makeCtx({ os: "linux" }))).not.toContain("alias n=");
  });
});

describe("commandList", () => {
  test("command names are unique across modules", async () => {
    const names = commandList(await loadModules()).map((c) => c.name);
    expect(new Set(names).size).toBe(names.length);
  });
});
