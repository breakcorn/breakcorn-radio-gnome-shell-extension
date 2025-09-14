// Minimal extension for testing GNOME Shell integration
// Copy this as extension.js to test basic functionality

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

export default class MinimalExtension extends Extension {
    enable() {
        console.log("Breakcorn Minimal: Extension enable() called");
        
        // Just show a notification - no UI components
        try {
            Main.notify("Breakcorn Radio", "Extension loaded successfully!");
            console.log("Breakcorn Minimal: Notification sent, extension should be enabled");
        } catch (error) {
            console.error("Breakcorn Minimal: Failed to show notification:", error);
        }
        
        console.log("Breakcorn Minimal: Enable method completed");
    }

    disable() {
        console.log("Breakcorn Minimal: Extension disable() called");
        // Nothing to clean up
        console.log("Breakcorn Minimal: Disable method completed");
    }
}
