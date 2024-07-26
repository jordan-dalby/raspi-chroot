#!/bin/bash
IMG=2024-07-04-raspios-bookworm-arm64-lite.img
IMGDIR=raspbian
chroot $IMGDIR su - pi
fstrim -v $IMGDIR # trim unused space on loop device
# revert ld.so.preload fix
# sed -i 's/^#//g' $IMGDIR/etc/ld.so.preload
umount $IMGDIR/{dev/pts,proc,sys,dev,boot,}
losetup -d $LOOP
du -sh $IMG