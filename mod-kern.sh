#!/bin/sh

#Download sources
wget -N http://downloadmirror.intel.com/25028/eng/edison-src-ww25.5-15.tgz
rm -rf edison-src
tar xvzf edison-src-ww25.5-15.tgz
cd edison-src

#Setup Build tree
make setup

#Patch Paho path bug
sed -i 's/^SRC_URI.*/SRC_URI = "git:\/\/github.com\/eclipse\/paho.mqtt.c.git \\/' out/linux64/poky/meta-intel-iot-middleware/recipes-connectivity/paho-mqtt/paho-mqtt_3.1.bb

#Increase rootfs only from 1536MB to desired value if provided in the first command line argument
if [ "$1" != "" ]; then
    echo "We will resize rootfs from the default 1536MiB to $1MiB"
    sed -i '/^partitions=/ { s,1536,'$1', }' meta-intel-edison/meta-intel-edison-bsp/recipes-bsp/u-boot/files/edison.env
fi

#Compile kernel
make image

#Replace lines of "# CONFIG_USB_NET_... is not set" >>> "# CONFIG_USB_NET_...=y"
sed -i '/^# CONFIG_USB_NET/ { s, is not set,=y, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Remove # in front of CONFIG_USB_NET...
sed -i '/^# CONFIG_USB_NET/ { s,# CONFIG_USB_NET,CONFIG_USB_NET, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Replace lines of "# CONFIG_USB_SERIAL_... is not set" >>> "# CONFIG_USB_SERIAL_...=y"
sed -i '/^# CONFIG_USB_SERIAL/ { s, is not set,=y, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Remove # in front of CONFIG_USB_SERIAL_...
sed -i '/^# CONFIG_USB_SERIAL/ { s,# CONFIG_USB_SERIAL,CONFIG_USB_SERIAL, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Compile once more
make

#Run postBuild Script
meta-intel-edison/utils/flash/postBuild.sh out/linux64/build

cd ..
rm -rf edison-image-ww25.5-15-usb-mod
mkdir edison-image-ww25.5-15-usb-mod
cp -a edison-src/out/linux64/build/toFlash/. edison-image-ww25.5-15-usb-mod/

echo "You can now run \"sudo ./flashall.sh\" in edison-image-ww25.5-15-usb-mod directory to flash your Intel Edison."
