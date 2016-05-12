# edison_mod_kernel_image_gen
This project contains convenience shell scripts that modifies and recompiles the Intel Edison kernel with USB-Serial and USB-Ethernet driver support without much intervention. The output includes both the Yocto and Ubilinux image. 

One of the recipes containing the Paho package has been patched with the correct path before compilation. Details can be found in this [Intel forum thread](https://communities.intel.com/thread/101849).

For more information on what shell scripts do, I have provided inline-comments in those scripts.

##Version tested
These instructions have only been tested on the following releases:

1. edison-src-ww25.5-15 sources used in Release 2.1. Intel has not released sources for Release 3.0.
2. ubilinux-edison-150309

##Machine Required

1. A Ubuntu 14.04 OS or later. I used Linux Mint 17.2 (64-bit) with no problems.
2. Lots of disk space. Set aside at least 40GB to avoid compilation errors.
3. Using an SSD is preferred

##Installing dependencies
```bash
sudo apt-get install build-essential wget diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev dfu-util libqt4-core:i386 libqt4-gui:i386
```

##Generate Yocto image with modified kernel

This process may take 4-5 hours depending on your machine speed. My Mac using Intel i7-4850HQ 2.3Ghz quad-core CPU takes about 1.5 hours.

```bash
git clone https://github.com/algoaccess/edison_mod_kernel_image_gen.git
cd edison_mod_kernel_image_gen
./mod-kern.sh
```

##Splice modded Yocto kernel into Ubilinux

This shell script is dependent on the files generated earlier so remember to generate the Yocto image first!

```bash
./splice-ubi.sh
```

##References
1. [Edison Ethernet setup instructions](https://github.com/LGSInnovations/Edison-Ethernet)
2. [Patch Paho source path](https://communities.intel.com/thread/101849)
