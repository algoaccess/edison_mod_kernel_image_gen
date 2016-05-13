# edison_mod_kernel_image_gen
This project contains convenience shell scripts that modifies and recompiles the Intel Edison kernel with USB-Serial and USB-Ethernet driver support without much intervention. You can optionally resize the rootfs partition by specifying the new partition size as a command-line argument.

The output includes both the Yocto and optionally the Ubilinux image using the second shell script. 

One of the recipes containing the Paho package has been patched with the correct path before compilation. Details can be found in this [Intel forum thread](https://communities.intel.com/thread/101849).

For more information on what the shell scripts do, I have provided inline-comments in those scripts.

##Version tested
These instructions have only been tested on the following releases:

1. edison-src-ww25.5-15 sources used in Release 2.1. Intel has not released sources for Release 3.0.
2. ubilinux-edison-150309

##Build Machine Required

1. Ubuntu 14.04 OS or later. I used Linux Mint 17.2 (64-bit) with no problems.
2. Lots of disk space. Set aside at least 40GB to avoid compilation errors.
3. Using an SSD is preferred

##Installing dependencies
```bash
sudo apt-get update
sudo apt-get install build-essential wget diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev dfu-util libqt4-core:i386 libqt4-gui:i386
```

##Generate Yocto image with modified kernel

Clone this directory to a partition on your disk with at least 40GB free disk space. This process may take 4-5 hours depending on your machine speed. My Mac using Intel i7-4850HQ 2.3Ghz quad-core CPU takes about 2 hours.

You can choose to resize the rootfs from the default 1536MiB. Just add the desired size as the command line argument. Make sure to not put a ridiculously small or large number. The `/home` partition will be reduced in size accordingly. The resizing option does not work for Ubilinux.

```bash
git clone https://github.com/algoaccess/edison_mod_kernel_image_gen.git
cd edison_mod_kernel_image_gen

#To just generate the Yocto image with untouched rootfs at 1536MiB, if not skip to next command example.
./mod-kern.sh

#To resize rootfs to desired size example 2048MiB
./mod-kern.sh 2048
```

##Splice modded Yocto kernel into Ubilinux

This shell script is dependent on the files generated earlier so remember to generate the Yocto image first! This has to be run as root as we have to mount the Ubi disk image to replace certain files. If you specify a new rootfs size in the earlier step, it does not carry over to Ubilinux for some reason.

```bash
sudo ./splice-ubi.sh
```

##Finally
Once you are confident and tested everything, you can remove the edison-src directory and other downloaded files to increase free disk space.

```bash
rm -rf edison-src
rm edison-src-ww25.5-15.tgz
rm ubilinux-edison-150309.tar.gz
```

You can zip up the generated images then delete the orignals to save even more space.

```bash
zip -r edison-image-ww25.5-15-usb-mod.zip edison-image-ww25.5-15-usb-mod
rm -rf edison-image-ww25.5-15-usb-mod

zip -r ubilinux-150309-usb-mod.zip ubilinux-150309-usb-mod
rm -rf ubilinux-150309-usb-mod
```

##References
1. [Edison Ethernet setup instructions](https://github.com/LGSInnovations/Edison-Ethernet)
2. [Patch Paho source path](https://communities.intel.com/thread/101849)
