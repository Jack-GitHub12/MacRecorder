#!/bin/bash

# Build script for MacroRecorder
# This script builds the MacroRecorder application using Xcode command line tools

set -e

echo "Building MacroRecorder..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode command line tools not found"
    echo "Please install Xcode from the App Store or run: xcode-select --install"
    exit 1
fi

# Build the project
xcodebuild \
    -project MacroRecorder.xcodeproj \
    -scheme MacroRecorder \
    -configuration Release \
    -derivedDataPath ./build \
    build

echo "Build completed successfully!"
echo "Application location: ./build/Build/Products/Release/MacroRecorder.app"
echo ""
echo "To run the application:"
echo "  open ./build/Build/Products/Release/MacroRecorder.app"
