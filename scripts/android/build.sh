#!/bin/bash
set -e

ARCH=$1
COMMIT_HASH=$2
TD_PATH=$(pwd)/td
NDK_PATH=$ANDROID_NDK_LATEST_HOME 

echo ">>> Cloning TDLib Commit: $COMMIT_HASH"
if [ ! -d "td" ]; then
    git clone https://github.com/tdlib/td.git
fi
cd td
git fetch https://github.com/tdlib/td.git $COMMIT_HASH
git checkout $COMMIT_HASH
cd ..

cd $TD_PATH/example/android

echo ">>> Building OpenSSL for Android ($ARCH)..."
# TDLib's build-openssl.sh expects: ANDROID_SDK_ROOT ANDROID_NDK_VERSION OPENSSL_INSTALL_DIR OPENSSL_VERSION
NDK_VERSION=$(basename "$ANDROID_NDK_LATEST_HOME")
SDK_ROOT=$(dirname $(dirname "$ANDROID_NDK_LATEST_HOME"))
./build-openssl.sh $SDK_ROOT $NDK_VERSION "" "" "" $ARCH

echo ">>> Building TDLib with JSON interface for Android ($ARCH)..."
# TDLib's build-tdlib.sh expects: ANDROID_SDK_ROOT ANDROID_NDK_VERSION OPENSSL_INSTALL_DIR STL_VERSION INTERFACE ARCH
./build-tdlib.sh $SDK_ROOT $NDK_VERSION "" "" "JSON" $ARCH

echo ">>> Build for $ARCH completed successfully!"
