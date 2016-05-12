#!/bin/sh

#Download and extract Ubilinux
wget -N http://www.emutexlabs.com/files/ubilinux/ubilinux-edison-150309.tar.gz
tar xvf ubilinux-edison-150309.tar.gz
mv toFlash ubilinux-150309-usb-mod
cd ubilinux-150309-usb-mod

#Replace existing Ubi kernel with new kernel
cp edison-src/out/current/build/toFlash/edison-image-edison.hddimg .

#Replace kernel modules
mkdir /mnt/ubi
mount edison-image-edison.ext4 /mnt/ubi
rm -rf /mnt/ubi/lib/modules/3.10.17-yocto-standard-r2
cp -r edison-src/out/current/build/tmp/work/edison-poky-linux/edison-image/1.0-r0/rootfs/lib/modules/* /mnt/ubi/lib/modules/
umount /mnt/ubi
cd ..

echo "You can now run \"sudo ./flashall.sh\" in ubilinux-150309-usb-mod directory to flash your Intel Edison."
