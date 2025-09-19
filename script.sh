#!/usr/bin/env bash
set -euo pipefail

# ========== Config ==========
PROJECT="zano-ios.xcodeproj"
SCHEME="zano-ios"
CONFIGURATION="${1:-Release}"   # default Release
OUT_XCFRAMEWORK="./zano_ios.xcframework"

# Where to put archives and intermediates
BUILD_DIR="./build"
ARCHIVE_DIR="$BUILD_DIR/archives"
IOS_ARCHIVE="$ARCHIVE_DIR/ios.xcarchive"
SIM_ARCHIVE="$ARCHIVE_DIR/iossim.xcarchive"

# Match your framework (module) name. For target 'zano-ios' Xcode will emit 'zano_ios.framework'
FRAMEWORK_NAME="zano_ios.framework"

# Verbose output control
VERBOSE=${VERBOSE:-false}
if [[ "$VERBOSE" == "true" ]]; then
  QUIET_FLAG=""
  echo "==> Verbose mode enabled"
else
  QUIET_FLAG="> /dev/null"
fi

# BUILD_LIBRARY_FOR_DISTRIBUTION only for Release
if [[ "$CONFIGURATION" == "Release" ]]; then
  BLD_FOR_DIST="YES"
else
  BLD_FOR_DIST="NO"
fi

echo "==> Clean"
rm -rf "$OUT_XCFRAMEWORK" "$BUILD_DIR"
mkdir -p "$ARCHIVE_DIR"

echo "==> Cleaning Xcode project"
if [[ "$VERBOSE" == "true" ]]; then
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" clean
else
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" clean > /dev/null
fi

echo "==> Archive (iOS Device)"
if [[ "$VERBOSE" == "true" ]]; then
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS" \
    -archivePath "$IOS_ARCHIVE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST" \
    DEBUG_INFORMATION_FORMAT=dwarf
else
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS" \
    -archivePath "$IOS_ARCHIVE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST" \
    DEBUG_INFORMATION_FORMAT=dwarf \
    > /dev/null || { echo "error: iOS device archive failed"; exit 1; }
fi

echo "==> Archive (iOS Simulator)"
if [[ "$VERBOSE" == "true" ]]; then
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$SIM_ARCHIVE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST" \
    DEBUG_INFORMATION_FORMAT=dwarf
else
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$SIM_ARCHIVE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST" \
    DEBUG_INFORMATION_FORMAT=dwarf \
    > /dev/null || { echo "error: iOS simulator archive failed"; exit 1; }
fi

# Find frameworks dynamically instead of assuming fixed paths
echo "==> Locating frameworks in archives"
IOS_FRAMEWORK=$(find "$IOS_ARCHIVE/Products" -name "$FRAMEWORK_NAME" -type d 2>/dev/null | head -1)
SIM_FRAMEWORK=$(find "$SIM_ARCHIVE/Products" -name "$FRAMEWORK_NAME" -type d 2>/dev/null | head -1)

# Sanity checks with better error messages
if [[ -z "$IOS_FRAMEWORK" || ! -d "$IOS_FRAMEWORK" ]]; then
  echo "error: Missing device framework '$FRAMEWORK_NAME' in archive"
  echo "Archive contents:"
  find "$IOS_ARCHIVE/Products" -type d -name "*.framework" 2>/dev/null || echo "No frameworks found"
  exit 1
fi

if [[ -z "$SIM_FRAMEWORK" || ! -d "$SIM_FRAMEWORK" ]]; then
  echo "error: Missing simulator framework '$FRAMEWORK_NAME' in archive"
  echo "Archive contents:"
  find "$SIM_ARCHIVE/Products" -type d -name "*.framework" 2>/dev/null || echo "No frameworks found"
  exit 1
fi

echo "==> Found device framework: $IOS_FRAMEWORK"
echo "==> Found simulator framework: $SIM_FRAMEWORK"

echo "==> Create XCFramework (without dSYMs)"
# Create XCFramework without any debug symbols
if [[ "$VERBOSE" == "true" ]]; then
  xcodebuild -create-xcframework \
    -framework "$IOS_FRAMEWORK" \
    -framework "$SIM_FRAMEWORK" \
    -output "$OUT_XCFRAMEWORK"
else
  xcodebuild -create-xcframework \
    -framework "$IOS_FRAMEWORK" \
    -framework "$SIM_FRAMEWORK" \
    -output "$OUT_XCFRAMEWORK" \
    || { echo "error: XCFramework creation failed"; exit 1; }
fi

echo "==> Done: $OUT_XCFRAMEWORK"

# Verify the output
if [[ -d "$OUT_XCFRAMEWORK" ]]; then
  echo "==> XCFramework created successfully"
  if [[ "$VERBOSE" == "true" ]]; then
    echo "==> XCFramework contents:"
    find "$OUT_XCFRAMEWORK" -type d -name "*.framework" | head -5
  fi
else
  echo "error: XCFramework was not created"
  exit 1
fi