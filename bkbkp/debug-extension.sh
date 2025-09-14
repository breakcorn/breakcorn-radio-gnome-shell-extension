#!/bin/bash

# Breakcorn Radio Extension Debug Script
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"

echo "=== Breakcorn Radio Extension Debug Information ==="
echo

# Check current status
echo "1. Current extension status:"
if command -v gnome-extensions >/dev/null 2>&1; then
    echo "   Installed extensions:"
    gnome-extensions list | grep -E "breakcorn|$EXT_UUID" || echo "   - Extension not found in list"
    
    echo "   Enabled extensions:"
    gnome-extensions list --enabled | grep -E "breakcorn|$EXT_UUID" || echo "   - Extension not enabled"
    
    echo "   Disabled extensions:"
    gnome-extensions list --disabled | grep -E "breakcorn|$EXT_UUID" || echo "   - Extension not in disabled list"
else
    echo "   gnome-extensions command not available"
fi

echo
echo "2. Force enable attempt:"
echo "   Running: gnome-extensions enable $EXT_UUID"
gnome-extensions enable "$EXT_UUID" 2>&1 || echo "   Enable command failed"

echo
echo "3. Check extension info:"
gnome-extensions info "$EXT_UUID" 2>&1 || echo "   Could not get extension info"

echo
echo "4. Recent GNOME Shell logs (last 50 lines):"
echo "   Looking for extension-related errors..."
journalctl --user -u gnome-shell --since="10 minutes ago" --no-pager | tail -50 | grep -E "breakcorn|extension|ERROR|error" || echo "   No recent extension errors found"

echo
echo "5. Extension files check:"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"
if [[ -d "$EXT_DIR" ]]; then
    echo "   Directory: $EXT_DIR"
    echo "   Files:"
    ls -la "$EXT_DIR"
    
    echo "   Checking metadata.json:"
    if [[ -f "$EXT_DIR/metadata.json" ]]; then
        cat "$EXT_DIR/metadata.json" 2>/dev/null || echo "   Error reading metadata.json"
    else
        echo "   metadata.json not found!"
    fi
    
    echo "   Checking extension.js syntax:"
    if command -v node >/dev/null 2>&1; then
        node -c "$EXT_DIR/extension.js" 2>&1 && echo "   Syntax OK" || echo "   Syntax errors found"
    else
        echo "   Node.js not available for syntax check"
    fi
else
    echo "   Extension directory not found: $EXT_DIR"
fi

echo
echo "6. GNOME Shell version and session info:"
echo "   GNOME Shell: $(gnome-shell --version 2>/dev/null || echo 'Not available')"
echo "   Session type: ${XDG_SESSION_TYPE:-Unknown}"
echo "   Desktop: ${XDG_CURRENT_DESKTOP:-Unknown}"

echo
echo "7. Manual activation test:"
echo "   Try disabling and re-enabling:"
gnome-extensions disable "$EXT_UUID" 2>&1 || echo "   Disable failed"
sleep 1
gnome-extensions enable "$EXT_UUID" 2>&1 || echo "   Enable failed"

echo
echo "=== Debug Complete ==="
echo "If the extension still doesn't work after this debug:"
echo "1. Try restarting GNOME Shell (Alt+F2 → 'r' on X11, or logout/login on Wayland)"
echo "2. Check if there are JavaScript errors in the extension code"
echo "3. Make sure all required dependencies are installed (GStreamer, etc.)"
echo "4. Check GNOME Extensions app for any additional error messages"
