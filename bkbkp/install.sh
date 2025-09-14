#!/bin/bash

# Breakcorn Radio GNOME Shell Extension - Automated Installer
# Compatible with Ubuntu LTS (22.04, 24.04) and Ubuntu 25.04, GNOME Shell 45, 46, 47, 48
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
  reinstall   Uninstall and install again
  check       Check system compatibility
  help        Show this help message

Examples:
  $0
  $0 install
  $0 uninstall
  $0 check
EOF
}

# Check if running on supported system
check_system() {
  log_info "Checking system compatibility..."
  
  # Check if we're on Linux
  if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This extension only supports Linux systems"
    return 1
  fi
  
  # Check if we're on Ubuntu (preferred)
  if command -v lsb_release >/dev/null 2>&1; then
    DISTRO=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    log_info "Detected: $DISTRO $VERSION"
    
    if [[ "$DISTRO" == "Ubuntu" ]]; then
      # Check if it's a supported Ubuntu version
      case "$VERSION" in
        "22.04"|"24.04"|"25.04")
          log_success "Supported Ubuntu version: $VERSION"
          ;;
        "20.04"|"23.04"|"23.10")
          log_warning "Ubuntu $VERSION may work but is not officially tested"
          ;;
        *)
          log_warning "Ubuntu $VERSION is untested. Supported versions: 22.04, 24.04, 25.04"
          ;;
      esac
    else
      log_warning "This extension is optimized for Ubuntu, but may work on other distributions"
    fi
  fi
  
  return 0
}

# Check GNOME Shell version
check_gnome_version() {
  log_info "Checking GNOME Shell version..."
  
  if ! command -v gnome-shell >/dev/null 2>&1; then
    log_error "GNOME Shell not found. This extension requires GNOME desktop environment."
    return 1
  fi
  
  GNOME_VERSION=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)
  log_info "GNOME Shell version: $GNOME_VERSION"
  
  if [[ "$GNOME_VERSION" -lt 45 || "$GNOME_VERSION" -gt 48 ]]; then
    log_warning "GNOME Shell $GNOME_VERSION may not be fully supported. Supported versions: 45, 46, 47, 48"
  else
    log_success "GNOME Shell version is supported"
  fi
  
  return 0
}

# Check system dependencies
check_dependencies() {
  log_info "Checking system dependencies..."
  
  local missing_deps=()
  
  # Check GStreamer
  if ! command -v gst-launch-1.0 >/dev/null 2>&1; then
    missing_deps+=("gstreamer1.0-tools")
  fi
  
  # Check for essential GStreamer plugins
  if ! gst-inspect-1.0 playbin >/dev/null 2>&1; then
    missing_deps+=("gstreamer1.0-plugins-base")
  fi
  
  if ! gst-inspect-1.0 pulsesink >/dev/null 2>&1; then
    missing_deps+=("gstreamer1.0-pulseaudio")
  fi
  
  # Check for multimedia codecs
  local codec_plugins=("gstreamer1.0-plugins-good" "gstreamer1.0-plugins-bad" "gstreamer1.0-plugins-ugly")
  local found_codecs=false
  
  for plugin in "${codec_plugins[@]}"; do
    if dpkg -l | grep -q "$plugin"; then
      found_codecs=true
      break
    fi
  done
  
  if [[ "$found_codecs" == false ]]; then
    missing_deps+=("gstreamer1.0-plugins-good")
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_warning "Missing dependencies detected: ${missing_deps[*]}"
    log_info "To install missing dependencies, run:"
    echo "  sudo apt update && sudo apt install ${missing_deps[*]}"
    
    read -p "Do you want to install missing dependencies now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      log_info "Installing dependencies..."
      sudo apt update && sudo apt install "${missing_deps[@]}"
      log_success "Dependencies installed successfully"
    else
      log_warning "Proceeding without installing dependencies. Extension may not work properly."
    fi
  else
    log_success "All dependencies are satisfied"
  fi
  
  return 0
}

