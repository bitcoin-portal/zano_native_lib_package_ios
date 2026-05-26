# zano_native_lib_package_ios

A Swift wrapper around the Zano C++ wallet library, distributed as a prebuilt `zano_ios.xcframework` for iOS. The public Swift API is the `ZanoWallet` enum in [zano-ios/zano.swift](zano-ios/zano.swift). For a runnable usage example, see [zano-ios-sample/](zano-ios-sample/).

## Consuming `zano_ios.xcframework` from an iOS app

There is **no** Swift Package or CocoaPods distribution — the xcframework is dropped into the consuming repo directly.

### 1. Add the xcframework

Copy `zano_ios.xcframework` into your app project. A common convention is a dedicated `Dependencies/` folder at the app target root, e.g. `YourApp/Dependencies/zano_ios.xcframework`.

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

## Updating to a new Zano library version

A library version bump is a **two-PR workflow**: first land the rebuilt artifact in this repo, then update the consuming app to pick it up. For a worked library-side example, see [zano_native_lib_package_ios#7](https://github.com/bitcoin-portal/zano_native_lib_package_ios/pull/7).

This fork has two git remotes:

- `origin` → `bitcoin-portal/zano_native_lib_package_ios` (where we open PRs)
- `upstream` → `hyle-team/zano_native_lib_package_ios` (where new C++ deps land first)

### Step 1 — Pull the new C++ deps into this repo

The upstream `hyle-team` repo is where new C++ builds (`libwallet`, `libboost`, `libcrypto_`, etc.) get bumped first. Sync from there:

```sh
git fetch upstream
git checkout -b update-zano-lib
git merge upstream/main          # or cherry-pick the specific upstream commit
```

The merge will refresh `zano-ios/Dependencies/` on disk. Those files are gitignored ([.gitignore](.gitignore) line 43) and will not appear in `git status`, but they're what the build links against.

If `hyle-team` hasn't yet published the version you need, build the C++ side directly from [`hyle-team/zano_native_lib_package_`](https://github.com/hyle-team/zano_native_lib_package_) and copy its xcframework outputs into `zano-ios/Dependencies/` by hand.

### Step 2 — Rebuild the xcframework

```sh
./script.sh
```

This produces `./zano_ios.xcframework`, overwriting the previously committed copy.

### Step 3 — Smoke-test with the sample app

Open `zano-ios.xcodeproj` in Xcode, select the `zano-ios-sample` scheme, and run on a simulator. If it launches and the basic wallet calls succeed, the rebuild is good.

If the Swift public API changed (e.g. a new method on `ZanoWallet` or a renamed parameter), this is when you'll notice — patch the sample app along with anything else that needs to compile.

### Step 4 — Open a PR in this repo

Commit the rebuilt `zano_ios.xcframework/` (and any Swift source changes). `zano-ios/Dependencies/` stays gitignored — do not try to add it.

```sh
git add zano_ios.xcframework zano-ios   # plus zano-ios-sample if you touched it
git commit -m "Update zano lib"
git push -u origin update-zano-lib
gh pr create --base main
```

### Step 5 — Open the matching PR in the consuming app

In the consuming app's repo, replace its committed copy of the xcframework:

```sh
rm -rf <path/to>/zano_ios.xcframework
cp -R ../zano_native_lib_package_ios/zano_ios.xcframework <path/to>/
```

A few things to expect:

- **The consuming app's `.xcodeproj/project.pbxproj` will be modified automatically** when Xcode picks up the new framework hashes. The pbxproj churn is normal — commit it.
- **Audit every consumer of `ZanoWallet`** for API changes. Additions are usually safe; renames or signature changes will surface as compile errors.
- **Link the library PR as a blocker** in the consuming app's PR body so reviewers know the two need to merge together.

The committed `zano_ios.xcframework` is the only artifact — there is no remote registry, no Swift Package, no CocoaPods.

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
