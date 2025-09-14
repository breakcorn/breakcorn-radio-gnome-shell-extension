# Debugging with GNOME Shell Looking Glass

Looking Glass is GNOME Shell's built-in debugger and is the best tool for diagnosing extension issues.

## How to Use Looking Glass

### 1. Open Looking Glass
```
Press Alt+F2
Type: lg
Press Enter
```

### 2. Check Extension Status
In the Looking Glass window:
- Click on the **"Extensions"** tab
- Look for "breakcorn-radio@breakcorny@gmail.com"
- Check its state and any error messages

### 3. View Console Output
- Click on the **"Evaluator"** tab
- Type commands to inspect the extension:

```javascript
// Check if extension is loaded
Main.extensionManager.lookup('breakcorn-radio@breakcorny@gmail.com')

// Check extension state
let ext = Main.extensionManager.lookup('breakcorn-radio@breakcorny@gmail.com')
ext.state

// Try to enable extension manually
Main.extensionManager.enableExtension('breakcorn-radio@breakcorny@gmail.com')

// Check for errors
ext.error
```

### 4. Check Console Log Messages
- Any `console.log()`, `console.error()` messages from the extension appear in Looking Glass
- Look for messages starting with "Breakcorn Radio"

### 5. Extension States in Looking Glass
- **ENABLED**: Working correctly
- **DISABLED**: Turned off
- **ERROR**: Failed to load/activate
- **OUT_OF_DATE**: Incompatible with current GNOME Shell
- **DOWNLOADING**: Being installed
- **INITIALIZED**: Loaded but not activated (our current issue)

## Diagnosing INITIALIZED State

If extension shows as **INITIALIZED** instead of **ENABLED**:

1. The extension loaded successfully
2. But the `enable()` method failed or didn't complete properly
3. Look for JavaScript errors in Looking Glass
4. Check if there are missing dependencies

## Example Debugging Session

1. Open Looking Glass (Alt+F2 → lg)
2. Go to Extensions tab
3. Find breakcorn-radio extension
4. Note its state and any error messages
5. Go to Evaluator tab
6. Run these commands one by one:

```javascript
// Get extension object
let ext = Main.extensionManager.lookup('breakcorn-radio@breakcorny@gmail.com')

// Check state
ext.state

// Check for error message
ext.error

// Try manual enable
try {
    Main.extensionManager.enableExtension('breakcorn-radio@breakcorny@gmail.com')
} catch (e) {
    log('Enable failed: ' + e.message)
}

// Check state again
ext.state
```

7. Look for error messages in the output

## Common Error Patterns

### Import Errors
```
Error: Requiring Gst, version none: Typelib file for namespace 'Gst', version 'none' not found
```
**Solution**: Install GStreamer development packages

### Module Loading Errors
```
Error: Could not load extension breakcorn-radio@breakcorny@gmail.com: SyntaxError: ...
```
**Solution**: Fix JavaScript syntax in extension files

### Missing Dependencies
```
Error: Gio: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown
```
**Solution**: Install missing system services

## Tips

- Keep Looking Glass open while testing extension enable/disable
- Use `log()` function instead of `console.log()` for better visibility
- Press Ctrl+Shift+R in Looking Glass to reload extensions
- Close Looking Glass with Escape key

## Alternative: Command Line Debugging

If Looking Glass is not available:

```bash
# Check extension state
gnome-extensions info breakcorn-radio@breakcorny@gmail.com

# Enable with error output
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com 2>&1

# Check system logs
journalctl --user -u gnome-shell --since='1 minute ago'
```
