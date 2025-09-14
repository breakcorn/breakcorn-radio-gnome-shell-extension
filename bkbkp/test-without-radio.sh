#!/bin/bash

# Test extension without radio.js import to isolate GStreamer issues
# License: GPL v3

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

echo "=== Testing Extension Without Radio Module ==="
echo

if [[ ! -d "$EXT_DIR" ]]; then
    echo "Extension not installed. Run ./simple-install.sh first."
    exit 1
fi

# Create a version of extension.js without radio.js import
echo "1. Creating extension.js without radio module..."

# Backup original if not done
if [[ ! -f "$EXT_DIR/extension.js.original" ]]; then
    cp "$EXT_DIR/extension.js" "$EXT_DIR/extension.js.original"
fi

# Create modified version
cat > "$EXT_DIR/extension.js" << 'EOF'
// Extension without radio.js to test if GStreamer import is the issue
import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import GObject from "gi://GObject";
import St from "gi://St";
import Clutter from "gi://Clutter";
import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";
import * as PopupMenu from "resource:///org/gnome/shell/ui/popupMenu.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

console.log("Breakcorn No Radio: Extension module loaded successfully!");

let button;

// Simple panel button without radio functionality
const SimpleButton = GObject.registerClass(
    class SimpleButton extends PanelMenu.Button {
        _init() {
            super._init(0.0, "Breakcorn Radio (No Radio Module)");
            
            console.log("Breakcorn No Radio: Creating button...");
            
            const icon = new St.Icon({
                icon_name: "audio-x-generic-symbolic",
                style_class: "system-status-icon",
            });
            
            const box = new St.BoxLayout({
                vertical: false,
                style_class: "panel-status-indicators-box",
            });
            
            box.add_child(icon);
            this.add_child(box);
            
            const menuItem = new PopupMenu.PopupMenuItem("No Radio Module Test");
            this.menu.addMenuItem(menuItem);
            
            console.log("Breakcorn No Radio: Button created successfully");
        }
    }
);

export default class NoRadioExtension extends Extension {
    enable() {
        console.log("Breakcorn No Radio: Extension enable started");
        
        try {
            button = new SimpleButton();
            Main.panel.addToStatusArea("breakcorn-no-radio", button);
            
            console.log("Breakcorn No Radio: Extension enabled successfully!");
            Main.notify("Breakcorn Test", "Extension without radio module enabled!");
            
        } catch (error) {
            console.error("Breakcorn No Radio: Enable failed:", error.message);
            console.error("Breakcorn No Radio: Stack:", error.stack);
            throw error;
        }
    }

    disable() {
        console.log("Breakcorn No Radio: Extension disable started");
        
        if (button) {
            button.destroy();
            button = null;
        }
        
        console.log("Breakcorn No Radio: Extension disabled successfully");
    }
}

console.log("Breakcorn No Radio: Module export completed");
EOF

echo "2. Testing extension without radio module..."

# Disable first
gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
sleep 2

# Try to enable
echo "3. Enabling test version..."
if gnome-extensions enable "$EXT_UUID"; then
    echo "   Enable command completed"
else
    echo "   Enable command failed"
fi

sleep 2

echo "4. Checking status:"
gnome-extensions info "$EXT_UUID" | grep -E "Enabled:|State:"

if gnome-extensions list --enabled | grep -q "$EXT_UUID"; then
    echo "   ✓ SUCCESS: Extension enabled without radio module!"
    echo "   This confirms the issue is with GStreamer/radio.js import"
else
    echo "   ✗ Still failed - issue is elsewhere"
fi

echo
read -p "Test complete. Restore original extension? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Restoring original extension.js..."
    mv "$EXT_DIR/extension.js.original" "$EXT_DIR/extension.js"
    echo "Original extension restored."
else
    echo "Test version kept. To restore manually:"
    echo "  mv '$EXT_DIR/extension.js.original' '$EXT_DIR/extension.js'"
fi

echo
echo "=== Test Results ==="
echo "If this version worked:"
echo "  → Problem is with GStreamer import in radio.js"
echo "  → Install GStreamer: sudo apt install gstreamer1.0-plugins-*"
echo "If this version failed too:"
echo "  → Problem is with basic GNOME Shell integration"
echo "  → Try Looking Glass debugging: Alt+F2 → lg"
