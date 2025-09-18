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

# Skip dSYMs control (useful when dSYMs cause xcodebuild issues)
SKIP_DSYMS=${SKIP_DSYMS:-false}
if [[ "$SKIP_DSYMS" == "true" ]]; then
  echo "==> Skipping dSYMs (SKIP_DSYMS=true)"
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
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST"
else
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS" \
    -archivePath "$IOS_ARCHIVE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST" \
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
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST"
else
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$SIM_ARCHIVE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION="$BLD_FOR_DIST" \
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

# Locate debug symbols
IOS_DSYM="$IOS_ARCHIVE/dSYMs/$FRAMEWORK_NAME.dSYM"
SIM_DSYM="$SIM_ARCHIVE/dSYMs/$FRAMEWORK_NAME.dSYM"
IOS_BCSYMBOLMAP_DIR="$IOS_ARCHIVE/BCSymbolMaps"

echo "==> Create XCFramework"
# Build argument list dynamically so we only add debug symbols that exist
args=( -create-xcframework )

# Device slice
args+=( -framework "$IOS_FRAMEWORK" )
if [[ "$SKIP_DSYMS" != "true" && -d "$IOS_DSYM" ]]; then
  echo "==> Checking iOS dSYM: $IOS_DSYM"
  
  # Extract just the framework name without .framework extension for DWARF file
  BARE_NAME="${FRAMEWORK_NAME%.framework}"
  
  # Check for valid dSYM structure
  DWARF_FILE1="$IOS_DSYM/Contents/Resources/DWARF/$FRAMEWORK_NAME"
  DWARF_FILE2="$IOS_DSYM/Contents/Resources/DWARF/$BARE_NAME"
  
  echo "==> Looking for DWARF files:"
  echo "    $DWARF_FILE1"
  echo "    $DWARF_FILE2"
  
  # Check if DWARF files exist and are not empty
  DWARF_VALID=false
  if [[ -f "$DWARF_FILE1" && -s "$DWARF_FILE1" ]]; then
    echo "==> Found non-empty DWARF file: $DWARF_FILE1"
    # Additional check: use file command to verify it's a valid DWARF file
    if command -v file >/dev/null 2>&1; then
      FILE_TYPE=$(file "$DWARF_FILE1" 2>/dev/null || echo "unknown")
      echo "==> DWARF file type: $FILE_TYPE"
      if [[ "$FILE_TYPE" == *"dSYM"* ]] || [[ "$FILE_TYPE" == *"DWARF"* ]] || [[ "$FILE_TYPE" == *"Mach-O"* ]]; then
        DWARF_VALID=true
      fi
    else
      # If file command not available, assume valid if non-empty
      DWARF_VALID=true
    fi
  elif [[ -f "$DWARF_FILE2" && -s "$DWARF_FILE2" ]]; then
    echo "==> Found non-empty DWARF file: $DWARF_FILE2"
    if command -v file >/dev/null 2>&1; then
      FILE_TYPE=$(file "$DWARF_FILE2" 2>/dev/null || echo "unknown")
      echo "==> DWARF file type: $FILE_TYPE"
      if [[ "$FILE_TYPE" == *"dSYM"* ]] || [[ "$FILE_TYPE" == *"DWARF"* ]] || [[ "$FILE_TYPE" == *"Mach-O"* ]]; then
        DWARF_VALID=true
      fi
    else
      DWARF_VALID=true
    fi
  fi
  
  if [[ "$DWARF_VALID" == "true" ]]; then
    echo "==> Valid dSYM found, adding to XCFramework"
    # Convert to absolute path to avoid xcodebuild path issues
    ABS_IOS_DSYM=$(cd "$(dirname "$IOS_DSYM")" && pwd)/$(basename "$IOS_DSYM")
    args+=( -debug-symbols "$ABS_IOS_DSYM" )
  else
    echo "==> Warning: iOS dSYM appears invalid or empty, skipping"
    echo "==> dSYM structure:"
    find "$IOS_DSYM" -type f 2>/dev/null | head -10 || echo "No files found in dSYM"
    if [[ -f "$DWARF_FILE1" ]]; then
      echo "==> DWARF file size: $(ls -lh "$DWARF_FILE1" | awk '{print $5}')"
    fi
    if [[ -f "$DWARF_FILE2" ]]; then
      echo "==> DWARF file size: $(ls -lh "$DWARF_FILE2" | awk '{print $5}')"
    fi
  fi
elif [[ "$SKIP_DSYMS" == "true" ]]; then
  echo "==> Skipping iOS dSYM (SKIP_DSYMS=true)"
else
  echo "==> No iOS dSYM found at: $IOS_DSYM"
fi

