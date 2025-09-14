#!/bin/bash

# Capture errors when enabling extension using multiple methods
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"

echo "=== Capturing Extension Enable Errors ==="
echo

# Method 1: Direct command with error capture
echo "1. Trying to enable extension with error capture..."
echo "Command: gnome-extensions enable $EXT_UUID"
echo "Output:"

# Capture both stdout and stderr
if output=$(gnome-extensions enable "$EXT_UUID" 2>&1); then
    echo "   SUCCESS: $output"
else
    echo "   ERROR: $output"
fi

echo
echo "2. Checking extension state:"
gnome-extensions info "$EXT_UUID" | grep -E "State:|Enabled:|Error:"

echo
echo "3. Trying to get more detailed info..."
# Try to get more info from gnome-extensions
if command -v gnome-extensions-app >/dev/null 2>&1; then
    echo "   gnome-extensions-app is available"
else
    echo "   gnome-extensions-app not available"
fi

echo
echo "4. Check if extension files are accessible..."
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"
if [[ -r "$EXT_DIR/extension.js" ]]; then
    echo "   ✓ extension.js is readable"
else
    echo "   ✗ extension.js is not readable"
fi

echo
echo "5. Test JavaScript syntax with gjs (if available)..."
if command -v gjs >/dev/null 2>&1; then
    echo "   Testing extension.js syntax..."
    if gjs -c "$EXT_DIR/extension.js" 2>&1; then
        echo "   ✓ No syntax errors found"
    else
        echo "   ✗ Syntax errors detected"
    fi
else
    echo "   gjs not available for syntax testing"
fi

echo
echo "6. Environment information:"
echo "   XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-not set}"
echo "   DISPLAY: ${DISPLAY:-not set}"
echo "   WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-not set}"
echo "   User: $(whoami)"
echo "   Shell: $0"

echo
echo "7. Alternative enable methods to try:"
echo
echo "   Method A: Using Looking Glass (most reliable)"
echo "   - Press Alt+F2, type 'lg', press Enter"
echo "   - Go to Extensions tab"
echo "   - Find breakcorn-radio@breakcorny@gmail.com"
echo "   - Check for error messages"
echo
echo "   Method B: GNOME Extensions App"
echo "   - Open 'Extensions' app from Activities"
echo "   - Find Breakcorn Radio"
echo "   - Try to enable it there"
echo "   - Look for error tooltips/messages"
echo
echo "   Method C: Restart GNOME Shell first"
echo "   - Press Alt+F2, type 'r', press Enter"
echo "   - Wait for shell to restart"
echo "   - Then try: gnome-extensions enable $EXT_UUID"
echo
echo "   Method D: Check system logs manually"
echo "   - journalctl --user -f (in one terminal)"
echo "   - gnome-extensions enable $EXT_UUID (in another)"
echo "   - Look for error messages"
