#!/bin/bash
# RS50 Testing Commands - Step by Step
# Run each section one at a time

echo "=========================================="
echo "RS50 Driver Testing - Step by Step"
echo "=========================================="
echo ""

# Step 1: Check if Driver is Loaded
echo "=== STEP 1: Check if Driver is Loaded ==="
echo ""
echo "Command 1.1: Check if module is loaded"
echo "----------------------------------------"
echo "lsmod | grep \"hid-logitech-new\""
echo ""
read -p "Press Enter to run this command..."
lsmod | grep "hid-logitech-new"
echo ""
echo "If nothing appears above, run: sudo modprobe hid-logitech-new"
echo ""
read -p "Press Enter to continue..."

echo ""
echo "Command 1.2: Check kernel messages"
echo "-----------------------------------"
echo "dmesg | grep -i \"logitech\|rs50\" | tail -10"
echo ""
read -p "Press Enter to run this command..."
dmesg | grep -i "logitech\|rs50" | tail -10
echo ""
read -p "Press Enter to continue to Step 2..."

# Step 2: Find Your Wheel Device
echo ""
echo "=== STEP 2: Find Your Wheel Device ==="
echo ""
echo "Command 2.1: List input devices"
echo "--------------------------------"
echo "evtest"
echo ""
echo "Look for a device with 'Logitech' or 'RS50' in the name"
echo "Write down the device number (e.g., event20)"
echo "Press Ctrl+C to exit evtest when done"
echo ""
read -p "Press Enter to run evtest (you'll need to exit it manually)..."
evtest
echo ""
read -p "What device number did you find? (e.g., 20): " DEVICE_NUM
echo "You selected: event$DEVICE_NUM"
echo ""
read -p "Press Enter to continue to Step 3..."

# Step 3: Test Basic Input Detection
echo ""
echo "=== STEP 3: Test Basic Input Detection ==="
echo ""
echo "Command 3.1: Test input (don't touch wheel yet)"
echo "------------------------------------------------"
echo "sudo evtest /dev/input/event$DEVICE_NUM"
echo ""
echo "Watch for events appearing (should see values around 32670-32767)"
echo "Keep this running for the next steps!"
echo ""
read -p "Press Enter to run evtest (keep it running for Steps 4-6)..."
sudo evtest /dev/input/event$DEVICE_NUM

# Note: The script will pause here while evtest runs
# User needs to exit evtest manually to continue

echo ""
echo "=== Steps 4-6 completed in evtest ==="
echo ""
read -p "Press Enter to continue to Step 7..."

# Step 7: Instructions for BeamNG
echo ""
echo "=== STEP 7: Test in BeamNG.drive ==="
echo ""
echo "Instructions (not terminal commands):"
echo "1. Start BeamNG.drive"
echo "2. Go to Settings → Controls"
echo "3. Select 'Steering Wheel' or 'Gamepad'"
echo "4. Configure controls (rotate wheel, press pedals/buttons)"
echo "5. Set Deadzone to 2-5%"
echo "6. Test in game"
echo ""
read -p "Press Enter when done testing in BeamNG..."

# Step 8: Final Verification
echo ""
echo "=== STEP 8: Final Verification ==="
echo ""
echo "Command 8.1: Check kernel messages"
echo "-----------------------------------"
echo "dmesg | grep -i \"logitech\|rs50\" | tail -5"
echo ""
read -p "Press Enter to run this command..."
dmesg | grep -i "logitech\|rs50" | tail -5
echo ""

echo ""
echo "Command 8.2: Verify module still loaded"
echo "----------------------------------------"
echo "lsmod | grep \"hid-logitech-new\""
echo ""
read -p "Press Enter to run this command..."
lsmod | grep "hid-logitech-new"
echo ""

echo ""
echo "=========================================="
echo "Testing Complete!"
echo "=========================================="
echo ""
echo "Please report your results using the template in:"
echo "CLIENT_COMMANDS_STEP_BY_STEP.md"
echo ""
