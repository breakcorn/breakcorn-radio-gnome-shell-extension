#!/bin/bash

# Test with absolutely minimal extension (just notification)
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

echo "=== Testing Minimal Extension (Notification Only) ==="
echo

if [[ ! -d "$EXT_DIR" ]]; then
    echo "Extension not installed. Run ./simple-install.sh first."
    exit 1
fi

# Backup original extension.js if not already backed up
if [[ ! -f "$EXT_DIR/extension.js.backup" ]]; then
    echo "1. Creating backup of original extension.js..."
    cp "$EXT_DIR/extension.js" "$EXT_DIR/extension.js.backup"
fi

# Copy minimal version
echo "2. Installing minimal test version..."
cp "breakcorn-radio@breakcorny@gmail.com/extension-minimal.js" "$EXT_DIR/extension.js"

# Disable extension first
echo "3. Disabling extension..."
gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
sleep 2

# Try to enable minimal version
echo "4. Enabling minimal version..."
echo "   Look for a notification that says 'Extension loaded successfully!'"
echo

if gnome-extensions enable "$EXT_UUID"; then
    echo "   Enable command completed"
    sleep 2
    
    echo "5. Checking status after enable:"
    gnome-extensions info "$EXT_UUID" | grep -E "Enabled:|State:"
    
    if gnome-extensions list --enabled | grep -q "$EXT_UUID"; then
        echo "   ✓ SUCCESS: Extension is now ENABLED!"
        echo "   This means GNOME Shell integration works fine."
        echo "   The problem is with the complex extension code (likely GStreamer)."
    else
        echo "   ✗ FAILED: Even minimal extension won't enable"
        echo "   This indicates a fundamental GNOME Shell compatibility issue."
    fi
else
    echo "   ✗ Enable command failed"
fi

echo
echo "6. Testing disable functionality:"
gnome-extensions disable "$EXT_UUID"
echo "   Disable command completed"

echo
read -p "Test complete. Restore original extension? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Restoring original extension.js..."
    mv "$EXT_DIR/extension.js.backup" "$EXT_DIR/extension.js"
    echo "Original extension restored."
else
    echo "Minimal version kept. To restore manually:"
    echo "  mv '$EXT_DIR/extension.js.backup' '$EXT_DIR/extension.js'"
fi

echo
echo "=== Test Results Summary ==="
echo "If you saw the notification and extension showed as ENABLED:"
echo "  → GNOME Shell integration works"
echo "  → Problem is in the main extension code"
echo "  → Likely GStreamer initialization failure"
echo
echo "If no notification appeared or extension stayed DISABLED:"
echo "  → Fundamental GNOME Shell compatibility issue"
echo "  → Check GNOME Shell version: $(gnome-shell --version)"
echo "  → Try restarting GNOME Shell: Alt+F2 → 'r' → Enter"
