# Windows VM on Linux

After no luck getting fusion 360 snap to work. And issues with Windows 11 not having disk drivers for my ASUS ROG Strix Z790-E, and failing to load the drivers off another USB even..... I gave up.

> Root Cause: the bootable ISO i made on pop_os but issue when trying to install it saying it couldn't find drivers. When i burned the same ISO using rufus on windows everything worked!.
 

Trying instead to run windows 11 on qemu.

```bash

sudo apt install qemu-system
sudo apt install virt-manager

sudo apt install qemu-system-x86 qemu-system-arm qemu-utils qemu-kvm
```

Now Open Virtuial Machine Manager from your applications menu or by typing "virt-manager" in a terminal window. This will open the graphical interface for managing virtual machines.

Now creating a new VM, and selecting the ISO file for Windows 11. It can be downloaded from Microsoft's website.


## Install Client tools

https://github.com/virtio-win/virtio-win-pkg-scripts?tab=readme-ov-file

Download the ISO and mount it to the VM.

Install the Agent for Windows.

This will allow you to change the screen resolution, mouse integration, etc.




