# Discord

## Install

```bash
wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
sudo apt install -y /tmp/discord.deb
```

## Update

The .deb install adds Discord's apt repo, so updates come through `sudo apt upgrade`.

## Uninstall

```bash
sudo apt remove discord
```
