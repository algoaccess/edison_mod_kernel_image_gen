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

#Adjust bug in build path "build_dir=$top_repo_dir/build" >>> "build_dir=$top_repo_dir/out/linux64/build"
sed -i 's/^build_dir=$top_repo_dir\/build/build_dir=$top_repo_dir\/out\/linux64\/build/' meta-intel-edison/utils/create-debian-image.sh

#Change from jessie to a newer sid to use latest packages.
if [ $# -eq 0 ]
	then
		echo "No arguments, we are staying with jessie"
else
    if [ "$1" == "sid" ]; then
    	echo "We will use the unstable sid branch instead of the stable jessie"
    	sed -i '/^  debootstrap --arch i386 --no-check-gpg/ { s,jessie,sid, }' meta-intel-edison/utils/create-debian-image.sh
    else
    	echo "Unknown argument, staying with jessie"
    fi
fi

cd ..

echo "To continue, you now have to run \"sudo ./gen-debian-image.sh\" to generate the Debian image."
