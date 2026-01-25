#!/bin/bash
# Quick fix script for loading the module correctly

set -e

cd ~/new-lg4ff

echo "=== Step 1: Unloading existing modules ==="
sudo modprobe -r hid_logitech 2>/dev/null || echo "hid_logitech not loaded"
sudo rmmod hid-logitech-new 2>/dev/null || echo "hid-logitech-new not loaded"
sudo rmmod hid_logitech_new 2>/dev/null || echo "hid_logitech_new not loaded"

echo ""
echo "=== Step 2: Checking what's still loaded ==="
lsmod | grep -i "logitech" || echo "No Logitech modules loaded"

echo ""
echo "=== Step 3: Rebuilding module ==="
make clean
make

echo ""
echo "=== Step 4: Installing module ==="
sudo make install

echo ""
echo "=== Step 5: Loading module ==="
sudo modprobe hid-logitech-new

echo ""
echo "=== Step 6: Verifying ==="
if lsmod | grep -q "hid-logitech-new"; then
    echo "✓ Module loaded successfully!"
else
    echo "✗ Module failed to load"
    echo "Check dmesg for errors:"
    dmesg | tail -10
    exit 1
fi

echo ""
echo "=== Step 7: Checking dmesg ==="
dmesg | grep -i "logitech\|rs50\|c276" | tail -10

echo ""
echo "=== Step 8: Finding input devices ==="
echo "Available input devices:"
ls -la /dev/input/event* 2>/dev/null | head -10 || echo "No input devices found"

echo ""
echo "Run 'evtest' to see all devices and test your RS50"
