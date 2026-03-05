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
zip tdlib.zip tdjson.js tdjson.wasm

echo ">>> Web build complete!"
