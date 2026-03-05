#!/bin/bash
set -e

echo ">>> Building TDLib for WebAssembly..."

echo ">>> Setting up dependencies..."
sudo apt-get update
sudo apt-get install -y make git zlib1g-dev libssl-dev gperf cmake clang ninja-build jq

echo ">>> Setting up Emscripten..."
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
cd $GITHUB_WORKSPACE

echo ">>> Cloning TDLib Commit: $commit_hash"
git clone https://github.com/tdlib/td.git
cd td
git fetch https://github.com/tdlib/td.git $commit_hash
git checkout $commit_hash
git show --summary

echo ">>> Patching TDLib CMakeLists.txt to allow building OpenSSL for WebAssembly..."
sed -i "/message(WARNING \"Can't find OpenSSL: stop building\")/{n;d}" CMakeLists.txt
echo "--- Verifying patch (the 'return()' line should be gone) ---"
grep -C 4 "Can't find OpenSSL" CMakeLists.txt

echo ">>> Step 1: Build native tools (prepare_cross_compiling generates required source files)..."
mkdir build-native
cd build-native
cmake ..
cmake --build . --target prepare_cross_compiling
cd ..

echo ">>> Step 2: Build with Emscripten..."
mkdir build-wasm
cd build-wasm
source $GITHUB_WORKSPACE/emsdk/emsdk_env.sh

# Configure with Emscripten. tdjson is the shared-library target.
emcmake cmake \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DTD_ENABLE_LTO=ON \
  -DCMAKE_CROSSCOMPILING=TRUE \
  ..

echo ">>> Step 3: Listing all available CMake targets..."
emmake make help 2>&1 | grep -i "td\|json\|wasm\|emscripten" | head -20 || true

echo ">>> Step 4: Build the tdjson target for Emscripten..."
emmake make -j4 tdjson

echo ">>> Step 5: Listing build directory..."
find . -maxdepth 3 -name "*.js" -o -name "*.wasm" 2>/dev/null
ls -la

echo ">>> Step 6: Packaging artifacts..."
JS_FILE=$(find . -maxdepth 3 -name "*.js" ! -name "*.worker.js" | head -1)
WASM_FILE=$(find . -maxdepth 3 -name "*.wasm" | head -1)

if [ -z "$JS_FILE" ] || [ -z "$WASM_FILE" ]; then
  echo "ERROR: No .js/.wasm output files found. Dumping full build tree for diagnosis:"
  find . -type f | head -50
  exit 1
fi

echo "Found JS: $JS_FILE"
echo "Found WASM: $WASM_FILE"
zip tdlib.zip "$JS_FILE" "$WASM_FILE"

echo ">>> Web build complete!"
