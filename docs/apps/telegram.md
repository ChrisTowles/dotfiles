# Telegram

## Install

```bash
# Download and install to /opt (system-wide)
cd /tmp
wget https://telegram.org/dl/desktop/linux -O telegram.tar.xz
tar -xf telegram.tar.xz
sudo mv Telegram /opt/
sudo ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram-desktop

# Create desktop entry
sudo tee /usr/share/applications/telegram.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Telegram Desktop
Comment=Official Telegram Desktop Client
Exec=/opt/Telegram/Telegram -- %u
Icon=telegram
Terminal=false
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;
EOF

rm telegram.tar.xz
```

## Update

Telegram auto-updates itself. No manual action needed.

## Uninstall

```bash
sudo rm -rf /opt/Telegram
sudo rm /usr/local/bin/telegram-desktop
sudo rm /usr/share/applications/telegram.desktop
```
