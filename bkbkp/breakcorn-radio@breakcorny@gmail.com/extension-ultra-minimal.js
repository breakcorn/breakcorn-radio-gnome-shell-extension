// Ultra minimal extension - just console.log to test loading
// Copy this as extension.js to test if the problem is module loading

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";

console.log("Breakcorn Ultra Minimal: Module loaded successfully!");

export default class UltraMinimalExtension extends Extension {
    enable() {
        console.log("Breakcorn Ultra Minimal: enable() called");
        // Do absolutely nothing except log
        console.log("Breakcorn Ultra Minimal: enable() completed");
    }

    disable() {
        console.log("Breakcorn Ultra Minimal: disable() called");
        // Do absolutely nothing except log
        console.log("Breakcorn Ultra Minimal: disable() completed");
    }
}

console.log("Breakcorn Ultra Minimal: Module export completed!");
