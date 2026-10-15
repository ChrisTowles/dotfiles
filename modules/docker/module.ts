import { appInstalled, out } from "../../lib/helpers";
import { defineModule } from "../../lib/module";

// Docker Engine (Linux) / Docker Desktop (macOS, Windows) — https://docs.docker.com/engine/install/
export default defineModule({
  id: "docker",
  installed: appInstalled({ bins: ["docker"], mac: "Docker", winget: "Docker.DockerDesktop" }),
  install: {
    linux: {
      via: "apt",
      pkg: ["docker-ce", "docker-ce-cli", "containerd.io", "docker-buildx-plugin", "docker-compose-plugin"],
      repo: {
        name: "docker",
        key: "https://download.docker.com/linux/ubuntu/gpg",
        keyring: "/etc/apt/keyrings/docker.asc",
        line: "deb [arch={arch} signed-by={keyring}] https://download.docker.com/linux/ubuntu {codename} stable",
      },
    },
    darwin: { via: "brew", pkg: "docker", cask: true },
    win32: { via: "winget", id: "Docker.DockerDesktop" },
  },
  completions: [
    { shell: "zsh", argv: ["docker", "completion", "zsh"], name: "_docker" },
    { shell: "pwsh", argv: ["docker", "completion", "powershell"], name: "docker" },
  ],
  async setup(ctx) {
    if (ctx.os !== "linux") return;
    // docker group avoids needing sudo
    const user = process.env.USER ?? "";
    if (!(await out(ctx, ["id", "-nG", user])).split(" ").includes("docker")) {
      await ctx.sudo(["usermod", "-aG", "docker", user]);
      ctx.notice(`Added ${user} to the docker group — log out and back in for it to take effect`);
    }
    if ((await ctx.read(["systemctl", "is-enabled", "docker"])).code !== 0) await ctx.sudo(["systemctl", "enable", "--now", "docker"]);
  },
});
