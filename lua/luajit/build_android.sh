#!/bin/sh
. `pwd`/../../android-toolchain.sh

PREBUILT_DIR=`pwd`/prebuilt/android

SRCDIR=`pwd`/src

if [ ! -z $1 ]
then
	for CFILE in $SRCDIR/src/*.c
	do
		dos2unix ${CFILE}
		chmod +rwxXst ${CFILE}
	done

	for CFILE in $SRCDIR/src/**/*.c
	do
		dos2unix ${CFILE}
		chmod +rwxXst ${CFILE}
	done

	for CFILE in $SRCDIR/src/*.h
	do
		dos2unix ${CFILE}
		chmod +rwxXst ${CFILE}
	done

	for CFILE in $SRCDIR/src/**/*.h
	do
		dos2unix ${CFILE}
		chmod +rwxXst ${CFILE}
	done
fi

function build_luajit() {
	DESTDIR="$PREBUILT_DIR/$2"

	if [ ! -f $DESTDIR/libluajit.a ]
	then
		if [ -d "$DESTDIR" ]
		then
			rm -r "$DESTDIR" || exit 1
		fi

		echo "$DESTDIR"
	
		mkdir -p "$DESTDIR" || exit 1
	
		export CFLAGS=""
		export CPPFLAGS=""
		export LDFLAGS="" 
	
		make_android_toolchain $5 $1
	
		pushd $SRCDIR
	
		make clean && make HOST_CC="gcc $4" CC="gcc $4" TARGET_FLAGS="-mandroid $3 -DANDROID -DNDEBUG -UDEBUG" CROSS=$ANDROID_TOOLCHAIN- TARGET_SYS=Linux -j 4 || exit 1
	
		if [ -f ./src/libluajit.a ]
		then
			mv ./src/libluajit.a "$DESTDIR/libluajit.a"
		fi
	
		popd
	fi
}

build_luajit arm-linux-androideabi armeabi "-march=armv5te -mthumb -mfloat-abi=softfp" "" android-9
build_luajit arm-linux-androideabi armeabi-v7a "-march=armv7-a -mfloat-abi=softfp -mfpu=neon" "" android-9
build_luajit mipsel-linux-android mips "" "" android-9
build_luajit x86 x86 "" "" android-9
#build_luajit aarch64-linux-android arm64-v8a "-march=armv8-a" "" android-21
#build_luajit mips64el-linux-android mips64 "-mabi=64" "" android-21
#build_luajit x86_64-linux-android x86_64 "-m64" "" android-21
