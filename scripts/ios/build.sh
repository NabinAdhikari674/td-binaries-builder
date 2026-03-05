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

echo ">>> Building OpenSSL..."
cd ../example/ios

# Clone the Python-Apple-support dependency ahead of time
# so we can patch it BEFORE the Makefile runs clang with the wrong target triple.
git clone https://github.com/beeware/Python-Apple-support
cd Python-Apple-support
git checkout 6f43aba0ddd5a9f52f39775d0141bd4363614020
git reset --hard
git apply ../Python-Apple-support.patch

echo ">>> Patching '-simulator-simulator' bug in Python-Apple-support Makefiles..."
# Fix all occurrences of the invalid double-simulator target triple in-place
grep -rl "\-simulator-simulator" . | xargs -I{} sed -i '' 's/-simulator-simulator/-simulator/g'

cd ..

# Now run the openssl build (the Python-Apple-support clone already exists and is patched,
# so build-openssl.sh will skip re-cloning and use our patched version)
./build-openssl.sh

echo ">>> Building TDLib (tdjson.xcframework)..."
./build.sh

echo ">>> Packaging artifact..."
cd tdjson
zip -r tdjson.xcframework.zip tdjson.xcframework
mv tdjson.xcframework.zip ../../../

echo ">>> iOS build complete!"
