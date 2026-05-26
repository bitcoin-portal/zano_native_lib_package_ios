# CLAUDE.md

Swift wrapper around the Zano C++ wallet library, distributed as `zano_ios.xcframework`. This repo builds the framework and ships a SwiftUI sample app that exercises the API.

User-facing setup and workflow instructions live in [README.md](README.md). In particular, the **"Updating to a new Zano library version"** section in the README is the end-to-end recipe for syncing C++ deps from upstream, rebuilding the xcframework, and propagating the change to the consuming app. This file covers what the README doesn't — internal code layout and interop rules.

## Repo layout

- [zano-ios/](zano-ios/) — framework target sources.
  - [zano.swift](zano-ios/zano.swift) — public Swift API (`ZanoWallet` enum, free functions).
  - [StringConversionUtils.swift](zano-ios/StringConversionUtils.swift) — Swift ↔ C++ `std::string` marshalling via `CxxStdlib`.
  - [Internal/ZanoCore.swift](zano-ios/Internal/ZanoCore.swift) — wraps the Objective-C bridge.
  - [Internal/Objective-C/ZanoBridgeShim.{h,mm}](zano-ios/Internal/Objective-C/) — Obj-C++ shim into `plain_wallet_api`.
  - [wallet/module.modulemap](zano-ios/wallet/module.modulemap) — exposes `plain_wallet_api.h` from the libwallet xcframework.
  - `Dependencies/` — **gitignored**, see below.
- [zano-ios-sample/](zano-ios-sample/) — SwiftUI sample app consuming the framework.
  - [JSONRPC/](zano-ios-sample/JSONRPC/) — small JSON-RPC layer for the wallet `invoke` proxy.
- [zano-iosTests/](zano-iosTests/) — framework unit tests.
- [zano-ios-sampleTests/](zano-ios-sampleTests/), [zano-ios-sampleUITests/](zano-ios-sampleUITests/) — sample-app unit and UI tests.
- [script.sh](script.sh) — xcframework build entrypoint.

## Dependencies are gitignored

[.gitignore](.gitignore) excludes `zano-ios/Dependencies/`. The prebuilt C++ xcframeworks (`libboost`, `libcommon.a`, `libcrypto_.a`, `libcurrency_core.a`, `libwallet.a`, `libz.a`, `openssl/`) live there at build time but never appear in `git status`.

If a build fails with missing modules or unresolved C++ symbols, the deps directory is the first place to check — don't go hunting in the Swift code. See the README's update workflow for how to populate it (sync from `upstream` remote or build from `hyle-team/zano_native_lib_package_`).

## Build & test

Build the xcframework (default `Release`):

```sh
./script.sh            # Release — sets BUILD_LIBRARY_FOR_DISTRIBUTION=YES
./script.sh Debug      # Debug — BUILD_LIBRARY_FOR_DISTRIBUTION=NO
VERBOSE=true ./script.sh  # full xcodebuild output
```

Output: `./zano_ios.xcframework`. The script archives for both `iOS` and `iOS Simulator` then runs `-create-xcframework`.

Run the framework tests:

```sh
xcodebuild test -project zano-ios.xcodeproj -scheme zano-ios \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Only one shared scheme exists: `zano-ios`. The sample-app tests run from the sample target inside Xcode.

## C++ interop rules

The bridge is layered: Swift public API → Swift internal → Obj-C++ shim → C++ `plain_wallet_api`. A few non-obvious rules:

- **Never pass `String` directly to the C++ layer.** Use `StringConversionUtils.swiftStringToCppString(_:)` — it allocates, copies, and deallocates the intermediate buffer for you. Calling the lower-level `swiftStringToStdString` without `deallocate` leaks.
- **Public surface lives in [zano.swift](zano-ios/zano.swift) only.** `ZanoCore` and the `ZanoBridgeShim` are `internal import`s — don't expose their types from public functions.
- **`asyncCallMethods` in [zano.swift:13](zano-ios/zano.swift)** enumerates which `invoke` targets dispatch async (`close`, `open`, `restore`, `get_seed_phrase_info`, `invoke`, `get_wallet_status`). When wrapping new wallet methods, update this list if they block.
- **CxxStdlib interop is enabled** (`internal import CxxStdlib`). This requires Swift 5.9+ and the framework target's C++ interoperability build setting; don't disable it.

## Code style

Defer to [.swift-format](.swift-format). Key choices baked in there: 4-space indent, 100-col line length, ordered imports, lowerCamelCase enforced, no block comments, ASCII identifiers only. Run `swift-format` before committing.

Ruby 3.2.4 is pinned in [.tool-versions](.tool-versions) for tooling around the iOS build (asdf/mise).

## Consumer setup and library updates

See [README.md](README.md). The two things worth repeating because they cause silent failures:

- Consumers must set `zano_ios.xcframework` to **Embed & Sign** — "Do Not Embed" crashes on launch in release builds.
- A library version bump is a **two-PR workflow**: one PR here (rebuilt artifact) and one in the consuming app (artifact copy + consumer adjustments), linked as blockers.
