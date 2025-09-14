#!/bin/bash

# Breakcorn Radio GNOME Shell Extension - Simple Installer
# Compatible with Ubuntu 22.04, 24.04, 25.04 and other Linux distributions
# Based on original README.md.bak instructions
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
CONFIG_DIR="$HOME/.breakcorn-radio"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Show usage information
show_usage() {
  cat << EOF
Usage: $0 [OPTIONS]

Options:
  install     Install the extension (default)
  uninstall   Remove the extension
  help        Show this help message

Based on original simple installation method.
For GUI environment, you may need to restart GNOME Shell after installation.

EOF
}

# Simple installation (original method)
install_extension() {
  log_info "Installing $EXT_NAME..."
  
  # Create extensions directory if it doesn't exist
  mkdir -p "$EXT_DIR"
  
  # Check if source extension directory exists
  if [[ ! -d "$SOURCE_DIR/$EXT_UUID" ]]; then
    log_error "Extension source directory not found: $SOURCE_DIR/$EXT_UUID"
    log_error "Make sure you're running this script from the extension's root directory"
    return 1
  fi
  
  # Copy extension files (original method)
  log_info "Copying extension files..."
  cp -r "$SOURCE_DIR/$EXT_UUID" "$EXT_DIR/"
  
  # Set proper permissions
  chmod -R 755 "$EXT_DIR/$EXT_UUID"
  
  log_success "Extension files installed successfully to: $EXT_DIR/$EXT_UUID"
  
  # Try to enable extension if gnome-extensions is available
  if command -v gnome-extensions >/dev/null 2>&1; then
    log_info "Attempting to enable extension..."
    if gnome-extensions enable "$EXT_UUID" 2>/dev/null; then
      log_success "Extension enabled successfully"
    else
      log_warning "Could not enable extension automatically"
      log_info "You can enable it manually using:"
      echo "  gnome-extensions enable $EXT_UUID"
      echo "  Or use GNOME Tweaks / Extension Manager"
    fi
  else
    log_info "Extension installed. To enable:"
    echo "  1. Restart GNOME Shell (Alt+F2 → 'r' → Enter on X11, or logout/login on Wayland)"
    echo "  2. Enable in GNOME Tweaks or Extension Manager"
    echo "  3. Or run: gnome-extensions enable $EXT_UUID"
  fi
  
  return 0
}

# Simple uninstall
uninstall_extension() {
  log_info "Uninstalling $EXT_NAME..."
  
  # Disable extension first if possible
  if command -v gnome-extensions >/dev/null 2>&1; then
    log_info "Disabling extension..."
    gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
  fi
  
  # Remove extension directory (FIXED UUID)
  if [[ -d "$EXT_DIR/$EXT_UUID" ]]; then
    rm -rf "$EXT_DIR/$EXT_UUID"
    log_success "Extension files removed"
  else
    log_warning "Extension directory not found: $EXT_DIR/$EXT_UUID"
  fi
  
  # Ask about removing configuration
  if [[ -d "$CONFIG_DIR" ]]; then
    read -p "Do you want to remove user configuration? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$CONFIG_DIR"
      log_success "Configuration removed"
    else
      log_info "Configuration preserved at: $CONFIG_DIR"
    fi
  fi
  
  log_success "Uninstallation completed"
  
  if command -v gnome-shell >/dev/null 2>&1; then
    log_info "You may need to restart GNOME Shell to complete removal"
  fi
}

# Main script logic
main() {
  local action="${1:-install}"
  
  echo "=== Breakcorn Radio GNOME Shell Extension - Simple Installer ==="
  echo
  
  case "$action" in
    "install")
      install_extension
      ;;
    "uninstall")
      uninstall_extension
      ;;
    "help"|"--help"|"-h")
      show_usage
      ;;
    *)
      log_error "Unknown action: $action"
      echo
      show_usage
      exit 1
      ;;
  esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
