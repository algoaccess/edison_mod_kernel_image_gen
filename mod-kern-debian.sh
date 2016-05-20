#!/bin/sh

#Download sources
wget -N http://downloadmirror.intel.com/25028/eng/edison-src-ww25.5-15.tgz
rm -rf edison-src
tar xvzf edison-src-ww25.5-15.tgz
cd edison-src

#Setup Build tree
make setup

sed -i -e 's/524288/1572864/' meta-intel-edison/meta-intel-edison-distro/recipes-core/images/edison-image.bb

#Compile kernel
make debian_image

#Patch Paho path bug. We do this after make debian_image as that command will reset our paho path patch.
sed -i 's/^SRC_URI.*/SRC_URI = "git:\/\/github.com\/eclipse\/paho.mqtt.c.git \\/' out/linux64/poky/meta-intel-iot-middleware/recipes-connectivity/paho-mqtt/paho-mqtt_3.1.bb

make

#Replace lines of "# CONFIG_USB_NET_... is not set" >>> "# CONFIG_USB_NET_...=y"
sed -i '/^# CONFIG_USB_NET/ { s, is not set,=y, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Remove # in front of CONFIG_USB_NET...
sed -i '/^# CONFIG_USB_NET/ { s,# CONFIG_USB_NET,CONFIG_USB_NET, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Replace lines of "# CONFIG_USB_SERIAL_... is not set" >>> "# CONFIG_USB_SERIAL_...=y"
sed -i '/^# CONFIG_USB_SERIAL/ { s, is not set,=y, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Remove # in front of CONFIG_USB_SERIAL_...
sed -i '/^# CONFIG_USB_SERIAL/ { s,# CONFIG_USB_SERIAL,CONFIG_USB_SERIAL, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Add # back in front of CONFIG_USB_SERIAL_DEBUG, we don't want DEBUG messages sent to/from the USB Serial adapter
sed -i '/^CONFIG_USB_SERIAL_DEBUG/ { s,CONFIG_USB_SERIAL_DEBUG,# CONFIG_USB_SERIAL_DEBUG, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

make

cd ..

echo "To continue, you now have to run \"sudo ./gen-debian-image.sh [sid]\" to generate the Debian image."
