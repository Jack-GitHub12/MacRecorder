# MacroRecorder Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-10-29

### Features
- **Core Recording & Playback**
  - Mouse clicks (left/right down/up) recording and playback
  - Mouse movements and drag operations
  - Keyboard key presses with modifier keys support
  - Scroll wheel events capture
  - Precise position and timing tracking
  - Configurable mouse movement threshold

- **Playback Modes**
  - Variable speed playback (0.1x to 5x)
  - Three playback modes: Once, Loop N times, Infinite loop
  - Async playback with real-time progress indicator
  - Stop/cancel functionality with global hotkeys

- **Event Management**
  - Edit event delays and positions
  - Insert new events manually
  - Delete individual events
  - Drag-and-drop event reordering
  - Manual event creation for custom macros

- **User Interface**
  - Split view with macro library sidebar
  - Real-time event list with color-coding
  - Timeline visualization for event sequences
  - Status bar with live updates
  - Comprehensive preferences window with 4 tabs
  - Global hotkeys (⌘⇧/, ⌘⇧P)

- **System Integration**
  - Global hotkeys work without app focus
  - Accessibility permissions management
  - Menu bar integration
  - JSON import/export for macro sharing
  - UserDefaults persistence for settings

### Bug Fixes
- Fixed hotkey filtering issue for proper keyboard event handling
- Resolved event reordering implementation issues
- Fixed dynamic hotkey updates not applying immediately
- Corrected manual event creation validation

### Technical Details
- Built with Swift 5.9+ and SwiftUI
- Native macOS application for macOS 12.0+
- Universal Binary supporting Intel and Apple Silicon
- Uses Core Graphics CGEvent API for recording
- Carbon Events API for global hotkey management

### Distribution
- Available as DMG installer (MacroRecorder-v1.0.dmg)
- Signed for local execution
- No network access required
- No telemetry or tracking

## Installation
1. Download MacroRecorder-v1.0.dmg
2. Mount the DMG and drag MacroRecorder.app to Applications
3. Grant accessibility permissions when prompted on first launch

## Known Issues
- None reported

---
For detailed documentation, see README.md and QUICKSTART.md