import { copyFileSync, existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { defineModule } from "../../lib/module";

/** First `[granted_]sso_<key> = value` in the AWS config (granted-generated profiles use the prefix). */
function ssoValue(config: string, key: string): string | undefined {
  return config.match(new RegExp(`^\\s*(?:granted_)?sso_${key}\\s*=\\s*(\\S+)`, "m"))?.[1];
}

// granted - AWS SSO profile switcher (https://granted.dev). ~/.granted/config
// is linked from ~/code/p/toolbox via that repo's sync manifest, not from here.
export default defineModule({
  id: "granted",
  needs: ["gh"],
  install: {
    linux: { via: "gh-release", repo: "common-fate/granted", asset: "granted_*_linux_x86_64.tar.gz", bins: ["granted", "assume", "assumego"] },
    darwin: { via: "brew", pkg: "granted", tap: "common-fate/granted" },
  },
  aliases: {
    // `assume` must be sourced, not executed — it exports AWS_* into the current shell
    assume: "source assume",
    assumef: "source assume --no-cache",
  },
  commands: {
    "granted-populate": {
      desc: "Regenerate every AWS profile from SSO (backs up ~/.aws/config first)",
      args: "[sso-start-url]",
      async run(ctx, [arg]) {
        // Start URL / region: argument, $AWS_SSO_START_URL / $AWS_SSO_REGION
        // (set them in ~/.zshrc_local.sh), then the first ones in ~/.aws/config
        const file = process.env.AWS_CONFIG_FILE ?? join(ctx.home, ".aws", "config");
        const text = existsSync(file) ? readFileSync(file, "utf8") : "";
        const url = arg ?? process.env.AWS_SSO_START_URL ?? ssoValue(text, "start_url");
        const region = process.env.AWS_SSO_REGION ?? ssoValue(text, "region");
        if (!url) return console.error("No SSO start URL found. Pass one as an argument or set AWS_SSO_START_URL in ~/.zshrc_local.sh"), 1;
        if (text) {
          const backup = `${file}.bak.${new Date().toISOString().replace(/\D/g, "").slice(0, 14)}`;
          copyFileSync(file, backup);
          console.log(`Backed up ${file} -> ${backup}`);
        }
        console.log(`Populating profiles from ${url}${region ? ` (${region})` : ""}...`);
        return ctx.exec(["granted", "sso", "populate", "--prune", ...(region ? ["--sso-region", region] : []), url]);
      },
    },
  },
  async setup(ctx) {
    // granted writes its completions under ~/.granted/zsh_autocomplete/<cmd>/_<cmd>, not stdout
    await ctx.read(["granted", "completion", "-s", "zsh"]);
    for (const cmd of ["granted", "assume"]) {
      const src = join(ctx.home, ".granted", "zsh_autocomplete", cmd, `_${cmd}`);
      if (existsSync(src) && !ctx.dryRun) copyFileSync(src, join(ctx.home, ".zsh", "completions", `_${cmd}`));
    }
  },
});