# Include any BCSymbolMaps if present (Release with bitcode-era projects; safe to skip if none)
if [[ -d "$IOS_BCSYMBOLMAP_DIR" ]]; then
  echo "==> Checking for BCSymbolMaps"
  bcsymbolmap_count=0
  
  # Use a more compatible approach for finding BCSymbolMaps
  if command -v find >/dev/null 2>&1; then
    while IFS= read -r sm; do
      if [[ -n "$sm" ]]; then
        echo "==> Adding BCSymbolMap: $(basename "$sm")"
        args+=( -debug-symbols "$sm" )
        ((bcsymbolmap_count++))
      fi
    done <<< "$(find "$IOS_BCSYMBOLMAP_DIR" -type f -name "*.bcsymbolmap" 2>/dev/null)"
  fi
  
  if [[ $bcsymbolmap_count -eq 0 ]]; then
    echo "==> No BCSymbolMaps found in $IOS_BCSYMBOLMAP_DIR"
  else
    echo "==> Added $bcsymbolmap_count BCSymbolMaps"
  fi
fi

# Simulator slice
args+=( -framework "$SIM_FRAMEWORK" )
if [[ "$SKIP_DSYMS" != "true" && -d "$SIM_DSYM" ]]; then
  echo "==> Checking iOS Simulator dSYM: $SIM_DSYM"
  
  # Extract just the framework name without .framework extension for DWARF file
  BARE_NAME="${FRAMEWORK_NAME%.framework}"
  
  # Check for valid dSYM structure
  DWARF_FILE1="$SIM_DSYM/Contents/Resources/DWARF/$FRAMEWORK_NAME"
  DWARF_FILE2="$SIM_DSYM/Contents/Resources/DWARF/$BARE_NAME"
  
  echo "==> Looking for DWARF files:"
  echo "    $DWARF_FILE1"
  echo "    $DWARF_FILE2"
  
  # Check if DWARF files exist and are not empty
  DWARF_VALID=false
  if [[ -f "$DWARF_FILE1" && -s "$DWARF_FILE1" ]]; then
    echo "==> Found non-empty DWARF file: $DWARF_FILE1"
    # Additional check: use file command to verify it's a valid DWARF file
    if command -v file >/dev/null 2>&1; then
      FILE_TYPE=$(file "$DWARF_FILE1" 2>/dev/null || echo "unknown")
      echo "==> DWARF file type: $FILE_TYPE"
      if [[ "$FILE_TYPE" == *"dSYM"* ]] || [[ "$FILE_TYPE" == *"DWARF"* ]] || [[ "$FILE_TYPE" == *"Mach-O"* ]]; then
        DWARF_VALID=true
      fi
    else
      # If file command not available, assume valid if non-empty
      DWARF_VALID=true
    fi
  elif [[ -f "$DWARF_FILE2" && -s "$DWARF_FILE2" ]]; then
    echo "==> Found non-empty DWARF file: $DWARF_FILE2"
    if command -v file >/dev/null 2>&1; then
      FILE_TYPE=$(file "$DWARF_FILE2" 2>/dev/null || echo "unknown")
      echo "==> DWARF file type: $FILE_TYPE"
      if [[ "$FILE_TYPE" == *"dSYM"* ]] || [[ "$FILE_TYPE" == *"DWARF"* ]] || [[ "$FILE_TYPE" == *"Mach-O"* ]]; then
        DWARF_VALID=true
      fi
    else
      DWARF_VALID=true
    fi
  fi
  
  if [[ "$DWARF_VALID" == "true" ]]; then
    echo "==> Valid dSYM found, adding to XCFramework"
    # Convert to absolute path to avoid xcodebuild path issues
    ABS_SIM_DSYM=$(cd "$(dirname "$SIM_DSYM")" && pwd)/$(basename "$SIM_DSYM")
    args+=( -debug-symbols "$ABS_SIM_DSYM" )
  else
    echo "==> Warning: iOS Simulator dSYM appears invalid or empty, skipping"
    echo "==> dSYM structure:"
    find "$SIM_DSYM" -type f 2>/dev/null | head -10 || echo "No files found in dSYM"
    if [[ -f "$DWARF_FILE1" ]]; then
      echo "==> DWARF file size: $(ls -lh "$DWARF_FILE1" | awk '{print $5}')"
    fi
    if [[ -f "$DWARF_FILE2" ]]; then
      echo "==> DWARF file size: $(ls -lh "$DWARF_FILE2" | awk '{print $5}')"
    fi
  fi
elif [[ "$SKIP_DSYMS" == "true" ]]; then
  echo "==> Skipping iOS Simulator dSYM (SKIP_DSYMS=true)"
else
  echo "==> No iOS Simulator dSYM found at: $SIM_DSYM"
fi

args+=( -output "$OUT_XCFRAMEWORK" )

echo "==> Running xcodebuild -create-xcframework..."
if [[ "$VERBOSE" == "true" ]]; then
  xcodebuild "${args[@]}"
else
  xcodebuild "${args[@]}" || { echo "error: XCFramework creation failed"; exit 1; }
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