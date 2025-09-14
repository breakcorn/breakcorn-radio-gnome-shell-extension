#!/bin/bash

# Check various log sources for GNOME Shell extension messages
# License: GPL v3

echo "=== Checking Console Logs for Extension Messages ==="
echo

# Check common log locations
log_locations=(
    "$HOME/.xsession-errors"
    "$HOME/.cache/gnome-shell/logs"
    "/var/log/Xorg.0.log"
    "/var/log/gdm3/greeter.log"
)

echo "1. Checking common log files:"
for log in "${log_locations[@]}"; do
    if [[ -f "$log" ]]; then
        echo "   Found: $log"
        # Check last 100 lines for extension-related messages
        recent_messages=$(tail -100 "$log" 2>/dev/null | grep -i -E "(breakcorn|extension)" | tail -10)
        if [[ -n "$recent_messages" ]]; then
            echo "   Recent messages:"
            echo "$recent_messages" | sed 's/^/     /'
        else
            echo "   No recent extension messages"
        fi
    else
        echo "   Not found: $log"
    fi
done

echo
echo "2. Using dbus-monitor to capture extension activation:"
echo "   Starting dbus monitor... (press Ctrl+C after trying to enable extension)"
echo "   Now try: gnome-extensions enable breakcorn-radio@breakcorny@gmail.com"
echo

# Monitor dbus for extension-related messages
timeout 30s dbus-monitor --session | grep -E "(extension|Extension|breakcorn|Breakcorn)" &
MONITOR_PID=$!

echo "   Waiting for 10 seconds or until you enable the extension..."
sleep 10

# Kill monitor
kill $MONITOR_PID 2>/dev/null || true
wait $MONITOR_PID 2>/dev/null || true

echo
echo "3. Checking if GNOME Shell can see our console.log messages:"
echo "   The extension should output debug messages when enabled."
echo "   If you don't see them above, try:"
echo
echo "   a) Looking Glass (Alt+F2 → 'lg' → Enter):"
echo "      - Go to 'Extensions' tab"
echo "      - Look for error messages"
echo
echo "   b) Browser developer tools:"
echo "      - If you have gnome-shell-extension-prefs installed"
echo "      - Check console for errors"
echo
echo "   c) Direct GNOME Shell restart:"
echo "      - Alt+F2 → 'r' → Enter"
echo "      - Then try enabling the extension"
echo
echo "4. Extension status right now:"
gnome-extensions info breakcorn-radio@breakcorny@gmail.com | grep -E "Enabled:|State:"
