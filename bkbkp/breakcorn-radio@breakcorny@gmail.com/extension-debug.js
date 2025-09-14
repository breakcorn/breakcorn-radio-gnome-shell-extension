// Debug version of extension.js without GStreamer dependency
// Copy this as extension.js to test if GStreamer is the issue

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";

import GObject from "gi://GObject";
import St from "gi://St";
import Clutter from "gi://Clutter";

import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";
import * as PopupMenu from "resource:///org/gnome/shell/ui/popupMenu.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

let button;

// Simple debug panel button without radio functionality
const DebugPanelButton = GObject.registerClass(
    class DebugPanelButton extends PanelMenu.Button {
        _init() {
            super._init(0.0, "Breakcorn Radio (Debug)");
            
            console.log("Breakcorn Radio Debug: Creating panel button...");
            
            // Create icon
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
            this.add_style_class_name("panel-status-button");
            
            // Add simple menu
            const menuItem = new PopupMenu.PopupMenuItem("Breakcorn Radio - Debug Mode");
            this.menu.addMenuItem(menuItem);
            
            const infoItem = new PopupMenu.PopupMenuItem("Extension loaded successfully!", {
                reactive: false
            });
            this.menu.addMenuItem(infoItem);
            
            console.log("Breakcorn Radio Debug: Panel button created successfully");
        }
    }
);

export default class BreakcornRadioDebugExtension extends Extension {
    enable() {
        console.log("Breakcorn Radio Debug: Starting extension enable...");
        try {
            console.log("Breakcorn Radio Debug: Creating debug panel button...");
            button = new DebugPanelButton();
            
            console.log("Breakcorn Radio Debug: Adding to status area...");
            Main.panel.addToStatusArea("breakcorn-debug", button);
            
            console.log("Breakcorn Radio Debug: Extension enabled successfully!");
            console.log("Breakcorn Radio Debug: Look for the audio icon in the top panel");
        } catch (error) {
            console.error("Breakcorn Radio Debug: Failed to enable extension:", error.message);
            console.error("Breakcorn Radio Debug: Error stack:", error.stack);
            throw error;
        }
    }

    disable() {
        console.log("Breakcorn Radio Debug: Disabling extension...");
        if (button) {
            button.destroy();
            button = null;
            console.log("Breakcorn Radio Debug: Extension disabled successfully");
        }
    }
}
