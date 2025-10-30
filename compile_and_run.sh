#!/bin/bash

# Direct compilation script for MacroRecorder
# This script compiles all Swift files and creates a runnable .app bundle

set -e

echo "🔨 Compiling MacroRecorder..."

# Create app bundle structure
APP_NAME="MacroRecorder"
APP_BUNDLE="$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# Clean previous build
rm -rf "$APP_BUNDLE"

# Create bundle directories
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Compile all Swift files
echo "Compiling Swift sources..."
swiftc \
    -target arm64-apple-macosx13.0 \
    -parse-as-library \
    -emit-executable \
    -o "$MACOS/$APP_NAME" \
    -module-name MacroRecorder \
    -import-objc-header <(echo "") \
    MacroRecorder/MacroRecorderApp.swift \
    MacroRecorder/Models/MacroEvent.swift \
    MacroRecorder/Services/EventRecorder.swift \
    MacroRecorder/Services/EventPlayer.swift \
    MacroRecorder/Services/MacroSession.swift \
    MacroRecorder/Services/HotkeyManager.swift \
    MacroRecorder/Views/ContentView.swift \
    MacroRecorder/Views/ControlsView.swift \
    MacroRecorder/Views/EventListView.swift \
    MacroRecorder/Views/EventEditorView.swift \
    MacroRecorder/Views/MacroListView.swift \
    MacroRecorder/Views/StatusBarView.swift \
    MacroRecorder/Views/PreferencesView.swift \
    MacroRecorder/Views/KeybindCaptureView.swift \
    -framework SwiftUI \
    -framework Foundation \
    -framework AppKit \
    -framework CoreGraphics \
    -framework Carbon

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful!"

    # Copy Info.plist
    cp MacroRecorder/Info.plist "$CONTENTS/"

    # Create PkgInfo
    echo "APPL????" > "$CONTENTS/PkgInfo"

    echo "📦 App bundle created at: $APP_BUNDLE"
    echo "🚀 Launching MacroRecorder..."

    # Launch the app
    open "$APP_BUNDLE"

    echo ""
    echo "✨ MacroRecorder is now running!"
    echo ""
    echo "Note: You'll need to grant Accessibility permissions on first launch."
    echo "Go to: System Preferences → Security & Privacy → Privacy → Accessibility"
else
    echo "❌ Compilation failed"
    exit 1
fi
