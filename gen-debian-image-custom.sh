#!/bin/sh

cp create-debian-image-custom.sh  edison-src/meta-intel-edison/utils/create-debian-image.sh

cd edison-src

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

./meta-intel-edison/utils/create-debian-image.sh

cd ..
rm -rf edison-image-ww25.5-15-usb-deb-mod
mkdir edison-image-ww25.5-15-usb-deb-mod
cp -a edison-src/out/linux64/build/toFlash/. edison-image-ww25.5-15-usb-deb-mod/

echo "You can now run \"sudo ./flashall.sh\" in edison-image-ww25.5-15-usb-deb-mod directory to flash your Intel Edison."