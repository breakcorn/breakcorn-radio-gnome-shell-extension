#!/bin/bash

# Test extension activation with detailed logging
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"

echo "=== Testing Extension Activation ==="
echo

# Check current state
echo "1. Current state:"
gnome-extensions info "$EXT_UUID" | grep -E "State:|Enabled:"

# Try to enable with verbose output
echo
echo "2. Attempting to enable extension with verbose logging..."
echo "   Running: gnome-extensions enable $EXT_UUID"

# Capture any output/errors
if gnome-extensions enable "$EXT_UUID" 2>&1; then
    echo "   Enable command completed"
else
    echo "   Enable command failed with exit code $?"
fi

# Check state after enable attempt
echo
echo "3. State after enable attempt:"
gnome-extensions info "$EXT_UUID" | grep -E "State:|Enabled:"

# List all enabled extensions
echo
echo "4. Currently enabled extensions:"
gnome-extensions list --enabled

# Check if our extension is in the list
echo
echo "5. Is our extension enabled?"
if gnome-extensions list --enabled | grep -q "$EXT_UUID"; then
    echo "   ✓ YES - Extension is in enabled list"
    echo "   Extension should be visible in the top panel"
else
    echo "   ✗ NO - Extension is not in enabled list"
    echo "   This indicates an activation error"
fi

# Try the more detailed gnome-extensions show command if available
echo
echo "6. Detailed extension information:"
gnome-extensions show "$EXT_UUID" 2>/dev/null || echo "   show command not available"

echo
echo "=== Activation Test Complete ==="
echo "If the extension shows as enabled but isn't visible:"
echo "- Press Alt+F2, type 'r', press Enter to restart GNOME Shell"
echo "- Look for the radio icon in the top-right area of the panel"
echo "- Check if the icon is hidden in the system tray overflow"
echo
echo "If the extension won't enable at all:"
echo "- There's likely a JavaScript error in the extension code"
echo "- Check: dbus-monitor --session | grep -i extension"
echo "- Or try: journalctl --user --since='1 minute ago' | grep -i extension"
