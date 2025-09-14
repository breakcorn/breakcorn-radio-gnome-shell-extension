# Next Steps for Debugging Extension Issue

Based on the diagnostics, the extension is in `INITIALIZED` state but won't activate. Here are the recommended steps:

## Immediate Actions

### 1. Try the File Logging Version (Recommended)
```bash
./test-file-logging.sh
```
This will create detailed logs in `~/.breakcorn-radio-debug.log` showing exactly what happens during activation.

### 2. Use GNOME Looking Glass (Most Effective)
```
Press Alt+F2
Type: lg
Press Enter
```
- Go to "Extensions" tab
- Find "breakcorn-radio@breakcorny@gmail.com"
- Look for error messages
- Note the exact state and any error details

### 3. Test Minimal Version
```bash
./test-minimal.sh
```
If this shows a notification and enables successfully, the issue is with the complex extension code.

## Likely Root Causes

### A. GStreamer Issues (Most Probable)
The extension tries to initialize GStreamer in the constructor, which might fail:

**Test:**
```bash
# Check if GStreamer is installed
gst-launch-1.0 --version

# Check for required plugins
gst-inspect-1.0 playbin
gst-inspect-1.0 pulsesink
```

**Solution:**
```bash
sudo apt update
sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-pulseaudio
```

### B. Circular Import Issues
The extension has complex module dependencies that might cause loading failures.

**Test:** The minimal version should work if this is the issue.

### C. GNOME Shell Version Incompatibility
Despite metadata saying it supports GNOME Shell 48, there might be API changes.

**Test:** Looking Glass will show specific API errors.

## Debugging Order

1. **First:** `./test-file-logging.sh` - Creates detailed logs
2. **Second:** Check `~/.breakcorn-radio-debug.log` for exact error
3. **Third:** Use Looking Glass (Alt+F2 → lg) for real-time debugging
4. **Fourth:** If still failing, try `./test-minimal.sh`

## Expected Outcomes

### If File Logging Works:
- Log file will contain detailed activation trace
- You'll see exactly where the failure occurs
- Error messages will point to specific issues

### If Looking Glass Shows Errors:
- Extension tab will show error state
- Error messages will indicate the specific problem
- Can try manual activation from evaluator tab

### If Minimal Version Works:
- Issue is with complex extension code (GStreamer, UI, etc.)
- GNOME Shell integration is fine
- Focus on dependency issues

### If Nothing Works:
- Fundamental GNOME Shell compatibility issue
- May need GNOME Shell restart: Alt+F2 → 'r' → Enter
- Check if other extensions work

## Getting Detailed Error Information

Once you run the file logging test, you'll have one of these outcomes:

1. **Log file created with detailed info** → Specific error identified
2. **Log file empty or missing** → Extension failed to load at all
3. **Extension enables but no icon** → UI creation issue
4. **Extension shows ERROR state** → JavaScript runtime error

## Contact Information

When reporting issues, please include:

- Output from `./test-file-logging.sh`
- Contents of `~/.breakcorn-radio-debug.log`
- GNOME Shell version: `gnome-shell --version`
- Ubuntu version: `lsb_release -a`
- Any errors from Looking Glass

**The file logging test is the most important step - it will show exactly what's happening during extension activation.**
