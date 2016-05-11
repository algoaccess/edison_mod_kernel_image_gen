#!/bin/sh

#Installing dependencies
#apt-get install build-essential wget diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev dfu-util libqt4-core:i386 libqt4-gui:i386

#Download sources
wget http://downloadmirror.intel.com/25028/eng/edison-src-ww25.5-15.tgz
tar xvzf edison-src-ww25.5-15.tgz
cd edison-src

#Setup Build tree
make setup

#Patch Paho path bug
sed -i 's/^SRC_URI.*/SRC_URI = "git:\/\/github.com\/eclipse\/paho.mqtt.c.git:protocol=http \\/' out/linux64/poky/meta-intel-iot-middleware/recipes-connectivity/paho-mqtt/paho-mqtt_3.1.bb

#Compile kernel
make image

#Replace lines of "# CONFIG_USB_SERIAL_FTDI_SIO is not set" >>> "# CONFIG_USB_SERIAL_FTDI_SIO=y"
sed -i '/^# CONFIG_USB_NET/ { s, is not set,=y, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Remove # in from of CONFIG_USB_NET
sed -i '/^# CONFIG_USB_NET/ { s,# CONFIG_USB_NET,CONFIG_USB_NET, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Replace lines of "# CONFIG_USB_SERIAL_FTDI_SIO is not set" >>> "# CONFIG_USB_SERIAL_FTDI_SIO=y"
sed -i '/^# CONFIG_USB_SERIAL/ { s, is not set,=y, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Remove # in from of CONFIG_USB_SERIAL_FTDI_SIO
sed -i '/^# CONFIG_USB_SERIAL/ { s,# CONFIG_USB_SERIAL,CONFIG_USB_SERIAL, }' meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig

#Start compiling kernel
make

#Run postBuild Script
meta-intel-edison/utils/flash/postBuild.sh out/linux64/build