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
# 1. Build OpenSSL (Required by TDLib)
# TDLib provides a helper for this in their examples
./build-openssl.sh $NDK_PATH "34" "" "" "" $ARCH

echo ">>> Building TDLib with JSON interface for Android ($ARCH)..."
# 2. Build TDLib with JSON interface
# Params: NDK_PATH, SDK_VERSION, OPENSSL_PATH, STL, INTERFACE
./build-tdlib.sh $NDK_PATH "34" "" "" "JSON" $ARCH

echo ">>> Build for $ARCH completed successfully!"
