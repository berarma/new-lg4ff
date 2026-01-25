#!/bin/bash
# Fix gcc-12 symlink issue
# This script removes the incorrect symlink and ensures the real gcc-12 is used

echo "Checking gcc-12 status..."

if [ -L /usr/bin/gcc-12 ]; then
    TARGET=$(readlink -f /usr/bin/gcc-12)
    echo "Found symlink: /usr/bin/gcc-12 -> $TARGET"
    
    # Check if it's pointing to gcc-11
    if [[ "$TARGET" == *"gcc-11"* ]] || [[ "$TARGET" == *"gcc"* ]]; then
        echo "⚠ Symlink is pointing to wrong version!"
        echo "Removing incorrect symlink..."
        sudo rm /usr/bin/gcc-12
        echo "✓ Symlink removed"
        
        # Check if real gcc-12 exists
        if [ -f /usr/bin/gcc-12 ] || command -v gcc-12 &> /dev/null; then
            echo "✓ Real gcc-12 should now be accessible"
        else
            echo "⚠ gcc-12 binary not found. Checking package..."
            if dpkg -l | grep -q "gcc-12 "; then
                echo "Package installed. Reinstalling to restore binary..."
                sudo apt-get install --reinstall gcc-12
            else
                echo "Installing gcc-12..."
                sudo apt-get update
                sudo apt-get install gcc-12
            fi
        fi
    else
        echo "Symlink looks correct."
    fi
else
    echo "No symlink found. Checking if gcc-12 exists..."
    if [ -f /usr/bin/gcc-12 ] || command -v gcc-12 &> /dev/null; then
        VERSION=$(gcc-12 --version 2>&1 | head -1)
        echo "✓ gcc-12 found: $VERSION"
        
        # Check if it's actually gcc-12
        if echo "$VERSION" | grep -q "12\."; then
            echo "✓ Correct version detected"
        else
            echo "⚠ Wrong version detected. Reinstalling..."
            sudo apt-get install --reinstall gcc-12
        fi
    else
        echo "gcc-12 not found. Installing..."
        sudo apt-get update
        sudo apt-get install gcc-12
    fi
fi

echo ""
echo "Verifying gcc-12:"
gcc-12 --version 2>&1 | head -1
