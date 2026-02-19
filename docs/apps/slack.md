# Slack

Team communication app. Installed automatically via `zsh-dotfiles-setup`.

See [`functions/77-slack.sh`](../../functions/77-slack.sh) for install logic.

## Notes

- Uses native .deb package, not Flatpak
- The .deb install adds Slack's apt repo for future updates
- Requires `jq` for fetching the download URL
- Cosmic tray fix tracked at [cosmic-epoch#2733](https://github.com/pop-os/cosmic-epoch/issues/2733)
