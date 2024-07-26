#!/bin/bash
# credit for this file goes to https://forums.raspberrypi.com/viewtopic.php?p=2239835#p2239835
if [ `id -u` -ne 0 ]
  then echo Please run this script as root or using sudo!
  exit
fi
IMG=2024-07-04-raspios-bookworm-arm64-lite.img
IMGDIR=raspbian
LOOP=$(losetup -Pf ${IMG} --show)
apt-get install qemu qemu-user-static binfmt-support
mkdir -p $IMGDIR
mount -o rw ${LOOP}p2  $IMGDIR
mount -o rw ${LOOP}p1 $IMGDIR/boot
# mount binds
mount --bind /dev $IMGDIR/dev
mount --bind /sys $IMGDIR/sys
mount --bind /proc $IMGDIR/proc
mount --bind /dev/pts $IMGDIR/dev/pts
# ld.so.preload fix
[ -f $IMGDIR/etc/ld.so.preload ] && sed -i 's/^/#/g' $IMGDIR/etc/ld.so.preload
# hostname fix
grep -q $(hostname) $IMGDIR/etc/hosts || echo "127.0.1.1 $(hostname)"  >> $IMGDIR/etc/hosts
# copy qemu binary
cp /usr/bin/qemu-arm-static $IMGDIR/usr/bin/
# chroot 
chroot $IMGDIR su - pi
fstrim -v $IMGDIR # trim unused space on loop device
# revert ld.so.preload fix
# sed -i 's/^#//g' $IMGDIR/etc/ld.so.preload
umount $IMGDIR/{dev/pts,proc,sys,dev,boot,}
losetup -d $LOOP
du -sh $IMG