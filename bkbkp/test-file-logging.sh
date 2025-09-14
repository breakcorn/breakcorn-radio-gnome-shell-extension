#!/bin/bash

# Test extension with file logging to capture all debug info
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"
LOG_FILE="$HOME/.breakcorn-radio-debug.log"

echo "=== Testing Extension with File Logging ==="
echo

if [[ ! -d "$EXT_DIR" ]]; then
    echo "Extension not installed. Run ./simple-install.sh first."
    exit 1
fi

# Backup original extension.js if not already backed up
if [[ ! -f "$EXT_DIR/extension.js.original" ]]; then
    echo "1. Creating backup of original extension.js..."
    cp "$EXT_DIR/extension.js" "$EXT_DIR/extension.js.original"
fi

# Remove old log file
echo "2. Clearing old debug log..."
rm -f "$LOG_FILE"

# Copy file logging version
echo "3. Installing file logging version..."
cp "breakcorn-radio@breakcorny@gmail.com/extension-file-logging.js" "$EXT_DIR/extension.js"

# Disable extension first
echo "4. Disabling extension..."
gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
sleep 2

echo "5. Enabling file logging version..."
echo "   This version will log everything to: $LOG_FILE"
echo

# Try to enable
if gnome-extensions enable "$EXT_UUID" 2>&1; then
    echo "   Enable command completed"
else
    echo "   Enable command returned error code: $?"
fi

sleep 3

echo
echo "6. Checking extension status:"
gnome-extensions info "$EXT_UUID" | grep -E "Enabled:|State:"

echo
echo "7. Debug log contents:"
if [[ -f "$LOG_FILE" ]]; then
    echo "   Log file found: $LOG_FILE"
    echo "   Contents:"
    echo "   ----------------------------------------"
    cat "$LOG_FILE" | sed 's/^/   /'
    echo "   ----------------------------------------"
else
    echo "   ⚠ No log file created: $LOG_FILE"
    echo "   This means the extension didn't start at all"
fi

echo
echo "8. System information:"
echo "   GNOME Shell: $(gnome-shell --version 2>/dev/null || echo 'Not available')"
echo "   Session: ${XDG_SESSION_TYPE:-Unknown}"
echo "   User: $(whoami)"

echo
echo "9. Testing disable..."
gnome-extensions disable "$EXT_UUID"
sleep 2

echo "   Log after disable:"
if [[ -f "$LOG_FILE" ]]; then
    echo "   ----------------------------------------"
    tail -10 "$LOG_FILE" | sed 's/^/   /'
    echo "   ----------------------------------------"
fi

echo
read -p "Test complete. Restore original extension? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Restoring original extension.js..."
    mv "$EXT_DIR/extension.js.original" "$EXT_DIR/extension.js"
    echo "Original extension restored."
else
    echo "File logging version kept. To restore manually:"
    echo "  mv '$EXT_DIR/extension.js.original' '$EXT_DIR/extension.js'"
fi

echo
echo "=== File Logging Test Results ==="
if [[ -f "$LOG_FILE" ]]; then
    echo "Debug log created successfully at: $LOG_FILE"
    echo "You can examine it anytime with: cat $LOG_FILE"
else
    echo "No debug log was created."
    echo "This indicates the extension failed to load completely."
    echo "Possible causes:"
    echo "- JavaScript syntax error"
    echo "- Missing GNOME Shell APIs"
    echo "- Permission issues"
fi
