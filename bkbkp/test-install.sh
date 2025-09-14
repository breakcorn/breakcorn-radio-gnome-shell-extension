#!/bin/bash

# Test version of install script for environments without GNOME Shell
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

EXT_UUID="breakcorn-radio@breakcorny@gmail.com"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test basic functionality
log_info "Testing installation script functionality..."

# Check if extension source exists
if [[ -d "$SOURCE_DIR/$EXT_UUID" ]]; then
  log_success "Extension source directory found: $SOURCE_DIR/$EXT_UUID"
else
  log_warning "Extension source directory not found: $SOURCE_DIR/$EXT_UUID"
fi

# Test file structure
log_info "Checking extension file structure..."
expected_files=("extension.js" "radio.js" "channels.js" "data.js" "metadata.json" "prefs.json")

for file in "${expected_files[@]}"; do
  if [[ -f "$SOURCE_DIR/$EXT_UUID/$file" ]]; then
    log_success "✓ $file"
  else
    log_warning "✗ Missing: $file"
  fi
done

# Test script syntax
log_info "Testing main script syntax..."
if bash -n "$SOURCE_DIR/install.sh"; then
  log_success "Installation script syntax is valid"
else
  log_warning "Installation script has syntax errors"
fi

log_info "Test completed successfully"
