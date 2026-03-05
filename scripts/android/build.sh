#!/bin/bash
set -e

ARCH=$1
COMMIT_HASH=$2
TD_PATH=$(pwd)/td

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
NDK_VERSION=$(basename "$ANDROID_NDK_LATEST_HOME")
SDK_ROOT=$(dirname $(dirname "$ANDROID_NDK_LATEST_HOME"))
./build-openssl.sh $SDK_ROOT $NDK_VERSION "" "" "" $ARCH

echo ">>> Building TDLib with JSON interface for Android ($ARCH)..."
./build-tdlib.sh $SDK_ROOT $NDK_VERSION "" "" "JSON" $ARCH

echo ">>> Listing output for debugging..."
ls -la $TD_PATH/example/android/tdlib/libs/$ARCH/ || echo "Path not found, searching..."
find $TD_PATH/example/android/tdlib -name "*.so" 2>/dev/null || echo "No .so files found"

echo ">>> Build for $ARCH completed successfully!"
