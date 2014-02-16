#!/bin/bash

# run as root!!!

DEVICEID=sdc # the device for the SD memory card
RELEASENAME=stage3-armv6j_hardfp-20140113.tar.bz2 # this ought to be changed to the most recent
WGETURL1=http://gentoo.osuosl.org/releases/arm/autobuilds/current-stage3-armv6j_hardfp/
WGETURL2=http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

# try to unmount just in case these are mounted

umount "/dev/${DEVICEID}1"
umount "/dev/${DEVICEID}2"
umount "/dev/${DEVICEID}3"

fdisk /dev/sdc

mkfs.vfat -F 16 "/dev/${DEVICEID}1"
mkswap "/dev/${DEVICEID}2"
mkfs.ext4 "/dev/${DEVICEID}3"

sleep 1

rm -rf /mnt/gentoo
mkdir /mnt/gentoo
mount "/dev/${DEVICEID}3/" /mnt/gentoo

sleep 1

rm -rf /mnt/gentoo/*
mkdir /mnt/gentoo/boot
mount "/dev/${DEVICEID}1" /mnt/gentoo/boot

sleep 1

rm -rf /mnt/gentoo/boot/*

cd /tmp/
rm -rf ./*

wget "${WGETURL1}${RELEASENAME}"
tar xfpj "/tmp/${RELEASENAME}" -C /mnt/gentoo/

wget "${WGETURL2}" 

mkdir /mnt/gentoo/usr
tar xjf /tmp/portage-latest.tar.bz2 -C /mnt/gentoo/usr

cd /tmp/
git clone --depth 1 git://github.com/raspberrypi/firmware/
cd firmware/boot
cp -r ./* /mnt/gentoo/boot
cp -r ../modules /mnt/gentoo/lib

cp /mnt/gentoo/etc/fstab /mnt/gentoo/etc/fstab_backup
echo -e "/dev/mmcblk0p1\t/boot\tauto\tnoauto,noatime\t1\t2" > /mnt/gentoo/etc/fstab
echo -e "/dev/mmcblk0p3\t/\text4\tnoatime\t0\t1" >> /mnt/gentoo/etc/fstab
echo -e "/dev/mmcblk0p2\tnone\tswap\tsw\t0\t0" >> /mnt/gentoo/etc/fstab
nano -w /mnt/gentoo/etc/fstab

echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p3 rootfstype=ext4 elevator=deadline rootwait" > /mnt/gentoo/boot/cmdline.txt

cp /mnt/gentoo/usr/share/zoneinfo/Asia/Riyadh /mnt/gentoo/etc/localtime
echo "Asia/Riyadh" > /mnt/gentoo/etc/timezone

nano /mnt/gentoo/etc/shadow

umount "/dev/${DEVICEID}1"
umount "/dev/${DEVICEID}3"


