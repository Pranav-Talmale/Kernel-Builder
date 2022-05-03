#!/bin/bash
#

#Setup Build Environment
cd ~
mkdir work
cd work 

#Clone Kernel Source
echo "Cloning Kernel Source"
	git clone https://github.com/Pranav-Talmale/android_kernel_xiaomi_lisa.git Kernel
echo "Done!"	

#Clone Clang
echo "Cloning Clang and other stuff"
        cd Kernel
	git clone https://gitlab.com/dakkshesh07/neutron-clang toolchains/clang
        git clone https://github.com/mvaisakh/gcc-arm -b gcc-master toolchains/gcc-arm
        git clone https://github.com/mvaisakh/gcc-arm64 -b gcc-master toolchains/gcc-arm64
        cd ~/work
echo "Done!"	

#Clone Zipper
echo "Cloning AnyKernel13"
        cd Kernel
        git clone https://github.com/Atom-X-Devs/AnyKernel3 -b main AnyKernel3
echo "Done!"	

#Setup Build Script
echo "Cloning build script into Kernel Dir..."
        cd ~/work
		git clone https://github.com/Pranav-Talmale/Kernel-Builder.git builder-script
        cd builder-script
		mv AtomX.sh ~/work/Kernel
echo "Done!"	

exit 0
