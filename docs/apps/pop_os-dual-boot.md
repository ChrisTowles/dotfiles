# Pop!_OS Dual Boot


https://github.com/spxak1/weywot/blob/main/Pop_OS_Dual_Boot.md


```

/dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi

```


sudo mount /dev/vme0n1p1@ /mnt



sudo cp -ax /mnt/EFI/Microsoft /boot/efi/EFI 

sudo cp -ax Microsoft /boot/efi/EFI