# Jellyfin  install PopOs - Linux


Starting from `https://www.reddit.com/r/pop_os/comments/uvn87r/is_it_possible_to_run_jellyfin_server_on_pop_os/?rdt=42791`


```bash
sudo apt install curl gnupg


curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/jellyfin.gpg

#Fixed command 
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/jellyfin.list


sudo apt update

sudo apt install jellyfin


```


----------------
```bash
sudo apt update && sudo apt upgrade
``
To install the necessary dependencies, run the following command:

```bash
sudo apt install apt-transport-https wget gnupg2 curl
```
Step 1: Add Jellyfin repository
First, you need to add the Jellyfin repository to your system. To do this, run the following commands:

```bash
wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key
sudo apt-key add - echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian $( lsb_release -c -s ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
```


Step 2: Install Jellyfin

Once the repository is added, update your system's package list and install Jellyfin by running the following command:

sudo apt update && sudo apt install jellyfin

## Library Setup

Use the given Library 

```bash
mkdir -p /var/lib/plexmediaserver/Library/Movies

```


I also use the following to set the correct permissions on the Library.


```bash


plex-setup() {

    echo "PLEX folder setup"

    sudo find /var/lib/plexmediaserver/Library -type d -exec chmod 775 {} \;

    sudo chown -R plex.plex /var/lib/plexmediaserver/Library
    # set to inherit permissions
    sudo chmod g+s "/var/lib/plexmediaserver/Library"
}
```



## Downlaod m3u8 with youtube-dl

use the `--hls-prefer-native` flag to download the m3u8 file with youtube-dl. This will ensure that the native HLS downloader is used, which can resume downloads.

```bash
youtube-dl  --hls-prefer-native "https:/1080/index.m3u8" -o "movie.mp4"

```


