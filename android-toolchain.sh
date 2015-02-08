#!/bin/bash

if [ -n ANDROID_TOOLCHAIN_GCC_VERSION ]
then
	ANDROID_TOOLCHAIN_GCC_VERSION=4.9
fi

#$1 platform
#$2 toolchain
function make_android_toolchain() {
	TOOLCHAIN="$2-$ANDROID_TOOLCHAIN_GCC_VERSION"
	INSTALLDIR="/usr/local/toolchains/$1/$TOOLCHAIN"
	if [ ! -d "$INSTALLDIR" ]
	then
		$NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform="$1" --install-dir="$INSTALLDIR" --toolchain="$TOOLCHAIN"		
	fi

	export PATH=$INSTALLDIR/bin:$PATH

	pushd $INSTALLDIR/bin

	for GCC_FILE in *-gcc.*; do export ANDROID_TOOLCHAIN=${GCC_FILE%-gcc.*}; done;

	popd
}

function make_all_android-toolchains() {
	make_android_toolchain android-9 arm-linux-androideabi
	make_android_toolchain android-9 mipsel-linux-android
	make_android_toolchain android-9 x86
	make_android_toolchain android-21 aarch64-linux-android
	make_android_toolchain android-21 mips64el-linux-android
	make_android_toolchain android-21 x86_64
}

# param 1: lib name
# param 2: download page
# exit with status 1 if downloading failed
function download_and_unpack() {
	TARBALL=$1.tar.gz
	echo "Check $TARBALL"
	if [ ! -f $TARBALL ] 
	then
		curl -O $2/$TARBALL || exit 1
		rm -rf $1
	fi

	if [ ! -d $1 ]
	then
		tar -xzf $TARBALL
	fi
}
