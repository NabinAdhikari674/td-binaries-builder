# TDLib Binaries Builder

A CI/CD infrastructure designed to compile the **Telegram Database Library (TDLib)** for high-performance cross-platform Flutter and Dart applications. 

This repository automates the complex native compilation process for Android, iOS, and Web (WebAssembly), providing ready-to-use binaries as GitHub Releases.

## 🚀 Key Features

*   **Matrix Parallel Builds**: Utilizes GitHub Actions matrix strategy to compile multiple Android architectures simultaneously, significantly reducing build times.
*   **Modern Target Support**: 
    *   **Android**: Generates `libtdjson.so` for `arm64-v8a`, `armeabi-v7a`, `x86_64`, and `x86`.
    *   **iOS**: Produces a modern `tdjson.xcframework` supporting both Physical Devices and Simulators.
    *   **Web**: Compiles `tdjson.js` and `tdjson.wasm` using the Emscripten SDK.
*   **Version Controlled**: Pin exact TDLib versions and commit hashes for deterministic, reproducible builds.

## 🛠 Repository Structure

*   `.github/workflows/`: Workflow logic for parallel and sequential build jobs.
*   `scripts/`: Platform-specific bash scripts utilizing official TDLib build helpers.
*   `td-version.json`: The central configuration file for targeting specific TDLib releases.

## ⚖️ License

This project is licensed under a **Custom Source Available License**.

*   **Personal Use**: Allowed, similar to the MIT license terms.
*   **Commercial Use**: Strictly prohibited without explicit written permission from the author.

For full terms, see the [LICENSE](LICENSE) file.

Please note that this project provides build automation for TDLib. The library itself is subject to the [TDLib License](https://github.com/tdlib/td/blob/master/LICENSE_1_0.txt) (Boost Software License 1.0).