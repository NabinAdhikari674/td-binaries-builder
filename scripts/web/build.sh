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

echo ">>> Preparing cross-compilation native tools..."
mkdir build-native
cd build-native
cmake ..
cmake --build . --target prepare_cross_compiling
cd ..

echo ">>> Building WASM via Emscripten..."
mkdir build-wasm
cd build-wasm
emcmake cmake -DCMAKE_BUILD_TYPE=MinSizeRel -DTD_ENABLE_LTO=ON ..
emmake make -j4

echo ">>> Packaging artifacts..."
echo "--- Files in build-wasm/ after build ---"
ls -la

JS_FILE=$(find . -maxdepth 1 -name "*.js" ! -name "*.worker.js" | head -1)
WASM_FILE=$(find . -maxdepth 1 -name "*.wasm" | head -1)

if [ -z "$JS_FILE" ] || [ -z "$WASM_FILE" ]; then
  echo "ERROR: Could not find output JS or WASM files in build-wasm/. Build may have failed silently."
  ls -la
  exit 1
fi

echo "Found JS: $JS_FILE"
echo "Found WASM: $WASM_FILE"

zip tdlib.zip "$JS_FILE" "$WASM_FILE"

echo ">>> Web build complete!"
