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

git clone https://github.com/beeware/Python-Apple-support
cd Python-Apple-support
git checkout 6f43aba0ddd5a9f52f39775d0141bd4363614020
git reset --hard
git apply ../Python-Apple-support.patch || echo "Patch application warning (may be OK)"

echo ">>> Fixing TARGET_TRIPLE -simulator-simulator bug in patched Makefile..."
python3 << 'PYFIX'
with open('Makefile', 'r') as f:
    content = f.read()

old = 'TARGET_TRIPLE-$(target)=$$(ARCH-$(target))-apple-$$(OS_LOWER-$(target))-simulator'
new = 'TARGET_TRIPLE-$(target)=$$(ARCH-$(target))-apple-$$(subst -simulator,,$$(OS_LOWER-$(target)))-simulator'

if old in content:
    content = content.replace(old, new)
    print(f'SUCCESS: Replaced TARGET_TRIPLE line')
else:
    print('WARNING: Could not find exact TARGET_TRIPLE line to patch')
    # Dump all TARGET_TRIPLE lines for debugging
    for i, line in enumerate(content.split('\n')):
        if 'TARGET_TRIPLE' in line:
            print(f'  Line {i+1}: {line.strip()}')

with open('Makefile', 'w') as f:
    f.write(content)
PYFIX

echo "--- Verify fix applied ---"
grep -n "TARGET_TRIPLE" Makefile | head -10

cd ..

echo ">>> Building OpenSSL for iOS..."
./build-openssl.sh

echo ">>> Building TDLib (tdjson.xcframework)..."
./build.sh

echo ">>> Packaging artifact..."
cd tdjson
zip -r tdjson.xcframework.zip tdjson.xcframework || zip -r tdjson.xcframework.zip libtdjson.xcframework
mv tdjson.xcframework.zip ../../../../

echo ">>> iOS build complete!"
