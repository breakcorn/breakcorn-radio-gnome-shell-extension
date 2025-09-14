#!/bin/bash

# Breakcorn Radio GNOME Shell Extension - Installation Checker
# License: GPL v3

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Extension details
EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
EXT_NAME="Breakcorn Radio"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
INSTALL_PATH="$EXT_DIR/$EXT_UUID"

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

echo "=== Breakcorn Radio Extension Installation Checker ==="
echo

# Check if extension directory exists
log_info "Checking installation directory..."
if [[ -d "$INSTALL_PATH" ]]; then
  log_success "Extension directory found: $INSTALL_PATH"
else
  log_error "Extension directory not found: $INSTALL_PATH"
  echo
  log_info "To install the extension, run:"
  echo "  ./simple-install.sh install"
  echo "  # or"
  echo "  cp -r 'breakcorn-radio@breakcorny@gmail.com' ~/.local/share/gnome-shell/extensions/"
  exit 1
fi

# Check essential files
log_info "Checking extension files..."
essential_files=("metadata.json" "extension.js" "radio.js" "channels.js" "data.js")
missing_files=()

for file in "${essential_files[@]}"; do
  if [[ -f "$INSTALL_PATH/$file" ]]; then
    log_success "✓ $file"
  else
    log_error "✗ $file (missing)"
    missing_files+=("$file")
  fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
  log_error "Missing essential files: ${missing_files[*]}"
  log_info "Try reinstalling: ./simple-install.sh install"
  exit 1
fi

# Check metadata.json
log_info "Checking metadata..."
if [[ -f "$INSTALL_PATH/metadata.json" ]]; then
  uuid=$(grep -o '"uuid"[^,]*' "$INSTALL_PATH/metadata.json" | cut -d'"' -f4)
  if [[ "$uuid" == "$EXT_UUID" ]]; then
    log_success "UUID correct: $uuid"
  else
    log_error "UUID mismatch. Expected: $EXT_UUID, Found: $uuid"
    exit 1
  fi
fi

# Check GNOME extensions command
log_info "Checking GNOME extensions command..."
if command -v gnome-extensions >/dev/null 2>&1; then
  log_success "gnome-extensions command available"
  
  # Check if extension is recognized
  log_info "Checking if GNOME recognizes the extension..."
  if gnome-extensions list 2>/dev/null | grep -q "$EXT_UUID"; then
    log_success "Extension recognized by GNOME"
    
    # Check if enabled
    if gnome-extensions list --enabled 2>/dev/null | grep -q "$EXT_UUID"; then
      log_success "Extension is ENABLED"
    else
      log_warning "Extension is installed but DISABLED"
      echo
      log_info "To enable the extension:"
      echo "  gnome-extensions enable $EXT_UUID"
      echo "  # or use GNOME Extensions app/GNOME Tweaks"
    fi
  else
    log_warning "Extension not recognized by GNOME Shell"
    echo
    log_info "This usually means you need to restart GNOME Shell:"
    echo "  • X11: Press Alt+F2, type 'r', press Enter"
    echo "  • Wayland: Log out and log back in"
    echo "  • Then try: gnome-extensions enable $EXT_UUID"
  fi
else
  log_warning "gnome-extensions command not available"
  log_info "Install gnome-shell-extensions package or use GNOME Tweaks"
fi

# Check GNOME Shell version
log_info "Checking GNOME Shell version..."
if command -v gnome-shell >/dev/null 2>&1; then
  gnome_version=$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "unknown")
  if [[ "$gnome_version" != "unknown" ]]; then
    log_info "GNOME Shell version: $gnome_version"
    if [[ "$gnome_version" -ge 45 && "$gnome_version" -le 48 ]]; then
      log_success "GNOME Shell version is supported ($gnome_version)"
    else
      log_warning "GNOME Shell version $gnome_version may not be fully supported"
      log_info "Supported versions: 45, 46, 47, 48"
    fi
  else
    log_warning "Could not detect GNOME Shell version"
  fi
else
  log_error "GNOME Shell not found"
  log_error "This extension requires GNOME desktop environment"
  exit 1
fi

# Final summary
echo
log_info "=== Installation Summary ==="
log_success "Extension is properly installed"

if command -v gnome-extensions >/dev/null 2>&1; then
  if gnome-extensions list --enabled 2>/dev/null | grep -q "$EXT_UUID"; then
    log_success "Extension is active and should be visible in the top panel"
    log_info "Look for the radio icon in the GNOME Shell top bar"
  else
    log_info "Next steps:"
    echo "  1. Restart GNOME Shell if you just installed"
    echo "  2. Enable extension: gnome-extensions enable $EXT_UUID"
    echo "  3. Check top panel for radio icon"
  fi
else
  log_info "Next steps:"
  echo "  1. Restart GNOME Shell"
  echo "  2. Enable extension via GNOME Tweaks or Extensions app"
  echo "  3. Check top panel for radio icon"
fi

echo
log_info "If the extension is still disabled after enable command:"
echo "  1. Check GNOME Shell logs: journalctl --user -u gnome-shell -f"
echo "  2. Look for JavaScript errors related to 'breakcorn' or 'extension'"
echo "  3. Make sure GStreamer is installed: apt install gstreamer1.0-plugins-*"
echo "  4. Try the debug script: ./debug-extension.sh"
echo "  5. Check the installation guide: SIMPLE-INSTALL.md"
