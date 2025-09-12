# Mullvad VPN Quick Guide

## Overview
Mullvad is a privacy-focused VPN service based in Sweden. Known for its no-logs policy, anonymous accounts, and strong privacy principles.

## Key Features
- **Anonymous Accounts**: No email or personal info required
- **Flat Rate**: €5/month for all users
- **No Logs**: Verified no-logging policy
- **WireGuard**: Modern, fast VPN protocol
- **Open Source**: Apps and infrastructure are open source
- **Multi-Platform**: Linux, Windows, macOS, iOS, Android

## Installation

### Linux CLI

https://mullvad.net/en/download/vpn/linux


```bash
# Download and install
wget https://mullvad.net/download/app/deb/latest -O mullvad-vpn.deb
sudo dpkg -i mullvad-vpn.deb

# Or via repository
sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list
sudo apt update && sudo apt install mullvad-vpn
```

### Account number

Your account number acts as your username and password for the Mullvad VPN service.

I have mine securely stored in Bitwarden.


### CLI Commands

```bash
# Login with account number
mullvad account login 

# Connect to VPN
mullvad connect

# Disconnect
mullvad disconnect

# Check status
mullvad status

# List relays
mullvad relay list

# Set relay location
mullvad relay set location us nyc
```


### Enable/disable features

```bash
mullvad lan set allow
mullvad auto-connect set on
mullvad lockdown-mode set on
```