# Test GStreamer audio pipeline
test_audio_pipeline() {
  log_info "Testing GStreamer audio pipeline..."
  
  if timeout 3 gst-launch-1.0 audiotestsrc num-buffers=10 ! pulsesink >/dev/null 2>&1; then
    log_success "Audio pipeline test passed"
  else
    log_warning "Audio pipeline test failed. You may experience audio issues."
  fi
}

# Check if extension is already installed
check_existing_installation() {
  if [[ -d "$EXT_DIR/$EXT_UUID" ]]; then
    log_warning "Extension is already installed at: $EXT_DIR/$EXT_UUID"
    return 0
  fi
  return 1
}

# Install the extension
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
  
  # Copy extension files
  log_info "Copying extension files..."
  cp -r "$SOURCE_DIR/$EXT_UUID" "$EXT_DIR/"
  
  # Set proper permissions
  chmod -R 755 "$EXT_DIR/$EXT_UUID"
  
  log_success "Extension files installed successfully"
  return 0
}

# Enable the extension
enable_extension() {
  log_info "Enabling extension..."
  
  if command -v gnome-extensions >/dev/null 2>&1; then
    if gnome-extensions enable "$EXT_UUID" 2>/dev/null; then
      log_success "Extension enabled successfully"
    else
      log_warning "Failed to enable extension automatically"
      log_info "You can enable it manually using: gnome-extensions enable $EXT_UUID"
      log_info "Or use GNOME Tweaks / Extension Manager"
    fi
  else
    log_warning "gnome-extensions command not available"
    log_info "Please enable the extension manually using GNOME Tweaks or Extension Manager"
  fi
}

# Disable the extension
disable_extension() {
  log_info "Disabling extension..."
  
  if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
    log_success "Extension disabled"
  fi
}

# Uninstall the extension
uninstall_extension() {
  log_info "Uninstalling $EXT_NAME..."
  
  # Disable extension first
  disable_extension
  
  # Remove extension directory
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
}

# Suggest GNOME Shell restart
suggest_restart() {
  log_info "Installation completed!"
  echo
  log_warning "GNOME Shell restart may be required for the extension to work properly:"
  
  if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
    log_info "  Press Alt+F2, type 'r' and press Enter"
  else
    log_info "  Log out and log back in (Wayland session)"
  fi
  
  echo
  log_info "After restart, you should see the radio icon in the top panel"
  log_info "If not visible, check: Extensions app or GNOME Tweaks"
}

# Run system compatibility check
run_compatibility_check() {
  log_info "=== System Compatibility Check ==="
  
  local checks_passed=0
  local total_checks=4
  
  check_system && ((checks_passed++))
  check_gnome_version && ((checks_passed++))
  check_dependencies && ((checks_passed++))
  test_audio_pipeline && ((checks_passed++))
  
  echo
  if [[ $checks_passed -eq $total_checks ]]; then
    log_success "All compatibility checks passed! ($checks_passed/$total_checks)"
    log_success "Your system is ready for Breakcorn Radio extension"
  else
    log_warning "Compatibility check completed with warnings ($checks_passed/$total_checks)"
    log_warning "Extension may work but could have issues"
  fi
  
  return 0
}

# Main installation process
run_installation() {
  log_info "=== Installing $EXT_NAME ==="
  
  # Check if already installed
  if check_existing_installation; then
    read -p "Do you want to reinstall? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Installation cancelled"
      return 0
    fi
  fi
  
  # Run compatibility checks
  run_compatibility_check
  
  echo
  read -p "Do you want to continue with installation? [Y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    log_info "Installation cancelled by user"
    return 0
  fi
  
  # Install extension
  install_extension || return 1
  enable_extension
  suggest_restart
  
  return 0
}

# Main script logic
main() {
  local action="${1:-install}"
  
  case "$action" in
    "install")
      run_installation
      ;;
    "uninstall")
      uninstall_extension
      ;;
    "reinstall")
      uninstall_extension
      echo
      run_installation
      ;;
    "check")
      run_compatibility_check
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
