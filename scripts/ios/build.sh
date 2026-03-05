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
zip -r tdjson.xcframework.zip tdjson.xcframework || zip -r tdjson.xcframework.zip libtdjson.xcframework
mv tdjson.xcframework.zip ../../../../

echo ">>> iOS build complete!"
