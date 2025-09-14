# Installation Guide - Breakcorn Radio GNOME Extension

This guide provides automated and manual installation methods for the Breakcorn Radio GNOME Shell extension.

## 🚀 Automated Installation (Recommended)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension.git
cd breakcorn-radio-gnome-shell-extension

# Run the installer
./install.sh
```

### Installation Options

```bash
# Check system compatibility first
./install.sh check

# Install the extension (default)
./install.sh install

# Reinstall (useful for updates)
./install.sh reinstall

# Uninstall
./install.sh uninstall

# Show help
./install.sh help
```

## ✅ System Requirements Check

The installer automatically verifies:

- **Operating System**: Ubuntu LTS (recommended)
- **GNOME Shell**: Versions 45, 46, or 47
- **GStreamer**: Core components and plugins
- **Audio System**: PulseAudio compatibility

## 📦 Dependencies

The installer can automatically install missing dependencies:

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio
```

### Fedora
```bash
sudo dnf install gstreamer1-tools gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly
```

### Arch Linux
```bash
sudo pacman -S gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
```

## 🛠️ Manual Installation

If you prefer manual installation:

### Step 1: Copy Extension Files
```bash
# Create extensions directory
mkdir -p ~/.local/share/gnome-shell/extensions/

# Copy extension
cp -r breakcorn-radio@breakcorny@gmail.com ~/.local/share/gnome-shell/extensions/
```

### Step 2: Enable Extension
```bash
# Using gnome-extensions command
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com

# Or using GUI tools:
# - GNOME Extensions app
# - GNOME Tweaks
```

### Step 3: Restart GNOME Shell
- **X11**: Press `Alt+F2`, type `r`, press Enter
- **Wayland**: Log out and log back in

## 🔧 Installation Script Features

### Automatic Checks
- ✅ System compatibility verification
- ✅ GNOME Shell version detection
- ✅ GStreamer installation and codec availability
- ✅ Audio pipeline testing
- ✅ Existing installation detection

### Smart Installation
- 🔄 Handles existing installations (upgrade path)
- 📁 Creates necessary directories
- 🔐 Sets proper file permissions
- ⚡ Automatically enables the extension
- 🗑️ Clean uninstallation with config preservation option

### User-Friendly
- 🎨 Color-coded output messages
- 📋 Interactive prompts for user choices
- ⚠️ Clear error messages and solutions
- 📖 Helpful post-installation instructions

## 🐛 Troubleshooting

### Extension Not Appearing

1. **Check if installed:**
   ```bash
   gnome-extensions list | grep breakcorn
   ```

2. **Check if enabled:**
   ```bash
   gnome-extensions list --enabled | grep breakcorn
   ```

3. **Enable manually:**
   ```bash
   gnome-extensions enable breakcorn-radio@breakcorny@gmail.com
   ```

### Audio Issues

1. **Test GStreamer pipeline:**
   ```bash
   gst-launch-1.0 audiotestsrc num-buffers=10 ! pulsesink
   ```

2. **Check PulseAudio:**
   ```bash
   pulseaudio --check
   systemctl --user status pulseaudio
   ```

3. **Verify codecs:**
   ```bash
   gst-inspect-1.0 | grep -E '(mp3|aac|ogg|flac)'
   ```

### GNOME Shell Issues

1. **View extension logs:**
   ```bash
   journalctl -f -o cat /usr/bin/gnome-shell | grep -i breakcorn
   ```

2. **Reset GNOME Shell:**
   ```bash
   # X11 only
   killall -3 gnome-shell
   ```

## 📱 Post-Installation

After successful installation:

1. **Look for the radio icon** in your top panel
2. **Click the icon** to open the radio player popup
3. **Choose a station** from the channels menu
4. **Add favorites** by clicking the star icon
5. **Adjust volume** using the slider

## 🔄 Updates

To update the extension:

```bash
# Pull latest changes
git pull

# Reinstall
./install.sh reinstall
```

## 🗑️ Uninstallation

```bash
# Complete removal
./install.sh uninstall

# Manual removal
rm -rf ~/.local/share/gnome-shell/extensions/breakcorn-radio@breakcorny@gmail.com
rm -rf ~/.breakcorn-radio  # Optional: removes user settings
```

## 📋 Installation Locations

- **Extension files**: `~/.local/share/gnome-shell/extensions/breakcorn-radio@breakcorny@gmail.com/`
- **User settings**: `~/.breakcorn-radio/prefs.json`
- **System logs**: `journalctl -u gnome-shell`

---

**Need help?** Open an issue at [GitHub Issues](https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension/issues)
