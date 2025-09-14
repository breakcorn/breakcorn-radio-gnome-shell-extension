# Simple Installation Guide

This guide provides a streamlined installation method for the Breakcorn Radio GNOME Extension.

## Quick Installation

```bash
# Clone the repository
git clone https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension.git
cd breakcorn-radio-gnome-shell-extension

# Use the simple installer
./simple-install.sh
```

## Supported Systems

- **Ubuntu**: 22.04 LTS, 24.04 LTS, 25.04
- **GNOME Shell**: 45, 46, 47, 48
- **Other Linux**: Should work on most distributions with GNOME

## Installation Options

```bash
# Install (default)
./simple-install.sh
./simple-install.sh install

# Uninstall
./simple-install.sh uninstall

# Help
./simple-install.sh help
```

## After Installation

1. **Restart GNOME Shell**:
   - **X11**: Press `Alt+F2`, type `r`, press `Enter`
   - **Wayland**: Log out and log back in

2. **Enable Extension**:
   - Use GNOME Extensions app
   - Or run: `gnome-extensions enable breakcorn-radio@breakcorny@gmail.com`

3. **Find the Extension**:
   - Look for the radio icon in the top panel
   - Click to open the player interface

## Manual Installation (Original Method)

If the script doesn't work, you can install manually:

```bash
# Copy extension files
cp -r 'breakcorn-radio@breakcorny@gmail.com' ~/.local/share/gnome-shell/extensions/

# Enable extension
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com

# Restart GNOME Shell
# X11: Alt+F2 → 'r' → Enter
# Wayland: logout/login
```

## Troubleshooting

### Quick Diagnosis

Run the installation checker:
```bash
./check-install.sh
```

This will verify:
- Extension files are properly installed
- GNOME Shell recognizes the extension
- Version compatibility
- Current status (enabled/disabled)

### Common Issues

**"Extension does not exist" error:**
```bash
# Check installation
./check-install.sh

# If not installed:
./simple-install.sh install

# Restart GNOME Shell:
# X11: Alt+F2 → 'r' → Enter  
# Wayland: logout/login

# Then enable:
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com
```

**Extension not visible in panel:**
- Restart GNOME Shell (required after first install)
- Check if enabled: `gnome-extensions list --enabled | grep breakcorn`
- Look for radio icon in top panel (may be hidden in overflow)

**Audio not working:**
- Install GStreamer plugins (see main README.md)
- Check audio permissions
- Test with different radio station

**Permission errors:**
- Ensure you're running as regular user (not root)
- Check directory permissions: `ls -la ~/.local/share/gnome-shell/extensions/`

## Advanced Installation

For advanced features and dependency checking, use the full installer:

```bash
./install.sh
```

This script includes:
- System compatibility checks
- GStreamer dependency verification
- Audio pipeline testing
- Detailed error reporting
