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

##Splice modded Yocto kernel into Ubilinux

This shell script is dependent on the files generated earlier so remember to generate the Yocto image first! This has to be run as root as we have to mount the Ubi disk image to replace certain files. If you specify a new rootfs size in the earlier step, it does not carry over to Ubilinux for some reason.

```bash
sudo ./splice-ubi.sh
```

##Create Debian image from source

Although Ubilinux is based on Debian, there may be use cases where you may not want to use it and might want to compile your own Debian-based version. So here are the instructions to do so.

```bash
sudo rm -rf edison-src

This will take many hours
./mod-kern-debian.sh

About half hour
sudo ./gen-debian-image.sh
```

##Increase number of compilation threads for better CPUs or Amazon EC2

If your CPU has more cores, you can let the compile script use those cores to speed up compilation. If your CPU has for example 8 cores, you can execute the following command before running any of the shell scripts or `make` commands.

```bash
export SETUP_ARGS="--parallel_make=8 --bb_number_thread=8"
```

You can also leverage on Amazon EC2 to speed up compilation even further. Since this is a CPU-heavy compute task, I opted for the Compute Optimized Instance Type C4 instead of the General Purpose M4. If you are willing to pay more, Type C4 can technically go up to 36 cores. However I noticed that in many portions during compilation, they generally do not use close to 36 cores.

So I settled with c4.4xlarge with 16 cores to balance between compilation time and cost.

```bash
export SETUP_ARGS="--parallel_make=16 --bb_number_thread=16"

#Run the compilation script here. I will use the Debian script as an example here.
./mod-kern-debian.sh
sudo ./gen-debian-image.sh

#Compress the compiled image
tar -zcvf edison-image-ww25.5-15-usb-deb-mod.tar.gz edison-image-ww25.5-15-usb-deb-mod

#Run this on your computer
scp -i yourkey.pem ubuntu@server-ip:/home/ubuntu/edison_mod_kernel_image_gen/edison-image-ww25.5-15-usb-deb-mod.tar.gz /home/user/yourlocation
```

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

##References
1. [Edison Ethernet setup instructions](https://github.com/LGSInnovations/Edison-Ethernet)
2. [Patch Paho source path](https://communities.intel.com/thread/101849)
3. [Create Debian image](http://www.hackgnar.com/2016/02/building-debian-linux-for-intel-edison.html)
4. [Use Amazon EC2 for compilation](https://github.com/hackgnar/kali_intel_edison/blob/master/ManualBuild.md)
