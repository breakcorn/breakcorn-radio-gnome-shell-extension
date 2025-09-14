#!/bin/bash

# Test with absolutely minimal extension (no UI, no dependencies)
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

echo "=== Testing Ultra Minimal Extension ==="
echo

if [[ ! -d "$EXT_DIR" ]]; then
    echo "Extension not installed. Run ./simple-install.sh first."
    exit 1
fi

# Backup original if not done
if [[ ! -f "$EXT_DIR/extension.js.minimal-backup" ]]; then
    cp "$EXT_DIR/extension.js" "$EXT_DIR/extension.js.minimal-backup"
fi

echo "1. Installing ultra minimal version (console.log only)..."
cp "breakcorn-radio@breakcorny@gmail.com/extension-ultra-minimal.js" "$EXT_DIR/extension.js"

echo "2. Disabling extension..."
gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
sleep 2

echo "3. Enabling ultra minimal version..."
echo "   This version only does console.log - no UI, no dependencies"
echo

# Check before enable
echo "   Status before enable:"
   gnome-extensions info "$EXT_UUID" | grep -E "Enabled:|State:"

# Try to enable
if gnome-extensions enable "$EXT_UUID" 2>&1; then
    echo "   Enable command completed"
else
    echo "   Enable command failed with code: $?"
fi

sleep 3

echo "4. Status after enable:"
gnome-extensions info "$EXT_UUID" | grep -E "Enabled:|State:"

echo "5. Checking if enabled in list:"
if gnome-extensions list --enabled | grep -q "$EXT_UUID"; then
    echo "   ✓ SUCCESS: Extension is ENABLED!"
    echo "   The issue is with UI creation, not basic extension loading"
else
    echo "   ✗ FAILED: Even ultra minimal extension won't enable"
    echo "   This indicates a fundamental GNOME Shell issue"
fi

echo
echo "6. Looking Glass check:"
echo "   Please check Looking Glass (Alt+F2 → lg) Extensions tab:"
echo "   - Is the extension state changed?"
echo "   - Are there any new error messages?"
echo "   - Does the state show as ENABLED or still INITIALIZED?"

echo
echo "7. Console message test:"
echo "   The ultra minimal version should output console messages."
echo "   In Looking Glass, go to Evaluator tab and run:"
echo "   > Main.extensionManager.lookup('breakcorn-radio@breakcorny@gmail.com')"
echo "   Check the result and any error messages."

echo
read -p "Press Enter after checking Looking Glass, then we'll test disable..."

echo "8. Testing disable..."
gnome-extensions disable "$EXT_UUID"
sleep 2

echo "   Status after disable:"
gnome-extensions info "$EXT_UUID" | grep -E "Enabled:|State:"

echo
read -p "Test complete. Restore original extension? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Restoring original extension.js..."
    mv "$EXT_DIR/extension.js.minimal-backup" "$EXT_DIR/extension.js"
    echo "Original extension restored."
else
    echo "Ultra minimal version kept. To restore manually:"
    echo "  mv '$EXT_DIR/extension.js.minimal-backup' '$EXT_DIR/extension.js'"
fi

echo
echo "=== Ultra Minimal Test Results ==="
echo "If this version showed as ENABLED:"
echo "  → Basic extension mechanism works"
echo "  → Problem is with UI creation (St.Icon, PanelMenu, etc.)"
echo "  → Check for missing GTK/UI libraries"
echo
echo "If this version still shows INITIALIZED:"
echo "  → GNOME Shell has a fundamental issue with this extension"
echo "  → Possible causes:"
echo "    - Extension UUID conflicts"
echo "    - GNOME Shell extension system problems"
echo "    - File permissions issues"
echo "    - GNOME Shell needs restart"
echo
echo "Next steps:"
echo "1. Check Looking Glass for detailed error information"
echo "2. Try restarting GNOME Shell: Alt+F2 → 'r' → Enter"
echo "3. Check if other extensions work normally"
echo "4. Verify extension directory permissions"
