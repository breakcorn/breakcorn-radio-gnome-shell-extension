#!/bin/bash

# Check for common GNOME Shell extension issues
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

echo "=== GNOME Shell Extension Issues Checker ==="
echo

# Check 1: File permissions
echo "1. Checking file permissions:"
if [[ -d "$EXT_DIR" ]]; then
    ls -la "$EXT_DIR" | head -5
    
    # Check if files are readable
    if [[ -r "$EXT_DIR/extension.js" ]]; then
        echo "   ✓ extension.js is readable"
    else
        echo "   ✗ extension.js is not readable"
    fi
    
    if [[ -r "$EXT_DIR/metadata.json" ]]; then
        echo "   ✓ metadata.json is readable"
    else
        echo "   ✗ metadata.json is not readable"
    fi
else
    echo "   ✗ Extension directory not found"
    exit 1
fi

echo

# Check 2: UUID conflicts
echo "2. Checking for UUID conflicts:"
echo "   Looking for other extensions with similar UUIDs..."
find "$HOME/.local/share/gnome-shell/extensions" -maxdepth 1 -type d -name "*breakcorn*" -o -name "*radio*" 2>/dev/null

echo "   All installed extensions:"
gnome-extensions list | sort

echo

# Check 3: GNOME Shell extension system status
echo "3. Checking GNOME Shell extension system:"
echo "   GNOME Shell version: $(gnome-shell --version)"
echo "   Session type: ${XDG_SESSION_TYPE:-not set}"
echo "   Extensions enabled: $(gsettings get org.gnome.shell disable-user-extensions 2>/dev/null || echo 'unknown')"

echo

# Check 4: Extension directory structure
echo "4. Extension directory structure:"
tree "$EXT_DIR" 2>/dev/null || find "$EXT_DIR" -type f | sort

echo

# Check 5: Metadata validation
echo "5. Metadata validation:"
if [[ -f "$EXT_DIR/metadata.json" ]]; then
    echo "   Checking JSON syntax:"
    if python3 -m json.tool "$EXT_DIR/metadata.json" >/dev/null 2>&1; then
        echo "   ✓ metadata.json has valid JSON syntax"
        
        echo "   Checking required fields:"
        uuid=$(python3 -c "import json; print(json.load(open('$EXT_DIR/metadata.json')).get('uuid', ''))" 2>/dev/null)
        if [[ "$uuid" == "$EXT_UUID" ]]; then
            echo "   ✓ UUID matches: $uuid"
        else
            echo "   ✗ UUID mismatch. Expected: $EXT_UUID, Found: $uuid"
        fi
    else
        echo "   ✗ metadata.json has invalid JSON syntax"
        echo "   Error:"
        python3 -m json.tool "$EXT_DIR/metadata.json" 2>&1 | head -5 | sed 's/^/     /'
    fi
fi

echo

# Check 6: Other extensions status
echo "6. Other extensions status (to check if extension system works):"
echo "   Enabled extensions:"
gnome-extensions list --enabled | head -5
echo "   Disabled extensions:"
gnome-extensions list --disabled | head -5

echo

# Check 7: GNOME Shell restart suggestion
echo "7. GNOME Shell restart test:"
echo "   Current uptime: $(uptime -p)"
echo "   If GNOME Shell has been running for a long time, restart might help:"
echo "   - X11: Alt+F2 → 'r' → Enter"
echo "   - Wayland: logout and login"

echo

# Check 8: System resources
echo "8. System resources:"
echo "   Memory usage:"
   free -h | head -2
echo "   Disk space (home directory):"
   df -h "$HOME" | tail -1

echo

# Check 9: Looking Glass recommendations
echo "9. Looking Glass debugging commands:"
echo "   Open Looking Glass: Alt+F2 → lg → Enter"
echo "   In Evaluator tab, try these commands:"
echo
echo "   // Check if extension is loaded"
echo "   Main.extensionManager.lookup('$EXT_UUID')"
echo
echo "   // Get extension state"
echo "   let ext = Main.extensionManager.lookup('$EXT_UUID')"
echo "   ext.state"
echo
echo "   // Check for errors"
echo "   ext.error"
echo
echo "   // Try manual enable"
echo "   Main.extensionManager.enableExtension('$EXT_UUID')"
echo
echo "   // Reload all extensions"
echo "   Main.extensionManager.reloadExtensions()"

echo
echo "=== Summary ==="
echo "This checker helps identify common extension issues."
echo "Most important next steps:"
echo "1. Use Looking Glass debugging commands above"
echo "2. Try GNOME Shell restart if not done recently"
echo "3. Check if other extensions can be enabled/disabled normally"
echo "4. Verify the ultra minimal extension test: ./test-ultra-minimal.sh"
