# edison_mod_kernel_image_gen
This project contains convenience shell scripts that modifies and recompiles the Intel Edison kernel with USB-Serial and USB-Ethernet driver support without much intervention. You can optionally resize the rootfs partition for the Yocto kernel by specifying the new partition size as a command-line argument.

The output includes both the Yocto and optionally the Ubilinux image using the second shell script. You can compile a Debian distribution with a provided shell script too.

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
sudo apt-get upgrade
sudo apt-get install build-essential diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev dfu-util debootstrap u-boot-tools debian-archive-keyring dfu-util git python wget
```

##Generate Yocto image with modified kernel

Clone this directory to a partition on your disk with at least 40GB free disk space. This process may take 4-5 hours depending on your machine speed. My Mac using Intel i7-4850HQ 2.3Ghz quad-core CPU takes about 2 hours.

You can choose to resize the rootfs from the default 1536MiB. Just add the desired size as the command line argument. Make sure to not put a ridiculously small or large number. The `/home` partition will be reduced in size accordingly. The resizing option does not work for Ubilinux.

```bash
git clone https://github.com/algoaccess/edison_mod_kernel_image_gen.git
cd edison_mod_kernel_image_gen

#To just generate the Yocto image with untouched rootfs at 1536MiB, if not skip to next command example.
./mod-kern-yocto.sh

#To resize rootfs to desired size example 2048MiB
./mod-kern-yocto.sh 2048
```

##Generate Yocto image with meta-openembedded recipes

The example shell script will do everything as the above as well as as install Samba and Ruby with the help of external recipes from [meta-openembedded](https://github.com/openembedded/meta-openembedded).

```bash
./mod-kern-yocto-with-meta-oe.sh

#You can also specify the rootfs size
./mod-kern-yocto-with-meta-oe.sh 1900
```

The objective of this shell script is for you to customise the recipe section in it before generating the image.

##Splice modded Yocto kernel into Ubilinux

This shell script is dependent on the files generated earlier so remember to generate the Yocto image first! This has to be run as root as we have to mount the Ubi disk image to replace certain files. If you specify a new rootfs size in the earlier step, it does not carry over to Ubilinux for some reason.

```bash
sudo ./splice-ubi.sh
```

##Create Debian image from source

Although Ubilinux is based on Debian, there may be use cases where you may not want to use it and might want to compile your own Debian-based version. So here are the instructions to do so. I have set the rootfs to use a fixed 1536MB to give more space for installing packages.

```bash
sudo rm -rf edison-src

#Compiling the kernel with default jessie, this will take a few hours. If you want sid, skip to next command.
./mod-kern-debian.sh

#Compiling the kernel with sid branch. sid is "supposedly" unstable but the packages are more up-to-date.
./mod-kern-debian.sh sid

#Generating the image and downloading the necessary packages takes about half hour
sudo ./gen-debian-image.sh
```

##Issues

###Debian jessie libc version

It seems the version of libc on jessie is out-of-date. When you do a `sudo apt-get upgrade`, you will get the following message.

```
You might want to run 'apt-get -f install' to correct these.
The following packages have unmet dependencies:
 bcm43340-bt : Depends: libc6 (>= 2.20) but 2.19-18+deb8u4 is installed
 u-boot-fw-utils : Depends: libc6 (>= 2.20) but 2.19-18+deb8u4 is installed
E: Unmet dependencies. Try using -f.
```

You can choose to run `apt-get -f install` and remove the packages but I'm unsure of the repercussions. sid does not have this problem.

###Debian `/etc/fstab` issue

For some strange reason on both jessie and sid, the `/home` directory is not mounted on `/dev/mmcblk0p10` as stated in `/etc/fstab`. During first-boot, `/home` is mounted properly. On subsquent reboots, the mount point is lost. 

To correct this, add the following to the bottom of the `/etc/fstab` file then reboot.

```
/dev/disk/by-partlabel/home     /home       auto    noauto,comment=systemd.automount,nosuid,nodev,noatime,discard     1   1
```

###Custom Debian Build network/bluetooth issues

Bluetooth specifically Low Energy does not seem to work. The command `hcitool` and `hciconfig` cannot seem to locate the `hci0` device. Ublinux does not have this issue.

For networks: I can't seem to get Wifi working. DHCP seems to work for USB-Ethernet but I'm unsure how to set static IP after trying out many solutions I found online.

##Increase number of compilation threads for better CPUs or Amazon EC2

If your CPU has more cores, you can let the compile script use those cores to speed up compilation. If your CPU has for example 8 cores, you can execute the following command before running any of the shell scripts or `make` commands.

```bash
export SETUP_ARGS="--parallel_make=8 --bb_number_thread=8"
```

You can also leverage on Amazon EC2 or Google Compute Engine (GCE) to speed up compilation even further. Since this is a CPU-heavy compute task, you should optimise for the number of CPUs instead of RAM and storage. If you choose EC2, the Compute Optimized Instance Type C4 c4.8 (36 cores) is the best choice. I eventually settled with GCE with 32 CPUs with the lowest 28.8 GB RAM as it is offers more value.

I chose the SSD size of the instance to be 80GB. Make sure you choose Ubuntu 14.04 64-bit as the OS.

```bash
export SETUP_ARGS="--parallel_make=32 --bb_number_thread=32"

#Run the compilation script here. I will use the Yocto script as an example here.
./mod-kern-yocto.sh

#Compress the compiled image
tar -zcvf edison-image-ww25.5-15-usb-mod.tar.gz edison-image-ww25.5-15-usb-mod

#Run this on your computer
scp -i yourkey.pem ubuntu@server-ip:/home/ubuntu/edison_mod_kernel_image_gen/edison-image-ww25.5-15-usb-mod.tar.gz /home/user/yourlocation
#To uncompress the image on your machine to prepare for flashing.
tar -xzvf edison-image-ww25.5-15-usb-mod.tar.gz
```

Remember to stop or poweroff your instance once you have finished to avoid racking up huge bills since this is quite a powerful instance. Once you confirm you no longer need the instance, it is better to terminate it once and for all to reduce storage charges.

##Cleanup
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

zip -r edison-image-ww25.5-15-usb-deb-mod.zip edison-image-ww25.5-15-usb-deb-mod
rm -rf edison-image-ww25.5-15-usb-deb-mod
```
##Network setup within Intel Edison

You have to modify the `/etc/network/interfaces` with the necessary options to setup your new ethernet interface. For more information, you can consult Step 3 of the [guide](https://github.com/LGSInnovations/Edison-Ethernet/tree/master/guides) here.

For Yocto, you may have to additionally run `systemctl enable connman && systemctl start connman`.

##References
1. [Edison Ethernet setup instructions](https://github.com/LGSInnovations/Edison-Ethernet)
2. [Patch Paho source path](https://communities.intel.com/thread/101849)
3. [Create Debian image](http://www.hackgnar.com/2016/02/building-debian-linux-for-intel-edison.html)
4. [Use Amazon EC2 for compilation](https://github.com/hackgnar/kali_intel_edison/blob/master/ManualBuild.md)
5. [Building custom images](https://software.intel.com/en-us/node/593592)
