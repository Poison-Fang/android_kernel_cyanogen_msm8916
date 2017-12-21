#!/bin/bash
rm .version
BUILD_START=$(date +"%s")

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="lineageos_tomato_defconfig"
KERNEL="Image"

# Paths
KERNEL_DIR=$PWD
DTBTOOL="$KERNEL_DIR/tools/dtbToolCM"
KERN_IMG="$KERNEL_DIR/arch/arm64/boot/Image"
OUT_DIR="$KERNEL_DIR/out"
MODULES_DIR="$OUT_DIR/system/lib/modules"
STRIP="/home/ayushwalia999/tc/bin/aarch64-linux-android-strip"

# Cleanup Stuff
rm $OUT_DIR/system/lib/modules/wlan.ko
rm $OUT_DIR/tools/Image
rm $OUT_DIR/tools/dt.img
rm $OUT_DIR/Remix_Kernel.zip
rm $KERNEL_DIR/arch/arm64/boot/dt.img

# Variables
export ARCH=arm64
export SUBARCH=arm64
export USE_CCACHE=1
export KBUILD_BUILD_USER="Poison-Fang"
export KBUILD_BUILD_HOST="killSwitch"
export CROSS_COMPILE="/home/ayushwalia999/tc/bin/aarch64-linux-android-"

# Specify colors utilized in the terminal
normal='tput sgr0'              # White
red='tput setaf 1'              # Red
green='tput setaf 2'            # Green
yellow='tput setaf 3'           # Yellow
blue='tput setaf 4'             # Blue
violet='tput setaf 5'           # Violet
cyan='tput setaf 6'             # Cyan
white='tput setaf 7'            # White
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) # Bold Red
bldgrn=${txtbld}$(tput setaf 2) # Bold Green
bldblu=${txtbld}$(tput setaf 4) # Bold Blue
bldylw=${txtbld}$(tput setaf 3) # Bold Yellow
bldvlt=${txtbld}$(tput setaf 5) # Bold Violet
bldcya=${txtbld}$(tput setaf 6) # Bold Cyan
bldwht=${txtbld}$(tput setaf 7) # Bold White

clear

echo -e "${bldred}  _____                _      "
echo -e "${bldgrn} |  __ \              (_)     "
echo -e "${bldblu} | |__) |___ _ __ ___  ___  __"
echo -e "${bldylw} |  _  // _ \ '_ \ _ \| \ \/ /"
echo -e "${bldcya} | | \ \  __/ | | | | | |>  < "
echo -e "${bldvlt} |_|  \_\___|_| |_| |_|_/_/\_\ "
echo -e "${bldred}       Building Kernel !!! "

tput bold && tput setaf 2

# Building Kernel
make $DEFCONFIG
make Image $THREAD
if ! [ -f $KERN_IMG ];
then
echo -e "${bldred} Bc!! Great, you can't build a kernel, now either fix the errors or HKSJ!! $nocol"
tput sgr0
exit 1
fi  
make dtbs $THREAD   
make modules $THREAD
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/

# Making Zip
cp $KERN_IMG $OUT_DIR/tools/Image 
find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
rm dummy
$STRIP --strip-unneeded *.ko
cd $KERNEL_DIR
cp $KERNEL_DIR/arch/arm64/boot/dt.img $OUT_DIR/tools/dt.img
cd $OUT_DIR
zip -r Remix_Kernel.zip *

# Uploading to GDrive
gdrive upload Remix_Kernel.zip
cd $MODULES_DIR
touch dummy
cd $KERNEL_DIR

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "${bldred}  _____                _      "
echo -e "${bldgrn} |  __ \              (_)     "
echo -e "${bldblu} | |__) |___ _ __ ___  ___  __"
echo -e "${bldylw} |  _  // _ \ '_ \ _ \| \ \/ /"
echo -e "${bldcya} | | \ \  __/ | | | | | |>  < "
echo -e "${bldvlt} |_|  \_\___|_| |_| |_|_/_/\_\ "
tput setaf 3
echo -e "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
tput sgr0
echo
echo "Clean up stuff ?"
read input
if [ "$input" == "y" ]
then
rm $OUT_DIR/system/lib/modules/wlan.ko
rm $OUT_DIR/tools/Image
rm $OUT_DIR/tools/dt.img
rm $OUT_DIR/Remix_Kernel.zip
rm $KERNEL_DIR/arch/arm64/boot/dt.img
git add .
make mrproper
echo
echo "Done!!!"
fi
if [ "$input" == "n" ]
then
echo "K, Kewl"
fi
