#!/bin/bash

#########################    CONFIGURATION    ##############################

# User details
KBUILD_USER="Pranav-Talmale"
KBUILD_HOST="AsusZephyrusG14"

# Build type (Fresh build: clean | incremental build: dirty)
# (default: dirty | modes: clean, dirty)
BUILD='clean'

############################################################################

########################   DIRECTORY PATHS   ###############################

# Kernel Directory
KERNEL_DIR=`pwd`

# Propriatary Directory (default paths may not work!)
PRO_PATH="$KERNEL_DIR/"

# Toolchain Directory
TLDR="$PRO_PATH/toolchains"

# Anykernel Directories
AK3_DIR="$PRO_PATH/AnyKernel3"
AKSH="$AK3_DIR/anykernel.sh"
AKVDR="$AK3_DIR/modules/vendor/lib/modules"

# Device Tree Blob Directory
DTB_PATH="$KERNEL_DIR/work/arch/arm64/boot/dts/vendor/qcom"

############################################################################

###############################   COLORS   #################################

R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
W='\033[1;37m'

############################################################################

################################   MISC   ##################################

# functions
error() {
	echo -e ""
	echo -e "$R ${FUNCNAME[0]}: $W$@"
	echo -e ""
	exit 1
}

success() {
	echo -e ""
	echo -e "$G ${FUNCNAME[1]}: $W$@"
	echo -e ""
	exit 0
}

inform() {
	echo -e ""
	echo -e "$B ${FUNCNAME[1]}: $W$@$G"
	echo -e ""
}

muke() {
	make $@ ${MAKE_ARGS[@]} $FLAG
}

usage() {
	inform " ./AtomX.sh <arg>
		--compiler   sets the compiler to be used
		--device     sets the device for kernel build
		--dtbs       Builds dtbs, dtbo & dtbo.img
		--regen      Regenerates defconfig (makes savedefconfig)
		--silence    Silence shell output of Kbuild"
	exit 2
}

############################################################################

compiler_setup() {
############################  COMPILER SETUP  ##############################
	MAKE_ARGS=()
	# default to clang
	CC='clang'
	C_PATH="$TLDR/clang"
	LLVM_PATH="$C_PATH/bin"
	if [[ $COMPILER == gcc ]]; then
		# Just override the existing declarations
		CC='aarch64-linux-gnu-gcc'
		C_PATH="$TLDR/gcc-arm64"
	fi
	MAKE_ARGS+=("O=work"
				"ARCH=arm64"
				"LLVM=$LLVM_PATH"
				"HOSTLD=ld.lld" "CC=$CC"
				"PATH=$C_PATH/bin:$PATH"
				"OPT_FLAGS=-march=armv8.4-a"
				"KBUILD_BUILD_USER=$KBUILD_USER"
				"KBUILD_BUILD_HOST=$KBUILD_HOST"
				"CROSS_COMPILE=aarch64-linux-gnu-"
				"CC_COMPAT=$TLDR/gcc-arm/bin/arm-eabi-gcc"
				"LD_LIBRARY_PATH=$C_PATH/lib:$LD_LIBRARY_PATH"
				"CROSS_COMPILE_COMPAT=$TLDR/gcc-arm/bin/arm-eabi-")
############################################################################
}

config_generator() {
#########################  .config GENERATOR  ############################
	if [[ -z $CODENAME ]]; then
		error 'Codename not present connot proceed'
		exit 1
	fi

	DFCF="vendor/${CODENAME}-${SUFFIX}_defconfig"
	if [[ ! -f arch/arm64/configs/$DFCF ]]; then
		inform "Genertating defconfig"

		export ${MAKE_ARGS[@]} TARGET_BUILD_VARIANT=user

		bash scripts/gki/generate_defconfig.sh "${CODENAME}-${SUFFIX}_defconfig"
		muke vendor/${CODENAME}-${SUFFIX}_defconfig vendor/lahaina_QGKI.config 
	else
		inform "Genertating .config"

		# Make .config
		muke $DFCF
	fi
	if [[ "$TEST" == "1" ]]; then
		./scripts/config --file work/.config -d CONFIG_LTO_CLANG
		./scripts/config --file work/.config -d CONFIG_HEADERS_INSTALL
	fi
############################################################################
}

config_regenerator() {
########################  DEFCONFIG REGENERATOR  ###########################
	config_generator

	inform "Regenertating defconfig"

	muke savedefconfig

	cat work/defconfig > arch/arm64/configs/$DFCF

	success "Regenertation completed"
############################################################################
}

