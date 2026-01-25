#!/bin/bash
# DKMS Setup Script for hid-logitech-new

set -e

cd ~/new-lg4ff

echo "=========================================="
echo "DKMS Setup for hid-logitech-new"
echo "=========================================="
echo ""

# Check if DKMS is installed
if ! command -v dkms &> /dev/null; then
    echo "❌ DKMS is not installed!"
    echo ""
    echo "Install it with:"
    echo "  sudo apt install dkms    # Debian/Ubuntu"
    echo "  sudo yum install dkms    # RedHat/CentOS"
    exit 1
fi

echo "✅ DKMS is installed"
echo ""

# Remove any existing DKMS version
echo "=== Step 1: Removing old DKMS version (if exists) ==="
sudo dkms remove hid-logitech-new/0.5.0 --all 2>/dev/null || echo "No existing version to remove"
echo ""

# Add to DKMS
echo "=== Step 2: Adding module to DKMS ==="
sudo dkms add .
echo ""

# Build
echo "=== Step 3: Building module ==="
sudo dkms build hid-logitech-new/0.5.0
echo ""

# Install
echo "=== Step 4: Installing module ==="
sudo dkms install hid-logitech-new/0.5.0
echo ""

# Show status
echo "=== Step 5: DKMS Status ==="
dkms status | grep "hid-logitech-new" || echo "Status check failed"
echo ""

# Unload old modules
echo "=== Step 6: Unloading old modules ==="
sudo modprobe -r hid_logitech 2>/dev/null || echo "hid_logitech not loaded"
sudo rmmod hid-logitech-new 2>/dev/null || echo "hid-logitech-new not loaded"
echo ""

# Load new module
echo "=== Step 7: Loading module ==="
sudo modprobe hid-logitech-new
echo ""

# Verify
echo "=== Step 8: Verification ==="
if lsmod | grep -q "hid-logitech-new"; then
    echo "✅ Module loaded successfully!"
    echo ""
    echo "Module info:"
    lsmod | grep "hid-logitech-new"
    echo ""
    echo "=== Recent dmesg messages ==="
    sudo dmesg | grep -i "logitech\|rs50" | tail -10
else
    echo "❌ Module failed to load!"
    echo ""
    echo "Check errors:"
    sudo dmesg | tail -20
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ DKMS setup complete!"
echo "=========================================="
echo ""
echo "The module will now automatically rebuild when you update your kernel."
echo ""
echo "Next steps:"
echo "1. Unplug and replug your RS50 USB cable"
echo "2. Check dmesg: sudo dmesg | grep -i 'logitech\|rs50' | tail -10"
echo "3. Test input: sudo evtest /dev/input/event20"
echo ""
