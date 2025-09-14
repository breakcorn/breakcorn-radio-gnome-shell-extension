# Breakcorn Radio Extension Troubleshooting Guide

## Issue: Extension Won't Enable (State: INITIALIZED)

If your extension shows as installed but won't enable:

### Step 1: Run Diagnostics

```bash
# Basic diagnostics
./check-install.sh

# Detailed debugging
./debug-extension.sh

# Test activation with logging
./test-activate.sh
```

### Step 2: Check for JavaScript Errors

The most common cause is a JavaScript error during extension initialization.

```bash
# Watch logs while enabling extension
./watch-logs.sh
# In another terminal:
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com
```

### Step 3: Test Without GStreamer

GStreamer initialization often causes problems:

```bash
# Test with debug version (no audio functionality)
./test-debug-version.sh
```

**If debug version works:** The issue is GStreamer. Install missing packages:
```bash
sudo apt update
sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-pulseaudio
```

**If debug version fails:** There's a deeper GNOME Shell integration issue.

### Step 4: Manual Log Check

```bash
# Check recent system logs
journalctl --user -u gnome-shell --since="5 minutes ago" | grep -i extension

# Check session errors (if file exists)
tail ~/.xsession-errors

# Check GNOME Shell version compatibility
gnome-shell --version
```

### Step 5: Clean Reinstall

```bash
# Complete removal and reinstall
./simple-install.sh uninstall
rm -rf ~/.breakcorn-radio  # Remove config
./simple-install.sh install

# Restart GNOME Shell
# X11: Alt+F2 → 'r' → Enter
# Wayland: logout/login

# Try enabling
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com
```

## Issue: Extension Enables But No Icon Appears

### Check Panel Overflow
- Look in the top-right corner of the panel
- The icon might be hidden in system tray overflow
- Try clicking the arrow or dots in the top-right

### Restart GNOME Shell
```bash
# X11
gnome-shell --replace &
# or Alt+F2 → 'r' → Enter

# Wayland
# Logout and login again
```

## Issue: Audio Doesn't Play

### Install GStreamer Plugins

```bash
# Ubuntu/Debian
sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio

# Test GStreamer
gst-launch-1.0 audiotestsrc num-buffers=100 ! pulsesink
```

### Check Audio System
```bash
# Test PulseAudio
pulseaudio --check -v

# List audio sinks
pactl list short sinks

# Test internet radio stream
gst-launch-1.0 playbin uri=https://stream.breakcorn.ru/main
```

## Issue: Permission Errors

```bash
# Fix extension directory permissions
chmod -R 755 ~/.local/share/gnome-shell/extensions/breakcorn-radio@breakcorny@gmail.com

# Ensure you're not running as root
whoami  # Should NOT be 'root'
```

## Common Error Messages

### "Extension does not exist"
- Extension not installed: Run `./simple-install.sh install`
- GNOME Shell needs restart: Press Alt+F2 → 'r' → Enter

### "Failed to create playbin element"
- Missing GStreamer plugins: `sudo apt install gstreamer1.0-plugins-base`

### "Failed to create pulsesink element"
- Missing PulseAudio plugin: `sudo apt install gstreamer1.0-pulseaudio`

### Extension shows "ERROR" state
- JavaScript error in extension code
- Check logs with `./watch-logs.sh`
- Try debug version with `./test-debug-version.sh`

## Getting Help

If none of these steps work:

1. **Run full diagnostics:**
   ```bash
   ./debug-extension.sh > debug-output.txt 2>&1
   ```

2. **Check GNOME Shell version compatibility:**
   - Extension supports GNOME Shell 45, 46, 47, 48
   - Check with: `gnome-shell --version`

3. **Report the issue** with:
   - Your GNOME Shell version
   - Ubuntu version
   - Output from debug scripts
   - Any error messages from logs

4. **Alternative installation:**
   - Try installing from GNOME Extensions website
   - Use GNOME Tweaks or Extensions app instead of command line
