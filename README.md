# zano_native_lib_package_ios

A Swift wrapper around the Zano C++ wallet library, distributed as a prebuilt `zano_ios.xcframework` for iOS. The public Swift API is the `ZanoWallet` enum in [zano-ios/zano.swift](zano-ios/zano.swift). For a runnable usage example, see [zano-ios-sample/](zano-ios-sample/).

## Consuming `zano_ios.xcframework` from an iOS app

This is how [`wallet-ios`](https://github.com/bitcoin-portal/wallet-ios) consumes the library, and how any other iOS app should too. There is **no** Swift Package or CocoaPods distribution — the xcframework is dropped into the consuming repo directly.

### 1. Add the xcframework

Copy `zano_ios.xcframework` into your app project. In `wallet-ios` it lives at:

```
BitcoinComWallet/Dependencies/zano_ios.xcframework
```

The xcframework bundles every transitive C++ dependency (`libboost`, `libwallet`, `libcrypto_`, etc.). You do **not** need to add anything from this repo's `zano-ios/Dependencies/` to your app — those are build-time-only inputs to `script.sh`.

### 2. Link and embed in Xcode

In your app target's **General** tab → **Frameworks, Libraries, and Embedded Content**:

1. Add `zano_ios.xcframework`.
2. Set it to **Embed & Sign**.

> ⚠️ **Embed & Sign is required.** "Do Not Embed" builds will run on the simulator but crash on launch in TestFlight / App Store builds.

### 3. Use the API from Swift

```swift
import zano_ios

let json = ZanoWallet.InitIpPort(
    ip: "127.0.0.1",
    port: "11211",
    working_dir: NSTemporaryDirectory(),
    log_level: 0
)
```

All `ZanoWallet` methods return a JSON string from the underlying C++ wallet API. The sample app shows one approach to decoding these — see [zano-ios-sample/ZanoService.swift](zano-ios-sample/ZanoService.swift) and [zano-ios-sample/JSONRPC/](zano-ios-sample/JSONRPC/).

The methods listed in `asyncCallMethods` ([zano-ios/zano.swift:13](zano-ios/zano.swift)) dispatch asynchronously inside the C++ layer; everything else is synchronous. Call them off the main thread.

## Updating the xcframework shipped with `wallet-ios`

When this library changes, rebuild and replace the copy in `wallet-ios`:

```sh
# In this repo:
./script.sh                                  # produces ./zano_ios.xcframework

# Then in wallet-ios:
rm -rf BitcoinComWallet/Dependencies/zano_ios.xcframework
cp -R ../zano_native_lib_package_ios/zano_ios.xcframework \
      BitcoinComWallet/Dependencies/
```

Commit the replaced `zano_ios.xcframework` in `wallet-ios` — it is checked in directly, there is no remote artifact.

## Building the xcframework

```sh
./script.sh           # Release (default) — BUILD_LIBRARY_FOR_DISTRIBUTION=YES
./script.sh Debug     # Debug
VERBOSE=true ./script.sh   # full xcodebuild output
```

Output is `./zano_ios.xcframework` at the repo root.

> 📦 **Fresh clones need the C++ deps.** `zano-ios/Dependencies/` is gitignored and must be populated with the prebuilt C++ xcframeworks (`libboost`, `libcommon.a`, `libcrypto_.a`, `libcurrency_core.a`, `libwallet.a`, `libz.a`, plus `openssl/`) before the build will succeed. These come from [`hyle-team/zano_native_lib_package_`](https://github.com/hyle-team/zano_native_lib_package_). If the build fails with missing modules or unresolved symbols, this is almost always the cause.

## Repo layout

- [zano-ios/](zano-ios/) — the Swift wrapper target (built into `zano_ios.xcframework`).
- [zano-ios-sample/](zano-ios-sample/) — SwiftUI sample app demonstrating consumption.
- [script.sh](script.sh) — xcframework build script.
- [zano_ios.xcframework/](zano_ios.xcframework/) — most recently built artifact, checked in for convenience.
