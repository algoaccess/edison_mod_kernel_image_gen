#!/bin/sh

cd edison-src
./meta-intel-edison/utils/create-debian-image.sh

cd ..
rm -rf edison-image-ww25.5-15-usb-deb-mod
mkdir edison-image-ww25.5-15-usb-deb-mod
cp -a edison-src/out/linux64/build/toFlash/. edison-image-ww25.5-15-usb-deb-mod/

echo "You can now run \"sudo ./flashall.sh\" in edison-image-ww25.5-15-usb-mod directory to flash your Intel Edison."