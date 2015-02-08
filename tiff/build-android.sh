#!/bin/bash
. `pwd`/../android-toolchain.sh

if [ ! -z ${1} ]
then
	export CYGWIN="winsymlinks:native"
	echo "WINLINK"
fi

if [ -z ${CPU_COUNT} ]
then
	export CPU_COUNT=4
	echo "CPU COUNT=4"
fi

# 1. Get sources
TIFF_NAME=tiff-4.0.3
TIFF_PAGE=http://download.osgeo.org/libtiff/
TIFF_SRC=`pwd`/$TIFF_NAME
HEADERS_DIR=`pwd`/include/android
PREBUILT_DIR=`pwd`/prebuilt/android 


if [ ! -d $TIFF_SRC ]
then
	export TIFF_INSTALL=1	
	echo "TIFF INSTALL"
fi

download_and_unpack $TIFF_NAME $TIFF_PAGE

if [ ! -z ${TIFF_INSTALL} ]
then
	pushd $TIFF_SRC
	rm -rf ./config
	sh ./autogen.sh
	popd
fi

cp -f ./Android.mk $TIFF_SRC
 
# $1: platform
# $2: host
# $3: abi
# $4: flags
function build_tiff() {	
	INSTALL_DIR=$PREBUILT_DIR/$2

	if [ ! -d "$INSTALL_DIR" ] || [ ! -f "$INSTALL_DIR/libtiff.a" ]
	then
		if [ ! -d "$INSTALL_DIR" ]
		then
			mkdir -p "$INSTALL_DIR" || exit 1
		fi

		make_android_toolchain $1 $3

		pushd $TIFF_SRC

		./configure --host="$ANDROID_TOOLCHAIN" --target="$ANDROID_TOOLCHAIN" || exit 1
		ndk-build -j $CPU_COUNT NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk APP_PLATFORM=$1 APP_ABI=$2 clean
		ndk-build -j $CPU_COUNT NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk APP_PLATFORM=$1 APP_ABI=$2 NDK_TOOLCHAIN_VERSION=4.9 APP_OPTIM=release APP_CFLAGS="-DANDROID -DNDEBUG" NDK_LIBS_OUT="$INSTALL_DIR" all || exit 1
	
		popd

		cp -vf "$TIFF_SRC/obj/local/$2/libtiff.a" "$INSTALL_DIR"
	fi
}

build_tiff android-9 armeabi arm-linux-androideabi
build_tiff android-9 armeabi-v7a arm-linux-androideabi
build_tiff android-9 mips mipsel-linux-android
build_tiff android-9 x86 x86
build_tiff android-21 arm64-v8a aarch64-linux-android
build_tiff android-21 mips64 mips64el-linux-android
build_tiff android-21 x86_64 x86_64-linux-android
