import { mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AptRepo, Ctx, Install } from "./types";

let aptUpdated = false;

async function aptRepo(ctx: Ctx, repo: AptRepo): Promise<void> {
  const list = `/etc/apt/sources.list.d/${repo.name}.list`;
  const arch = (await ctx.read(["dpkg", "--print-architecture"])).stdout.trim() || "amd64";
  const codename = (await ctx.read(["sh", "-c", ". /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}"])).stdout.trim();
  const line = repo.line.replaceAll("{arch}", arch).replaceAll("{keyring}", repo.keyring).replaceAll("{codename}", codename);
  if (!(await Bun.file(repo.keyring).exists())) {
    const fetch = `curl -fsSL ${repo.key}`;
    const store = repo.dearmor ? `gpg --dearmor -o ${repo.keyring}` : `tee ${repo.keyring} >/dev/null`;
    await ctx.sudo(["install", "-m", "0755", "-d", "/etc/apt/keyrings"]);
    await ctx.exec(["sh", "-c", `${fetch} | sudo ${store}`]);
  }
  const current = await Bun.file(list).text().catch(() => "");
  if (current.trim() !== line) {
    await ctx.exec(["sh", "-c", `echo '${line}' | sudo tee ${list} >/dev/null`]);
    aptUpdated = false;
  }
}

async function aptInstall(ctx: Ctx, pkgs: string[]): Promise<number> {
  if (!aptUpdated) {
    await ctx.sudo(["apt-get", "update", "-qq"]);
    aptUpdated = true;
  }
  return ctx.sudo(["apt-get", "install", "-y", "-qq", ...pkgs]);
}

/** Download a GitHub release asset, unpack it, and install `bins` to /usr/local/bin. */
async function ghRelease(ctx: Ctx, spec: Extract<Install, { via: "gh-release" }>): Promise<number> {
  const tmp = mkdtempSync(join(tmpdir(), "ttd-"));
  try {
    const dl = ["gh", "release", "download", ...(spec.tag ? [spec.tag] : []), "--repo", spec.repo, "--pattern", spec.asset, "-D", tmp, "--clobber"];
    if ((await ctx.exec(dl)) !== 0) return 1;
    if (ctx.dryRun) return 0;
    for (const f of readdirSync(tmp)) {
      const p = join(tmp, f);
      if (/\.(tar\.gz|tgz|tar\.xz)$/.test(f)) await ctx.exec(["tar", "xf", p, "-C", tmp]);
      else if (f.endsWith(".zip")) await ctx.exec(["unzip", "-qo", p, "-d", tmp]);
      else if (f.endsWith(".bz2")) await ctx.exec(["bunzip2", "-f", p]);
    }
    const files = readdirSync(tmp, { recursive: true, withFileTypes: true }).filter((e) => e.isFile());
    let code = 0;
    for (const bin of spec.bins) {
      // a bare asset (no archive) is the binary itself: the one file left with no archive extension
      const hit = files.find((e) => e.name === bin) ?? (spec.bins.length === 1 ? files.find((e) => !/\.(gz|tgz|xz|zip|bz2)$/.test(e.name)) : undefined);
      if (!hit) {
        console.error(`  ${bin} not found in ${spec.repo} release`);
        code = 1;
        continue;
      }
      code ||= await ctx.sudo(["install", join(hit.parentPath, hit.name), `/usr/local/bin/${bin}`]);
    }
    return code;
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
}

/** Fetch an install script and run it (the old `curl | sh`). */
async function script(ctx: Ctx, spec: Extract<Install, { via: "script" }>): Promise<number> {
  if (ctx.os === "win32") return ctx.exec(["pwsh", "-NoProfile", "-Command", `irm ${spec.url} | iex`]);
  const tmp = mkdtempSync(join(tmpdir(), "ttd-"));
  const file = join(tmp, "install.sh");
  try {
    if ((await ctx.exec(["curl", "-fsSL", spec.url, "-o", file])) !== 0) return 1;
    return await ctx.exec([spec.shell ?? "sh", file, ...(spec.args ?? [])]);
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
}

export async function install(ctx: Ctx, spec: Install): Promise<number> {
  switch (spec.via) {
    case "apt":
      if (spec.repo) await aptRepo(ctx, spec.repo);
      return aptInstall(ctx, [spec.pkg].flat());
    case "brew":
      if (spec.tap) await ctx.exec(["brew", "tap", spec.tap]);
      return ctx.exec(["brew", "install", ...(spec.cask ? ["--cask"] : []), spec.pkg]);
    case "winget":
      return ctx.exec(["winget", "install", "--id", spec.id, "--exact", "--silent", "--accept-package-agreements", "--accept-source-agreements"]);
    case "cargo":
      return ctx.exec(["cargo", "install", ...(spec.locked ? ["--locked"] : []), ...(spec.git ? ["--git", spec.git] : [spec.crate])]);
    case "gh-release":
      return ghRelease(ctx, spec);
    case "script":
      return script(ctx, spec);
    case "flatpak":
      await ctx.exec(["flatpak", "remote-add", "--user", "--if-not-exists", "flathub", "https://flathub.org/repo/flathub.flatpakrepo"]);
      return ctx.exec(["flatpak", "install", "--user", "-y", "flathub", spec.id]);
    case "pnpm-global":
      return ctx.exec(["pnpm", "install", "--global", spec.pkg]);
  }
}

export function describe(spec: Install): string {
  switch (spec.via) {
    case "apt": return `apt ${[spec.pkg].flat().join(" ")}`;
    case "brew": return `brew ${spec.cask ? "--cask " : ""}${spec.pkg}`;
    case "winget": return `winget ${spec.id}`;
    case "cargo": return `cargo ${spec.git ?? spec.crate}`;
    case "gh-release": return `gh-release ${spec.repo}`;
    case "script": return `script ${spec.url}`;
    case "flatpak": return `flatpak ${spec.id}`;
    case "pnpm-global": return `pnpm -g ${spec.pkg}`;
  }
}
