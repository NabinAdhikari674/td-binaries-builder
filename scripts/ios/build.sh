#!/bin/bash
set -e

echo ">>> Building TDLib for iOS..."
brew install gperf cmake coreutils jq

echo ">>> Cloning TDLib Commit: $commit_hash"
git clone https://github.com/tdlib/td.git
cd td
git fetch https://github.com/tdlib/td.git $commit_hash
git checkout $commit_hash
git show --summary

echo ">>> Preparing for cross-compiling..."
mkdir build
cd build
cmake ..
cmake --build . --target prepare_cross_compiling
cd ..

echo ">>> Navigating to iOS example directory..."
cd example/ios

echo ">>> Configuring TDLib iOS build scripts..."
sed -i.bak 's/^platforms=".*"/platforms="iOS"/' build-openssl.sh
sed -i.bak 's/^platforms=".*"/platforms="iOS"/' build.sh
echo "--- Verifying Patches ---"
echo "build-openssl.sh:" && grep 'platforms=' build-openssl.sh
echo "build.sh:" && grep 'platforms=' build.sh

echo ">>> Building OpenSSL for iOS..."
./build-openssl.sh

echo ">>> Building TDLib (tdjson.xcframework)..."
./build.sh

echo ">>> Packaging artifact..."
cd tdjson

FRAMEWORK_NAME=""
if [ -d "tdjson.xcframework" ]; then
  FRAMEWORK_NAME="tdjson.xcframework"
elif [ -d "libtdjson.xcframework" ]; then # Handle older naming convention just in case
  FRAMEWORK_NAME="libtdjson.xcframework"
else
  echo "ERROR: Could not find output tdjson.xcframework. Dumping directory for diagnosis:"
  ls -la
  exit 1
fi

echo "Found framework: $FRAMEWORK_NAME. Zipping..."
zip -r tdjson.xcframework.zip "$FRAMEWORK_NAME"
mv tdjson.xcframework.zip ../../../../

echo ">>> iOS build complete!"
