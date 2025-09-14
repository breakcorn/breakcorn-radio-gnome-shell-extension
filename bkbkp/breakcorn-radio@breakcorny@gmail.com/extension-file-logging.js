// Extension version with file logging for debugging
// Copy this as extension.js to debug activation issues

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import GObject from "gi://GObject";
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import St from "gi://St";
import Clutter from "gi://Clutter";

import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";
import * as PopupMenu from "resource:///org/gnome/shell/ui/popupMenu.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

let button;
let logFile;

// File logging function
function logToFile(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}\n`;
    
    try {
        if (!logFile) {
            const logPath = GLib.get_home_dir() + '/.breakcorn-radio-debug.log';
            logFile = Gio.File.new_for_path(logPath);
        }
        
        // Append to file
        const outputStream = logFile.append_to(Gio.FileCreateFlags.NONE, null);
        outputStream.write(logMessage, null);
        outputStream.close(null);
    } catch (error) {
        // Fallback to console if file logging fails
        console.log(`Breakcorn File Log: ${message}`);
        console.error('File logging failed:', error.message);
    }
}

// Simple debug panel button
const DebugPanelButton = GObject.registerClass(
    class DebugPanelButton extends PanelMenu.Button {
        _init() {
            super._init(0.0, "Breakcorn Radio (File Debug)");
            
            logToFile("Creating debug panel button...");
            
            try {
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
                
                logToFile("Icon and box created successfully");
                
                // Add simple menu
                const menuItem = new PopupMenu.PopupMenuItem("Breakcorn Radio - File Debug Mode");
                this.menu.addMenuItem(menuItem);
                
                const infoItem = new PopupMenu.PopupMenuItem("Check ~/.breakcorn-radio-debug.log for details", {
                    reactive: false
                });
                this.menu.addMenuItem(infoItem);
                
                logToFile("Menu items added successfully");
                logToFile("Panel button creation completed");
                
            } catch (error) {
                logToFile(`ERROR in panel button creation: ${error.message}`);
                logToFile(`Error stack: ${error.stack}`);
                throw error;
            }
        }
    }
);

export default class BreakcornRadioFileLogExtension extends Extension {
    enable() {
        logToFile("=== EXTENSION ENABLE STARTED ===");
        logToFile(`Extension path: ${this.path}`);
        logToFile(`GNOME Shell version: ${global.session_mode || 'unknown'}`);
        
        try {
            logToFile("Creating debug panel button...");
            button = new DebugPanelButton();
            
            logToFile("Adding button to status area...");
            Main.panel.addToStatusArea("breakcorn-file-debug", button);
            
            logToFile("=== EXTENSION ENABLE COMPLETED SUCCESSFULLY ===");
            
            // Show notification
            Main.notify("Breakcorn Radio", "Debug version enabled - check ~/.breakcorn-radio-debug.log");
            
        } catch (error) {
            logToFile(`=== EXTENSION ENABLE FAILED ===");
            logToFile(`ERROR: ${error.message}`);
            logToFile(`ERROR STACK: ${error.stack}`);
            
            // Clean up
            if (button) {
                button.destroy();
                button = null;
            }
            
            logToFile("=== CLEANUP COMPLETED, RE-THROWING ERROR ===");
            throw error;
        }
    }

    disable() {
        logToFile("=== EXTENSION DISABLE STARTED ===");
        
        try {
            if (button) {
                logToFile("Destroying panel button...");
                button.destroy();
                button = null;
                logToFile("Panel button destroyed");
            } else {
                logToFile("No button to destroy (was null)");
            }
            
            logToFile("=== EXTENSION DISABLE COMPLETED ===");
            
        } catch (error) {
            logToFile(`ERROR during disable: ${error.message}`);
            logToFile(`Error stack: ${error.stack}`);
        }
        
        // Close log file handle
        logFile = null;
    }
}
