import { existsSync } from "node:fs";
import { join } from "node:path";
import { withTmp } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Android SDK (https://developer.android.com/tools) — needed to build the
// Capacitor shell in ~/code/p/playpass. The JDK comes from the mise module.
const CMDTOOLS = "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip";
const sdk = (home: string) => join(home, "Android", "Sdk");

export default defineModule({
  id: "android",
  needs: ["mise"],
  os: ["linux"],
  installed: (ctx) => existsSync(join(sdk(ctx.home), "cmdline-tools", "latest", "bin", "sdkmanager")),
  env: { ANDROID_HOME: "~/Android/Sdk", ANDROID_SDK_ROOT: "~/Android/Sdk" },
  path: ["~/Android/Sdk/cmdline-tools/latest/bin", "~/Android/Sdk/platform-tools"],
  async setup(ctx) {
    const latest = join(sdk(ctx.home), "cmdline-tools", "latest");
    const sdkmanager = join(latest, "bin", "sdkmanager");
    if (!existsSync(sdkmanager)) {
      // cmdline-tools is the bootstrap: sdkmanager installs everything else
      ctx.log("installing Android command-line tools");
      await withTmp("ttd-android-", async (tmp) => {
        if ((await ctx.exec(["curl", "-fsSL", "-o", join(tmp, "cmdtools.zip"), CMDTOOLS])) !== 0) throw new Error("download failed");
        await ctx.exec(["unzip", "-q", join(tmp, "cmdtools.zip"), "-d", tmp]);
        await ctx.exec(["mkdir", "-p", join(sdk(ctx.home), "cmdline-tools")]);
        await ctx.exec(["rm", "-rf", latest]);
        await ctx.exec(["mv", join(tmp, "cmdline-tools"), latest]);
      });
    }
    await ctx.exec(["sh", "-c", `yes | "${sdkmanager}" --licenses >/dev/null 2>&1`]);
    await ctx.exec([sdkmanager, "--install", "platform-tools", "platforms;android-36", "build-tools;36.0.0"]);
  },
});
