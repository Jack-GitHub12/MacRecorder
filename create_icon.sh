#!/bin/bash

# Create icon for MacroRecorder
# This script generates an app icon using SF Symbols

ICON_DIR="MacroRecorder.iconset"
APP_ICON="AppIcon.icns"

# Create iconset directory
mkdir -p "$ICON_DIR"

# Create a simple icon using sips and SF Symbols
# We'll use a record.circle symbol as the base

# Generate different sizes
for size in 16 32 64 128 256 512 1024; do
    half_size=$((size / 2))

    # Create a simple red circle icon
    # Using Python with PIL to create the icon
    python3 - <<EOF
from PIL import Image, ImageDraw
import sys

size = $size
img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw outer circle (red)
margin = size // 10
draw.ellipse([margin, margin, size-margin, size-margin], fill=(220, 38, 38, 255), outline=(180, 20, 20, 255), width=max(1, size//64))

# Draw inner circle (darker red for record button effect)
inner_margin = size // 4
draw.ellipse([inner_margin, inner_margin, size-inner_margin, size-inner_margin], fill=(200, 30, 30, 255))

# Save the icon
if size <= 256:
    if size <= 128:
        if size <= 32:
            if size == 16:
                img.save('$ICON_DIR/icon_16x16.png')
            else:
                img.save('$ICON_DIR/icon_16x16@2x.png')
        else:
            if size == 64:
                img.save('$ICON_DIR/icon_32x32@2x.png')
            else:
                img.save('$ICON_DIR/icon_64x64@2x.png')
    else:
        if size == 128:
            img.save('$ICON_DIR/icon_128x128.png')
        else:
            img.save('$ICON_DIR/icon_128x128@2x.png')
else:
    if size == 256:
        img.save('$ICON_DIR/icon_256x256.png')
    elif size == 512:
        img.save('$ICON_DIR/icon_256x256@2x.png')
        img.save('$ICON_DIR/icon_512x512.png')
    else:
        img.save('$ICON_DIR/icon_512x512@2x.png')

EOF
done

# Create special sizes
sips -z 32 32 "$ICON_DIR/icon_16x16@2x.png" --out "$ICON_DIR/icon_32x32.png" 2>/dev/null || cp "$ICON_DIR/icon_16x16@2x.png" "$ICON_DIR/icon_32x32.png"
sips -z 64 64 "$ICON_DIR/icon_32x32@2x.png" --out "$ICON_DIR/icon_64x64.png" 2>/dev/null || cp "$ICON_DIR/icon_32x32@2x.png" "$ICON_DIR/icon_64x64.png"

# Convert iconset to icns
iconutil -c icns "$ICON_DIR" -o "$APP_ICON"

# Copy to app bundle
if [ -d "MacroRecorder.app/Contents/Resources" ]; then
    cp "$APP_ICON" "MacroRecorder.app/Contents/Resources/"
    echo "✅ Icon created and installed: $APP_ICON"
else
    echo "⚠️  App bundle not found. Icon created but not installed."
fi

# Clean up
rm -rf "$ICON_DIR"

echo "🎨 Icon generation complete!"
