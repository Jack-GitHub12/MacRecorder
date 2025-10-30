# Quick Start Guide

## Building the Project

### Option 1: Using Xcode (Recommended)

1. Open the project:
   ```bash
   open MacroRecorder.xcodeproj
   ```

2. In Xcode:
   - Select the MacroRecorder scheme
   - Choose your Mac as the destination
   - Press `⌘R` to build and run

### Option 2: Using Command Line

1. Run the build script:
   ```bash
   ./build.sh
   ```

2. Launch the app:
   ```bash
   open ./build/Build/Products/Release/MacroRecorder.app
   ```

### Option 3: Using Swift Package Manager

```bash
swift build -c release
```

## First Run

1. When you first launch MacroRecorder, it will request **Accessibility Permissions**
2. Click "Open System Preferences"
3. Navigate to: **System Preferences → Security & Privacy → Privacy → Accessibility**
4. Check the box next to **MacroRecorder**
5. Restart the application

## Basic Usage

### Recording Your First Macro

1. Click **"Start Recording"** or press `⌘⇧/`
2. Perform the actions you want to record:
   - Click buttons
   - Type text
   - Move the mouse
   - Scroll
3. Click **"Stop Recording"** or press `⌘⇧/` again
4. Click **"Save Macro"** or press `⌘S`
5. Give your macro a name

### Playing Back a Macro

1. Select a saved macro from the sidebar
2. (Optional) Adjust settings:
   - **Playback Speed**: Use the slider (0.1x - 5.0x)
   - **Playback Mode**: Choose Once, Loop, or Infinite
3. Click **"Play Macro"** or press `⌘⇧P`

### Editing Events

1. Double-click an event in the list, or
2. Right-click and select "Edit"
3. Modify:
   - **Delay**: Time before this event executes
   - **Position**: X, Y coordinates for mouse events
4. Click "Save"

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Start/Stop Recording | `⌘⇧/` |
| Play/Stop Playback | `⌘⇧P` |
| Save Macro | `⌘S` |
| Preferences | `⌘,` |

## Tips

- **Reduce Macro Size**: Increase the mouse move threshold in Preferences
- **Precise Timing**: Edit event delays for exact timing control
- **Loop Testing**: Use Loop mode with count 2-3 to test macros
- **Export Macros**: Right-click any macro to export as JSON
- **Stop Playback**: Press `⌘⇧P` again during playback to stop

## Troubleshooting

**Recording doesn't work?**
- Check Accessibility permissions
- Restart the application

**Playback is too fast/slow?**
- Adjust the playback speed slider
- Or edit individual event delays

**Hotkeys not working?**
- Check for conflicting shortcuts in other apps
- Make sure MacroRecorder is running

## Project Structure

```
MacroRecorder/
├── MacroRecorder/
│   ├── Models/              # Data models
│   ├── Services/            # Core functionality
│   ├── Views/               # SwiftUI views
│   └── Resources/           # Assets
├── MacroRecorder.xcodeproj/ # Xcode project
├── Package.swift            # Swift Package Manager
├── README.md                # Full documentation
├── QUICKSTART.md           # This file
└── build.sh                # Build script
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Explore the Preferences to customize behavior
- Try exporting and sharing macros with others
- Check out the timeline visualization while recording

## Need Help?

- Check the full README for detailed information
- Review the code - it's fully documented
- Open an issue on GitHub

---

Happy automating!
