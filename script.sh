#!/bin/bash

# Accept build configuration (Debug or Release) as the first parameter, default to Release if not provided
BUILD_CONFIGURATION=${1:-Release}

# Set LIBRARY_FOR_DISTRIBUTION based on the build configuration
if [ "$BUILD_CONFIGURATION" == "Release" ]; then
    LIBRARY_FOR_DISTRIBUTION=YES
else
    LIBRARY_FOR_DISTRIBUTION=NO
fi

# Check if zano_ios.xcframework exists and remove it if necessary
if [ -d "./zano_ios.xcframework" ]; then
    echo "Removing existing zano_ios.xcframework..."
    rm -rf "./zano_ios.xcframework"
fi

# Clean the build directory
xcodebuild clean -project "zano-ios.xcodeproj" -scheme "zano-ios" -configuration $BUILD_CONFIGURATION

# Build for iOS Simulator
xcodebuild build \
    -project "zano-ios.xcodeproj" \
    -scheme "zano-ios" \
    -destination "generic/platform=iOS Simulator" \
    -configuration $BUILD_CONFIGURATION \
    -derivedDataPath build \
    Build_library_for_distribution=$LIBRARY_FOR_DISTRIBUTION
# OTHER_SWIFT_FLAGS="-disable-module-verification"
# OTHER_SWIFT_FLAGS="-disable-module-verification"

# Build for iOS Device
xcodebuild build \
    -project "zano-ios.xcodeproj" \
    -scheme "zano-ios" \
    -destination "generic/platform=iOS" \
    -configuration $BUILD_CONFIGURATION \
    -derivedDataPath build \
    Build_library_for_distribution=$LIBRARY_FOR_DISTRIBUTION
# OTHER_SWIFT_FLAGS="-disable-module-verification"
# OTHER_SWIFT_FLAGS="-disable-module-verification"

# Create XCFramework
xcodebuild \
    -create-xcframework \
    -framework "build/Build/Products/$BUILD_CONFIGURATION-iphoneos/zano_ios.framework" \
    -framework "build/Build/Products/$BUILD_CONFIGURATION-iphonesimulator/zano_ios.framework" \
    -output "./zano_ios.xcframework"
