# Plex Setup - Linux

Download from <plex.tv>

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
