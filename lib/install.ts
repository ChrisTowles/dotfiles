import { existsSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { out, withTmp } from "./helpers";
import type { AptRepo, Ctx, Install } from "./types";

let aptUpdated = false;

async function aptRepo(ctx: Ctx, repo: AptRepo): Promise<void> {
  if ("ppa" in repo) {
    const listed = (await ctx.read(["sh", "-c", `grep -rqs "${repo.ppa}" /etc/apt/sources.list.d/`])).code === 0;
    if (!listed) {
      await ctx.sudo(["add-apt-repository", "-y", `ppa:${repo.ppa}`]);
      aptUpdated = false;
    }
    return;
  }
  const list = `/etc/apt/sources.list.d/${repo.name}.list`;
  const arch = (await out(ctx, ["dpkg", "--print-architecture"])) || "amd64";
  const codename = await out(ctx, ["sh", "-c", ". /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}"]);
  const line = repo.line.replaceAll("{arch}", arch).replaceAll("{keyring}", repo.keyring).replaceAll("{codename}", codename);
  if (!existsSync(repo.keyring)) {
    const store = repo.dearmor ? `gpg --dearmor -o ${repo.keyring}` : `tee ${repo.keyring} >/dev/null`;
    await ctx.sudo(["install", "-m", "0755", "-d", "/etc/apt/keyrings"]);
    await ctx.exec(["sh", "-c", `curl -fsSL ${repo.key} | sudo ${store}`]);
  }
  const current = await Bun.file(list).text().catch(() => "");
  if (current.trim() !== line) {
    await ctx.exec(["sh", "-c", `echo '${line}' | sudo tee ${list} >/dev/null`]);
    aptUpdated = false;
  }
}

/** apt-get install, with one `apt-get update` per run (redone after a repo is added). */
export async function aptInstall(ctx: Ctx, pkgs: string[]): Promise<number> {
  if (!aptUpdated) {
    await ctx.sudo(["apt-get", "update", "-qq"]);
    aptUpdated = true;
  }
  return ctx.sudo(["apt-get", "install", "-y", "-qq", ...pkgs]);
}

/** Resolve `tag: "prefix*"` to the newest matching release tag. */
async function releaseTag(ctx: Ctx, repo: string, tag: string): Promise<string | undefined> {
  if (!tag.endsWith("*")) return tag;
  const prefix = tag.slice(0, -1);
  const jq = `[.[] | select(.tagName | startswith("${prefix}"))][0].tagName`;
  return (await out(ctx, ["gh", "release", "list", "--repo", repo, "--limit", "60", "--json", "tagName", "--jq", jq])) || undefined;
}

/** Download one GitHub release asset into `dir`. Returns the gh exit code. */
async function ghDownload(ctx: Ctx, spec: { repo: string; asset: string; tag?: string }, dir: string): Promise<number> {
  let { asset, tag } = spec;
  if (tag) {
    const resolved = await releaseTag(ctx, spec.repo, tag);
    if (!resolved) {
      if (ctx.dryRun) return ctx.log(`would download the newest ${tag} release of ${spec.repo}`), 0;
      return console.error(`  no ${tag} release in ${spec.repo}`), 1;
    }
    asset = asset.replaceAll("{version}", resolved.slice(tag.length - 1));
    tag = resolved;
  }
  return ctx.exec(["gh", "release", "download", ...(tag ? [tag] : []), "--repo", spec.repo, "--pattern", asset, "-D", dir, "--clobber"]);
}

/** Download a GitHub release asset, unpack it, and install `bins` to /usr/local/bin. */
function ghRelease(ctx: Ctx, spec: Extract<Install, { via: "gh-release" }>): Promise<number> {
  return withTmp("ttd-", async (tmp) => {
    if ((await ghDownload(ctx, spec, tmp)) !== 0) return 1;
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
  });
}

/** Download a .deb (URL, resolver, or GitHub release asset) and apt-install it. */
function deb(ctx: Ctx, spec: Extract<Install, { via: "deb" }>): Promise<number> {
  return withTmp("ttd-deb-", async (tmp) => {
    if (spec.gh) {
      if ((await ghDownload(ctx, spec.gh, tmp)) !== 0) return 1;
    } else {
      const url = typeof spec.url === "function" ? await spec.url(ctx) : spec.url;
      if (!url) return console.error(`  no download URL for ${spec.pkg}`), 1;
      if ((await ctx.exec(["curl", "-fsSL", url, "-o", join(tmp, `${spec.pkg}.deb`)])) !== 0) return 1;
    }
    if (ctx.dryRun) return 0;
    const file = readdirSync(tmp).find((f) => f.endsWith(".deb"));
    return file ? aptInstall(ctx, [join(tmp, file)]) : 1;
  });
}

/** Fetch an install script and run it (the old `curl | sh`). */
function script(ctx: Ctx, spec: Extract<Install, { via: "script" }>): Promise<number> {
  if (ctx.os === "win32") return ctx.exec(["pwsh", "-NoProfile", "-Command", `irm ${spec.url} | iex`]);
  return withTmp("ttd-", async (tmp) => {
    const file = join(tmp, "install.sh");
    if ((await ctx.exec(["curl", "-fsSL", spec.url, "-o", file])) !== 0) return 1;
    return ctx.exec([spec.shell ?? "sh", file, ...(spec.args ?? [])]);
  });
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
    case "deb":
      return deb(ctx, spec);
    case "script":
      return script(ctx, spec);
    case "flatpak":
      await ctx.exec(["flatpak", "remote-add", "--user", "--if-not-exists", "flathub", "https://flathub.org/repo/flathub.flatpakrepo"]);
      return ctx.exec(["flatpak", "install", "--user", "-y", "flathub", spec.id]);
    case "pnpm-global":
      return ctx.exec(["pnpm", "install", "--global", spec.pkg]);
  }
}

/**
 * Ask the package manager whether `spec` is installed — for things that are not
 * a binary on PATH (GUI apps, casks, libraries). False when the backend cannot tell.
 */
export async function installedBy(ctx: Ctx, spec: Install): Promise<boolean> {
  const ok = async (argv: string[]) => (await ctx.read(argv)).code === 0;
  switch (spec.via) {
    case "apt":
      return ok(["dpkg", "-s", [spec.pkg].flat()[0]]);
    case "deb":
      return ok(["dpkg", "-s", spec.pkg]);
    case "brew":
      if (spec.app && existsSync(`/Applications/${spec.app}.app`)) return true;
      return ok(["brew", "list", spec.cask ? "--cask" : "--formula", spec.pkg]);
    case "winget":
      return ok(["winget", "list", "--id", spec.id, "--exact"]);
    case "flatpak":
      return ok(["flatpak", "info", "--user", spec.id]);
    default:
      return false;
  }
}

export function describe(spec: Install): string {
  switch (spec.via) {
    case "apt": return `apt ${[spec.pkg].flat().join(" ")}`;
    case "brew": return `brew ${spec.cask ? "--cask " : ""}${spec.pkg}`;
    case "winget": return `winget ${spec.id}`;
    case "cargo": return `cargo ${spec.git ?? spec.crate}`;
    case "gh-release": return `gh-release ${spec.repo}`;
    case "deb": return `deb ${spec.pkg}`;
    case "script": return `script ${spec.url}`;
    case "flatpak": return `flatpak ${spec.id}`;
    case "pnpm-global": return `pnpm -g ${spec.pkg}`;
  }
}
