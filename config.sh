#!/bin/bash

# Kernel Source
export KERNEL_SOURCE="https://github.com/Atom-X-Devs/android_kernel_xiaomi_sm7325.git -b codelinaro"

# Neutron clang
#clang will be always cloned in toolchains/clang inside the kernel directory. Make sure to use proper paths in your build script
#Can't clone all clangs at once.
export BUILD_USE_NEUTRON_CLANG=true
export BUILD_USE_TRB_CLANG=false

# Anykernel
# Standard : clone anykernel13 from official osm0sis repo
# Custom : clone anykernel13 from your own custom repo
# ZIPPER_LINK : link of custom repo (NOT REQUIRED UNLESS USING CUSTOM ANYKERNEL)
# ZIPPER_PATH : path where the standard or custom anykernel will be cloned. base directory : ~/work
# so if you put ZIPPER_PATH=AnyKernel13 ; then anykernel will be cloned in ~/work/AnyKernel13. 
# if need to clone in kernel directory, then ZIPPER_PATH="Kernel/AnyKernel13"
export BUILD_CLONE_STANDARD_ANYKERNEL=false
export BUILD_CLONE_CUSTOM_ANYKERNEL=true
export ZIPPER_LINK="https://github.com/Atom-X-Devs/AnyKernel3 -b main"
export ZIPPER_PATH="Kernel/AnyKernel13"  #mandatory

#Build Script (NOT NEEDED IF YOUR KERNEL SOURCE ALREADY HAS A BUILD SCRIPT INCLUDED)
# You can use a custom build script to start the kernel build. Make sure the script does not have any interactions when the script executes, since 
# you won't be able to interact/interfere with the build process.
# If the build script in your kernel source is build.sh, then SCRIPT_NAME="build.sh"
export BUILD_CLONE_CUSTOM_SCRIPT=true
export SCRIPT_LINK="https://github.com/Pranav-Talmale/Kernel-Builder -b lisa"
export SCRIPT_NAME="AtomX.sh" # mandatory # SCRIPT_NAME IS MANDATORY TO SET SINCE IT IS REFRRED IN THE BUILD PROCESS AS WELL TO EXECUTE THE SCRIPT. 

# Build 
# Extra build commands that can to be passed if build script needs it.
# Check build.sh of this repo for more info on how this works
export CUSTOM_ARG1="compiler"
export CUSTOM_ANS1="clang"
export CUSTOM_ARG2="device"
export CUSTOM_ANS2="lisa"
#LEAVE EMPTY IF YOU DON'T KNOW WHAT THIS DOES

# Upload
# zip the entire out dir if you need it. 
export BUILD_ZIP_OUT_DIR=false
export OUTPUT="*-signed.zip"

