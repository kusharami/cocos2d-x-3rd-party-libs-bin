#!/bin/bash
. `pwd`/../android-toolchain.sh

if [ -z ${CPU_COUNT} ]
then
	export CPU_COUNT=4
	echo "CPU COUNT=4"
fi

# 1. Get sources
REPO_LINK=git://git.libwebsockets.org/libwebsockets
REPO_SRC=`pwd`/libwebsockets
HEADERS_DIR=`pwd`/include/android
PREBUILT_DIR=`pwd`/prebuilt/android 
ANDROID_MK=`pwd`/Android.mk

git clone $REPO_LINK $REPO_SRC --recursive
pushd $REPO_SRC
	git clean -f
	git pull
popd

cp -vf `pwd`/config.h $REPO_SRC/lib

# $1: platform
# $2: host
# $3: abi
# $4: flags
function build_tiff() {	
	INSTALL_DIR=$PREBUILT_DIR/$2

	if [ ! -d "$INSTALL_DIR" ] || [ ! -f "$INSTALL_DIR/libwebsockets.a" ]
	then
		if [ ! -d "$INSTALL_DIR" ]
		then
			mkdir -p "$INSTALL_DIR" || exit 1
		fi
		
		ndk-build -j $CPU_COUNT NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk APP_PLATFORM=$1 APP_ABI=$2 clean
		ndk-build -j $CPU_COUNT NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk APP_PLATFORM=$1 APP_ABI=$2 NDK_TOOLCHAIN_VERSION=4.9 APP_OPTIM=release APP_CFLAGS="-DANDROID -DNDEBUG" NDK_LIBS_OUT="$INSTALL_DIR" all || exit 1

		cp -vf `pwd`/obj/local/$2/libwebsockets.a "$INSTALL_DIR"
	fi
}

build_tiff android-9 armeabi
build_tiff android-9 armeabi-v7a
build_tiff android-9 mips
build_tiff android-9 x86
build_tiff android-21 arm64-v8a
build_tiff android-21 mips64
build_tiff android-21 x86_64

echo "Copy headers"

if [ ! -d $HEADERS_DIR ]
then
	mkdir -p "$HEADERS_DIR"
fi

cp -fv $REPO_SRC/lib/libwebsockets.h $HEADERS_DIR