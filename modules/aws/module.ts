import { join } from "node:path";
import { withTmp } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// AWS CLI v2. `assume` / `assumef` live in the granted module.
export default defineModule({
  id: "aws",
  install: { win32: { via: "winget", id: "Amazon.AWSCLI" } },
  os: ["linux", "darwin", "win32"],
  async setup(ctx) {
    if (ctx.os !== "win32" && !ctx.has("aws")) {
      await withTmp("ttd-aws-", async (tmp) => {
        if (ctx.os === "darwin") {
          await ctx.exec(["curl", "-fsSL", "https://awscli.amazonaws.com/AWSCLIV2.pkg", "-o", join(tmp, "AWSCLIV2.pkg")]);
          await ctx.sudo(["installer", "-pkg", join(tmp, "AWSCLIV2.pkg"), "-target", "/"]);
        } else {
          await ctx.exec(["curl", "-fsSL", "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip", "-o", join(tmp, "awscliv2.zip")]);
          await ctx.exec(["unzip", "-qo", join(tmp, "awscliv2.zip"), "-d", tmp]);
          await ctx.sudo([join(tmp, "aws", "install")]);
        }
      });
    }
    if (ctx.os !== "win32" && ctx.has("aws_completer"))
      await ctx.write(join(ctx.home, ".zsh", "completions", "_aws"), "#compdef aws\nautoload -Uz bashcompinit && bashcompinit\ncomplete -C aws_completer aws\n");
  },
});
