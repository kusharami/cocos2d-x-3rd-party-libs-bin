#!/bin/bash
. `pwd`/../android-toolchain.sh

if [ ! -z $1 ]
then
	export CYGWIN="winsymlinks:native"
fi

# 1. Get sources
LIBCURL_SRC=curl-7.40.0
OPENSSL_SRC=openssl-1.0.2
LIBCURL_PAGE=http://curl.haxx.se/download
OPENSSL_PAGE=http://www.openssl.org/source
LIBCURL_ROOT=`pwd`/curl
OPENSSL_ROOT=`pwd`/openssl
CPU_COUNT=4

download_and_unpack $LIBCURL_SRC $LIBCURL_PAGE
download_and_unpack $OPENSSL_SRC $OPENSSL_PAGE

LIBCURL_SRC=`pwd`/$LIBCURL_SRC
OPENSSL_SRC=`pwd`/$OPENSSL_SRC

PREBUILT_DIR=`pwd`/prebuilt/android
CURL_EXTRA="--enable-ipv6 --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-sspi --disable-manual"
CURL_CFLAGS="-mandroid -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-short-enums -Wno-multichar -fmessage-length=0 -W -Wall -Wno-unused -Winit-self -Wpointer-arith -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -g -Wstrict-aliasing=2 -finline-functions -fno-inline-functions-called-once -fgcse-after-reload -frerun-cse-after-loop -frename-registers -Os -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64"
CURL_CPPFLAGS="-DANDROID -DNDEBUG -UDEBUG -DSK_RELEASE"
OPENSSL_CONFIGURE=`pwd`/Configure

# $1: host
# $2: arch
# $3: abi
# $4: flags
# $5: platform
function build_curl() {	
	if [ ! -d "$PREBUILT_DIR/$3" ] || [ ! -f "$PREBUILT_DIR/$3/libcurl.a" ] || [ ! -f "$PREBUILT_DIR/$3/libssl.a" ] || [ ! -f "$PREBUILT_DIR/$3/libcrypto.a" ]
	then
		if [ ! -d "$PREBUILT_DIR/$3" ]
		then
			mkdir -p "$PREBUILT_DIR/$3" || exit 1
		fi

		make_standalone_toolchain $5 $1

		export CC=$ANDROID_TOOLCHAIN-gcc
		export CXX=$ANDROID_TOOLCHAIN-g++
		export AR=$ANDROID_TOOLCHAIN-ar
		export RANLIB=$ANDROID_TOOLCHAIN-ranlib
		export CFLAGS=""
		export CPPFLAGS=""
		export LDFLAGS=""

		if [ ! -f "$PREBUILT_DIR/$3/libcrypto.a" ] || [ ! -f "$PREBUILT_DIR/$3/libssl.a" ] || [ ! -d "$OPENSSL_ROOT/$3" ]
		then
			echo "Copy files into $OPENSSL_ROOT/$3"

			if [ -d "$OPENSSL_ROOT/$3" ]
			then
				rm -r "$OPENSSL_ROOT/$3" || exit 1
			fi
	
			if [ ! -d "$OPENSSL_ROOT" ]
			then
				mkdir -p "$OPENSSL_ROOT"
			fi
			
			cp -P -r "$OPENSSL_SRC" "$OPENSSL_ROOT/$3" || exit 1
			cp -v -f "$OPENSSL_CONFIGURE" "$OPENSSL_ROOT/$3/Configure" || exit 1
	
			# Build OPENSSL
	
			pushd "$OPENSSL_ROOT/$3"
		
			./Configure $2 no-shared || exit 1
			make clean && make build_crypto build_ssl -j $CPU_COUNT || exit 1
	
			cp -v -f libcrypto.a "$PREBUILT_DIR/$3" || exit 1
			cp -v -f libssl.a "$PREBUILT_DIR/$3" || exit 1
	
			popd
		fi

		# Build CURL

		echo "Copy files into $LIBCURL_ROOT/$3"		

		if [ -d "$LIBCURL_ROOT/$3" ]
		then
			rm -r "$LIBCURL_ROOT/$3" || exit 1
		fi

		if [ ! -d "$LIBCURL_ROOT" ]
		then
			mkdir -p "$LIBCURL_ROOT"
		fi

		cp -P -r "$LIBCURL_SRC" "$LIBCURL_ROOT/$3" || exit 1

		pushd "$LIBCURL_ROOT/$3"

		ln -s "$OPENSSL_ROOT/$3" openssl
		ln -s "$OPENSSL_ROOT/$3/include/openssl" include/openssl
		ln -s "$OPENSSL_ROOT/$3" lib/openssl
		ln -s "$OPENSSL_ROOT/$3" src/openssl
		ln -s "$OPENSSL_ROOT/$3" "$OPENSSL_ROOT/$3/lib"		

		export CFLAGS="$CURL_CFLAGS $4"
		export CPPFLAGS="$CURL_CPPFLAGS"
		export LDFLAGS="-L./openssl"

		./configure --disable-shared --enable-static --host=$ANDROID_TOOLCHAIN --with-ssl="./openssl" --without-ca-bundle --without-ca-path --with-zlib $CURL_EXTRA || exit 1
		make clean && make -j $CPU_COUNT || exit 1

		cp -v -f lib/.libs/libcurl.a "$PREBUILT_DIR/$3" || exit 1
	
		popd
	fi
}

# 2.3.2 Build CURL for Android

build_curl arm-linux-androideabi android-armv5 armeabi "-march=armv5te -mthumb -mfloat-abi=softfp" android-9 &
build_curl arm-linux-androideabi android-armv7 armeabi-v7a "-march=armv7-a -mfloat-abi=softfp -mfpu=neon" android-9 &
build_curl mipsel-linux-android android-mips mips "" android-9 &
build_curl x86 android-x86 x86 "" android-9 &
build_curl aarch64-linux-android android-arm64 arm64-v8a "-march=armv8-a" android-21 &
build_curl mips64el-linux-android linux64-mips64 mips64 "-mabi=64" android-21 &
build_curl x86_64-linux-android android-x86_64 x86_64 "-m64" android-21 &
wait 

# 3 Copy headers
echo "Copy header files into $HEADERS_DIR"
if [ ! -d "$HEADERS_DIR" ]
then
	mkdir -p "$HEADERS_DIR"
fi
cp -f $LIBCURL_SRC/include/curl/*.h $HEADERS_DIR