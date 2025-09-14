#!/bin/bash

# Check JavaScript syntax in all extension files
# License: GPL v3

EXT_DIR="breakcorn-radio@breakcorny@gmail.com"

echo "=== JavaScript Syntax Checker ==="
echo

# Check if source directory exists
if [[ ! -d "$EXT_DIR" ]]; then
    echo "Extension source directory not found: $EXT_DIR"
    exit 1
fi

# JavaScript files to check
js_files=(
    "extension.js"
    "radio.js"
    "channels.js"
    "data.js"
    "extension-debug.js"
    "extension-file-logging.js"
    "extension-minimal.js"
)

echo "1. Checking JavaScript syntax with various methods..."
echo

errors_found=0

# Method 1: Using node (if available)
if command -v node >/dev/null 2>&1; then
    echo "Using Node.js for syntax checking:"
    for file in "${js_files[@]}"; do
        filepath="$EXT_DIR/$file"
        if [[ -f "$filepath" ]]; then
            echo -n "   Checking $file... "
            if node -c "$filepath" 2>/dev/null; then
                echo "✓ OK"
            else
                echo "✗ SYNTAX ERROR"
                echo "     Error details:"
                node -c "$filepath" 2>&1 | sed 's/^/     /'
                ((errors_found++))
            fi
        else
            echo "   Skipping $file (not found)"
        fi
    done
else
    echo "Node.js not available for syntax checking"
fi

echo

# Method 2: Using gjs (GNOME JavaScript) if available
if command -v gjs >/dev/null 2>&1; then
    echo "Using gjs (GNOME JavaScript) for syntax checking:"
    for file in "${js_files[@]}"; do
        filepath="$EXT_DIR/$file"
        if [[ -f "$filepath" ]]; then
            echo -n "   Checking $file... "
            if gjs -c "$filepath" 2>/dev/null; then
                echo "✓ OK"
            else
                echo "✗ SYNTAX ERROR"
                echo "     Error details:"
                gjs -c "$filepath" 2>&1 | sed 's/^/     /'
                ((errors_found++))
            fi
        fi
    done
else
    echo "gjs not available for syntax checking"
fi

echo

# Method 3: Manual checks for common issues
echo "2. Manual checks for common JavaScript issues:"
echo

for file in "${js_files[@]}"; do
    filepath="$EXT_DIR/$file"
    if [[ -f "$filepath" ]]; then
        echo "Checking $file for common issues:"
        
        # Check for missing semicolons after imports
        if grep -n "^import.*[^;]$" "$filepath" >/dev/null 2>&1; then
            echo "   ⚠ Possible missing semicolons after imports:"
            grep -n "^import.*[^;]$" "$filepath" | sed 's/^/     /'
        fi
        
        # Check for mismatched brackets
        open_braces=$(grep -o '{' "$filepath" | wc -l)
        close_braces=$(grep -o '}' "$filepath" | wc -l)
        if [[ $open_braces -ne $close_braces ]]; then
            echo "   ⚠ Mismatched braces: $open_braces open, $close_braces close"
        fi
        
        # Check for mismatched parentheses
        open_parens=$(grep -o '(' "$filepath" | wc -l)
        close_parens=$(grep -o ')' "$filepath" | wc -l)
        if [[ $open_parens -ne $close_parens ]]; then
            echo "   ⚠ Mismatched parentheses: $open_parens open, $close_parens close"
        fi
        
        # Check for ES6 import syntax issues
        if grep -n "import.*from.*['\"]\\./.*['\"]" "$filepath" >/dev/null 2>&1; then
            echo "   ✓ ES6 import syntax looks correct"
        fi
        
        # Check for export syntax
        if grep -n "export" "$filepath" >/dev/null 2>&1; then
            echo "   ✓ Has export statements"
        fi
        
        echo
    fi
done

# Method 4: Check specific file for GNOME Shell extension structure
echo "3. Checking extension.js structure:"
if [[ -f "$EXT_DIR/extension.js" ]]; then
    # Check for required export default class
    if grep -q "export default class.*Extension" "$EXT_DIR/extension.js"; then
        echo "   ✓ Has export default class extending Extension"
    else
        echo "   ✗ Missing 'export default class ... extends Extension'"
        ((errors_found++))
    fi
    
    # Check for enable() method
    if grep -q "enable()" "$EXT_DIR/extension.js"; then
        echo "   ✓ Has enable() method"
    else
        echo "   ✗ Missing enable() method"
        ((errors_found++))
    fi
    
    # Check for disable() method
    if grep -q "disable()" "$EXT_DIR/extension.js"; then
        echo "   ✓ Has disable() method"
    else
        echo "   ✗ Missing disable() method"
        ((errors_found++))
    fi
fi

echo
echo "=== Syntax Check Results ==="
if [[ $errors_found -eq 0 ]]; then
    echo "✓ No syntax errors detected"
    echo "The issue is likely with:"
    echo "  - Import dependencies (GStreamer, etc.)"
    echo "  - Runtime errors during module loading"
    echo "  - GNOME Shell API compatibility"
else
    echo "✗ Found $errors_found syntax errors"
    echo "Fix these errors before testing the extension"
fi

echo
echo "Next steps:"
echo "1. If no syntax errors: Check import dependencies"
echo "2. Use Looking Glass (Alt+F2 → lg) for runtime errors"
echo "3. Test with simpler extension versions first"
