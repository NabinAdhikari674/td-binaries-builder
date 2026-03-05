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

echo ">>> Cloning and patching Python-Apple-support before OpenSSL build..."
cd example/ios

# Pre-clone Python-Apple-support at the exact pinned commit TDLib uses
git clone https://github.com/beeware/Python-Apple-support Python-Apple-support
cd Python-Apple-support
git checkout 6f43aba0ddd5a9f52f39775d0141bd4363614020
git reset --hard

# Apply TDLib's own patch first
git apply ../Python-Apple-support.patch || echo "Patch already applied or not needed"

echo ">>> Fixing -simulator-simulator bug in Python-Apple-support CC variables..."
# The Makefile defines CC-$(target) using $(SDK).$(ARCH)
# where SDK can be 'iphonesimulator' and then appends '-simulator' 
# producing 'arm64-apple-ios-simulator-simulator'.
# Fix: rewrite the -target flag pattern to deduplicate the simulator suffix.
sed -i '' 's/-simulator-simulator/-simulator/g' Makefile

# Also patch the generated build-target macro if it exists
find . -name "*.mk" -exec sed -i '' 's/-simulator-simulator/-simulator/g' {} \; 2>/dev/null || true

cd ..

echo ">>> Building OpenSSL for iOS (Python-Apple-support already cloned and patched)..."
./build-openssl.sh

echo ">>> Building TDLib (tdjson.xcframework)..."
./build.sh

echo ">>> Packaging artifact..."
cd tdjson
zip -r tdjson.xcframework.zip tdjson.xcframework || zip -r tdjson.xcframework.zip libtdjson.xcframework
# Move to repo root so the workflow can find it
mv tdjson.xcframework.zip ../../../../

echo ">>> iOS build complete!"