kernel_builder() {
##################################  BUILD  #################################
	case $BUILD in
		clean)
			rm -rf work || mkdir work
		;;
		*)
			muke clean mrproper distclean
		;;
	esac

	config_generator

	if [[ "$OBJ" != "" ]]; then
		inform "Building $OBJ"

		muke -j$(nproc) $OBJ

		exit 0
	fi

	# Build Start
	BUILD_START=$(date +"%s")

	source work/.config
	C_NAME=$(echo $CONFIG_CC_VERSION_TEXT | head -n 1 | perl -pe 's/\(http.*?\)//gs')
	C_NAME_32=$($(echo ${MAKE_ARGS[@]} | sed s/' '/'\n'/g | grep CC_COMPAT | cut -c 11-) --version | head -n 1)

	inform "
	*************Build Triggered*************
	Date: $(date +"%Y-%m-%d %H:%M")
	Build Type: $BUILD_TYPE
	Device: $DEVICENAME
	Codename: $CODENAME
	Compiler: $C_NAME
	Compiler_32: $C_NAME_32
	"

	# Compile
	muke -j$(nproc)

	if [[ $CONFIG_MODULES == "y" ]]; then
		muke -j$(nproc)          \
			'modules_install'    \
			INSTALL_MOD_STRIP=1  \
			INSTALL_MOD_PATH="modules"
	fi

	# Build End
	BUILD_END=$(date +"%s")

	DIFF=$(($BUILD_END - $BUILD_START))

	if [[ -f $KERNEL_DIR/work/arch/arm64/boot/$TARGET ]]; then
		zipper
	else
		error 'Kernel image not found' || { echo "ERROR: Failed to Build Kernel!" && exit 1; }
	fi
############################################################################
}

zipper() {
####################################  ZIP  #################################
	if [[ ! -d $AK3_DIR ]]; then
		error 'Anykernel not present cannot zip' || { echo "ERROR: Failed to zip Kernel!" && exit 1; }
	fi
	if [[ ! -d "$KERNEL_DIR/out" ]]; then
		mkdir $KERNEL_DIR/out
	fi

	cp $KERNEL_DIR/work/arch/arm64/boot/$TARGET $AK3_DIR
	cp $DTB_PATH/*.dtb $AK3_DIR/dtb
	cp $DTB_PATH/*.img $AK3_DIR/
	if [[ $CONFIG_MODULES == "y" ]]; then
		MOD_NAME="$(cat work/include/generated/utsrelease.h | cut -c 21- | tr -d '"')"
		MOD_PATH="work/modules/lib/modules/$MOD_NAME"

		cp $(find $MOD_PATH -name '*.ko') $AKVDR
		cp $MOD_PATH/modules.{alias,dep,softdep} $AKVDR
		cp $MOD_PATH/modules.order $AKVDR/modules.load
		sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' $AKVDR/modules.dep
		sed -i 's/.*\///g' $AKVDR/modules.load
	fi

	KERNEL_VERSION=$(make kernelversion)
	LAST_COMMIT=$(git show -s --format=%s)
	LAST_HASH=$(git rev-parse --short HEAD)

	cd $AK3_DIR

	make zip VERSION=`echo $CONFIG_LOCALVERSION | cut -c 8-`

	inform "
	*************Kernel-Builder*************
	Linux Version: $KERNEL_VERSION
	CI: $KBUILD_HOST
	Core count: $(nproc)
	Compiler: $C_NAME
	Compiler_32: $C_NAME_32
	Device: $DEVICENAME
	Codename: $CODENAME
	Build Date: $(date +"%Y-%m-%d %H:%M")
	Build Type: $BUILD_TYPE
	*****************************************
	"

	cp *-signed.zip ~/work


	cd $KERNEL_DIR

	success "build completed in $(($DIFF / 60)).$(($DIFF % 60)) mins"

############################################################################
}

###############################  COMMAND_MODE  ##############################
if [[ -z $* ]]; then
	usage
fi

for arg in "$@"; do
	case "${arg}" in
		"--compiler="*)
			COMPILER=${arg#*=}
			COMPILER=${COMPILER,,}
			case $COMPILER in
				clang | gcc)
					compiler_setup
				;;
				*)
					usage
				;;
			esac
		;;
		"--obj="*)
			OBJ=${arg#*=}
		;;
		"--device="*)
			CODE_NAME=${arg#*=}
			case $CODE_NAME in
				lisa)
					DEVICENAME='Xiaomi 11 lite 5G NE'
					CODENAME='lisa'
					SUFFIX='qgki'
					TARGET='Image'
				;;
				*)
					error 'device not supported'
				;;
			esac
		;;
		"--test")
			TEST='1'
			CODENAME=lahaina
		;;
		"--silence")
			MAKE_ARGS+=("-s")
		;;
		"--log")
			FLAG='2>&1 | tee ../log.txt'
		;;
		"--dtbs")
			OBJ=dtbs
		;;
		"--regen")
			config_regenerator
		;;
		*)
			usage
		;;
	esac
done
############################################################################

kernel_builder
