#!/bin/bash

# Watch GNOME Shell logs for extension debugging
# License: GPL v3

echo "=== Watching GNOME Shell logs for Breakcorn Radio ==="
echo "Press Ctrl+C to stop"
echo "Now try enabling the extension in another terminal..."
echo

# Try different log sources
if journalctl --user -u gnome-shell -f --no-pager 2>/dev/null | grep --line-buffered -E "(breakcorn|Breakcorn|BREAKCORN|extension)"; then
    echo "Using user journal logs"
elif journalctl -u gdm -f --no-pager 2>/dev/null | grep --line-buffered -E "(breakcorn|Breakcorn|BREAKCORN|extension)"; then
    echo "Using gdm journal logs"
elif journalctl -f --no-pager 2>/dev/null | grep --line-buffered -E "(breakcorn|Breakcorn|BREAKCORN|extension)"; then
    echo "Using system journal logs"
else
    echo "Journal logs not available, trying dmesg and Xorg logs..."
    (
        # Monitor dmesg
        dmesg -w 2>/dev/null | grep --line-buffered -E "(breakcorn|Breakcorn|extension)" &
        
        # Monitor Xorg logs if available
        if [[ -f /var/log/Xorg.0.log ]]; then
            tail -f /var/log/Xorg.0.log 2>/dev/null | grep --line-buffered -E "(breakcorn|Breakcorn|extension)" &
        fi
        
        # Monitor user session logs
        if [[ -d ~/.local/share/gnome-shell/logs ]]; then
            tail -f ~/.local/share/gnome-shell/logs/* 2>/dev/null | grep --line-buffered -E "(breakcorn|Breakcorn|extension)" &
        fi
        
        # Wait for user to stop
        wait
    )
fi

echo
echo "Log monitoring stopped."
echo "If you didn't see any extension-related logs:"
echo "1. The extension might be failing silently"
echo "2. Try running: gnome-extensions enable breakcorn-radio@breakcorny@gmail.com"
echo "3. Check the Extensions app for error messages"
echo "4. Look in ~/.xsession-errors file if it exists"
