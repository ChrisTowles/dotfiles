import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, writeFileSync } from "fs";
import { tmpdir } from "os";
import { join } from "path";
import { findUp, formatterFor, parseEdition, rustEdition } from "./format-on-edit";

describe("parseEdition", () => {
  test("reads a crate's literal edition", () => {
    expect(parseEdition('[package]\nname = "x"\nedition = "2024"\n')).toBe("2024");
  });

  test("reads a workspace.package edition", () => {
    expect(parseEdition('[workspace.package]\nedition = "2021"\n')).toBe("2021");
  });

  test("edition.workspace = true is not a literal edition", () => {
    expect(parseEdition('[package]\nedition.workspace = true\n')).toBeNull();
  });

  test("no edition at all", () => {
    expect(parseEdition('[package]\nname = "x"\n')).toBeNull();
  });
});

describe("rustEdition / findUp", () => {
  test("crate edition wins over workspace edition", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    writeFileSync(join(root, "Cargo.toml"), '[workspace.package]\nedition = "2021"\n');
    const crate = join(root, "crates", "demo", "src");
    mkdirSync(crate, { recursive: true });
    writeFileSync(join(root, "crates", "demo", "Cargo.toml"), '[package]\nedition = "2024"\n');
    expect(rustEdition(crate)).toBe("2024");
  });

  test("walks past an inheriting crate manifest to the workspace root", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    writeFileSync(join(root, "Cargo.toml"), '[workspace.package]\nedition = "2024"\n');
    const crate = join(root, "crates", "demo", "src");
    mkdirSync(crate, { recursive: true });
    writeFileSync(join(root, "crates", "demo", "Cargo.toml"), "[package]\nedition.workspace = true\n");
    expect(rustEdition(crate)).toBe("2024");
  });

  test("defaults to 2021 with no manifest anywhere useful", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    expect(rustEdition(root)).toBe("2021");
  });

  test("findUp returns null when nothing matches", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    expect(findUp(root, "no-such-file-anywhere")).toBeNull();
  });
});

describe("formatterFor", () => {
  test("rust files get rustfmt with a detected edition", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    writeFileSync(join(root, "Cargo.toml"), '[package]\nedition = "2024"\n');
    const file = join(root, "main.rs");
    writeFileSync(file, "fn main() {}\n");
    expect(formatterFor(file)).toEqual(["rustfmt", "--edition", "2024", file]);
  });

  test("prettier-eligible file without a local prettier install is skipped", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    const file = join(root, "app.ts");
    writeFileSync(file, "export const x = 1;\n");
    expect(formatterFor(file)).toBeNull();
  });

  test("prettier-eligible file uses the project's local prettier", () => {
    const root = mkdtempSync(join(tmpdir(), "fmt-hook-"));
    const bin = join(root, "node_modules", ".bin");
    mkdirSync(bin, { recursive: true });
    writeFileSync(join(bin, "prettier"), "#!/bin/sh\n");
    const src = join(root, "src");
    mkdirSync(src);
    const file = join(src, "app.ts");
    writeFileSync(file, "export const x = 1;\n");
    expect(formatterFor(file)).toEqual([join(bin, "prettier"), "--write", file]);
  });

  test("unknown extensions are skipped", () => {
    expect(formatterFor("/tmp/whatever.lock")).toBeNull();
  });
});
