#!/bin/bash

# Source Vars
source $CONFIG

#Setup Build Environment
cd ~
mkdir work
cd work 

#Clone Kernel Source
echo "Cloning Kernel Source"
	git clone --depth=1 $KERNEL_SOURCE Kernel || { echo "ERROR: Failed to Clone Kernel Source!" && exit 1; }
echo "Done!"	

#Clone Clang

if [ "$BUILD_USE_NEUTRON_CLANG" = "true" ]; then
echo "Cloning Neutron Clang and its dependencies"
        cd Kernel
	git clone --depth=1 https://gitlab.com/dakkshesh07/neutron-clang toolchains/clang || { echo "ERROR: Failed to Clone Kernel Clang !" && exit 1; }
        git clone --depth=1 https://github.com/mvaisakh/gcc-arm -b gcc-master toolchains/gcc-arm || { echo "ERROR: Failed to Clone Clang Dependency!" && exit 1; }
        git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 -b gcc-master toolchains/gcc-arm64 || { echo "ERROR: Failed to Clone Kernel Dependency!" && exit 1; }
        cd ~/work
echo "Done!"	
fi

if [ "$BUILD_USE_TRB_CLANG" = "true" ]; then
echo "Cloning TRB Clang ..."
        cd Kernel
        git clone --depth=1 https://gitlab.com/varunhardgamer/trb_clang.git -b 15 toolchains/clang || { echo "ERROR: Failed to Clone Kernel Clang !" && exit 1; }
        cd ~/work
echo "Done!"		
fi

#Clone Standard AnyKernel13
if [ "$BUILD_CLONE_STANDARD_ANYKERNEL" = "true" ]; then
echo "Cloning Custom AnyKernel13"
        cd ~/work
        git clone https://github.com/osm0sis/AnyKernel3.git -b master $ZIPPER_PATH
echo "Done!"	
fi

#Clone Custom AnyKernel13
if [ "$BUILD_CLONE_CUSTOM_ANYKERNEL" = "true" ]; then
echo "Cloning Custom AnyKernel13"
        cd ~/work
        git clone $ZIPPER_LINK $ZIPPER_PATH
echo "Done!"	
fi

#Setup Build Script (Do Not Change)
if [ "$BUILD_CLONE_CUSTOM_SCRIPT" = "true" ]; then
echo "Cloning build script into Kernel Dir..."
        cd ~/work
		git clone $SCRIPT_LINK builder-script
        cd builder-script
		mv $SCRIPT_NAME ~/work/Kernel
echo "Done!"	
fi

exit 0
