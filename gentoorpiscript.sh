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

# see http://forums.gentoo.org/viewtopic-t-979638-start-0.html
echo -e "VIDEO_CARDS=\"exynos\"" >> /mnt/gentoo/usr/portage/make.conf
echo -e ">=x11-libs/libdrm-2.4.46 libkms" >> /mnt/gentoo/usr/portage/package.use


nano /mnt/gentoo/etc/shadow

cat -e "#!/bin/bash" > /mnt/gentoo/root/initialconfig.sh
cat -e "cd /etc/init.d/" >> /mnt/gentoo/root/initialconfig.sh
cat -e "cp net.lo net.eth0" >> /mnt/gentoo/root/initialconfig.sh

cat -e "rc-config start net.eth0" >> /mnt/gentoo/root/initialconfig.sh
cat -e "rc-config add net.eth0 boot" >> /mnt/gentoo/root/initialconfig.sh

cat -e "eselect profile set 26" >> /mnt/gentoo/root/initialconfig.sh

cat -e "nano /etc/rc.conf" >> /mnt/gentoo/root/initialconfig.sh

cat -e "rc-update add swclock" >> /mnt/gentoo/root/initialconfig.sh
cat -e "rc-update del hwclock" >> /mnt/gentoo/root/initialconfig.sh

cat -e "date 021004212014" >> /mnt/gentoo/root/initialconfig.sh

cat -e "emerge --ask htop ntp" >> /mnt/gentoo/root/initialconfig.sh

cat -e "rc-update add ntp-client default" >> /mnt/gentoo/root/initialconfig.sh

cat -e "rc-update add sshd default" >> /mnt/gentoo/root/initialconfig.sh
cat -e "/etc/init.d/sshd start" >> /mnt/gentoo/root/initialconfig.sh

cat -e "emerge --ask raspberrypi-userland" >> /mnt/gentoo/root/initialconfig.sh


umount "/dev/${DEVICEID}1"
umount "/dev/${DEVICEID}3"


