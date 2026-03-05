# TDLib Pre-Compiled Binaries

Automated GitHub Actions and shell scripts to compile [TDLib](https://github.com/tdlib/td) (Telegram Database Library) into `.so`, `.xcframework`, and `.wasm` artifacts for Flutter integration.

## Architecture

* **`.github/workflows/`**: Contains parallel execution matrix logic.
  * `master-build.yml`: Orchestrator for platform builds.
  * `build-*.yml`: Reusable platform-specific matrix execution nodes.
* **`scripts/`**: Reusable bash shell execution scripts that map line-by-line build logic.
* **`td-version.json`**: Central source of truth for TDLib target version & commit hashes.

## Manual Execution 

You can manually trigger compilation builds without necessarily tying them to `push` hooks.
Go to your GitHub Actions tab > **Master TDLib Build** -> `Run Workflow`. 

## Updating the Binary

Just update `td-version.json`, ensure it's structurally valid, and push it to `main`. The `master-build.yml` Action will sequentially kick everything off.
