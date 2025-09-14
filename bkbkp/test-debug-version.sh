#!/bin/bash

# Test extension with debug version (no GStreamer)
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

echo "=== Testing Debug Version (No GStreamer) ==="
echo

if [[ ! -d "$EXT_DIR" ]]; then
    echo "Extension not installed. Run ./simple-install.sh first."
    exit 1
fi

# Backup original extension.js
echo "1. Backing up original extension.js..."
cp "$EXT_DIR/extension.js" "$EXT_DIR/extension.js.backup"

# Copy debug version
echo "2. Installing debug version..."
cp "breakcorn-radio@breakcorny@gmail.com/extension-debug.js" "$EXT_DIR/extension.js"

# Disable extension first
echo "3. Disabling extension..."
gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
sleep 1

# Try to enable debug version
echo "4. Enabling debug version..."
if gnome-extensions enable "$EXT_UUID"; then
    echo "   ✓ Debug version enabled successfully!"
    echo "   Look for an audio icon in the top panel"
    echo
    echo "If you see the icon, the problem is with GStreamer initialization."
    echo "If you don't see the icon, there's a deeper GNOME Shell integration issue."
else
    echo "   ✗ Debug version also failed to enable"
    echo "   This indicates a fundamental problem with extension loading"
fi

echo
echo "5. Current extension status:"
gnome-extensions info "$EXT_UUID" | grep -E "State:|Enabled:"

echo
read -p "Test complete. Restore original extension? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Restoring original extension.js..."
    mv "$EXT_DIR/extension.js.backup" "$EXT_DIR/extension.js"
    echo "Original extension restored."
else
    echo "Debug version kept. To restore manually:"
    echo "  mv '$EXT_DIR/extension.js.backup' '$EXT_DIR/extension.js'"
fi
