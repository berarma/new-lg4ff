# Module Loading Fix - Troubleshooting Guide

## Problem
- `modprobe -r hid_logitech_new` fails: "Module not found"
- `insmod hid-logitech-new.ko` fails: "File exists"
- `evtest /dev/input/eventX` fails: "No such file or directory"

## Diagnosis Steps

### Step 1: Check what Logitech modules are loaded

```bash
# List all loaded modules related to Logitech/HID
lsmod | grep -i "logitech\|hid"

# Check specifically for hid_logitech modules
lsmod | grep "hid_logitech"

# Check what module is managing your RS50
dmesg | grep -i "logitech\|rs50\|c276" | tail -20
```

### Step 2: Find the actual module name

```bash
# Check what the module is actually called
modinfo hid-logitech-new.ko | grep "^name:"

# Or check the module name in the .ko file
strings hid-logitech-new.ko | grep "^hid_" | head -5
```

### Step 3: Unload existing Logitech modules

```bash
# Try unloading the generic Logitech module first
sudo modprobe -r hid_logitech

# Try unloading any custom module (try different names)
sudo modprobe -r hid_logitech_new
sudo modprobe -r hid-logitech-new

# Force remove if needed (be careful!)
sudo rmmod hid_logitech 2>/dev/null
sudo rmmod hid_logitech_new 2>/dev/null
sudo rmmod hid-logitech-new 2>/dev/null

# Check if anything is still loaded
lsmod | grep "hid_logitech"
```

### Step 4: Check for module conflicts

```bash
# See what's using the HID subsystem
lsmod | grep "^hid"

# Check dmesg for conflicts
dmesg | tail -30
```

## Solution: Proper Module Loading

### Option A: If using DKMS

```bash
# Remove old DKMS version
sudo dkms remove hid-logitech-new/1.0 --all

# Install new version
sudo dkms install hid-logitech-new/1.0

# Load the module
sudo modprobe hid-logitech-new
```

### Option B: If building manually

```bash
# 1. Make sure you're in the right directory
cd ~/new-lg4ff

# 2. Clean and rebuild
make clean
make

# 3. Unload any existing modules
sudo modprobe -r hid_logitech 2>/dev/null
sudo rmmod hid_logitech_new 2>/dev/null
sudo rmmod hid-logitech-new 2>/dev/null

# 4. Check module name in the .ko file
modinfo hid-logitech-new.ko | grep "^name:"

# 5. Load the module (use the actual name from step 4)
# If name is "hid_logitech_new":
sudo insmod hid-logitech-new.ko

# Or if name is "hid-logitech-new":
sudo insmod hid-logitech-new.ko

# 6. Verify it loaded
lsmod | grep "hid_logitech"
dmesg | tail -20
```

### Option C: Check Makefile for module name

The module name is defined in the Makefile. Check what it's set to:

```bash
grep "MODULE_NAME\|obj-m\|KERNEL_MODULE" Makefile
```

## Finding the Input Device

After the module loads successfully:

```bash
# List all input devices
ls -la /dev/input/event*

# Or use evtest to see all devices
evtest

# Or find RS50 specifically
for dev in /dev/input/event*; do
    udevadm info -q name -n $dev 2>/dev/null | grep -i "logitech\|rs50" && echo "Found: $dev"
done

# Or check /sys
ls -la /sys/class/input/input*/device/name | xargs grep -i "logitech\|rs50"
```

## Complete Workflow

```bash
# 1. Navigate to project directory
cd ~/new-lg4ff

# 2. Check current module status
echo "=== Current modules ==="
lsmod | grep "hid_logitech"
echo ""

# 3. Unload everything
echo "=== Unloading modules ==="
sudo modprobe -r hid_logitech 2>/dev/null
sudo rmmod hid_logitech_new 2>/dev/null
sudo rmmod hid-logitech-new 2>/dev/null
echo ""

# 4. Rebuild
echo "=== Rebuilding ==="
make clean
make
echo ""

# 5. Check module name
echo "=== Module info ==="
modinfo hid-logitech-new.ko | grep "^name:"
echo ""

# 6. Load module
echo "=== Loading module ==="
sudo insmod hid-logitech-new.ko
echo ""

# 7. Verify
echo "=== Verification ==="
lsmod | grep "hid_logitech"
dmesg | tail -10
echo ""

# 8. Find input device
echo "=== Input devices ==="
evtest
```

## Common Issues

### Issue 1: "File exists" error
**Cause:** Module is already loaded or there's a symbol conflict
**Fix:**
```bash
# Find and unload the conflicting module
lsmod | grep "hid"
sudo rmmod <conflicting_module>
```

### Issue 2: Module name mismatch
**Cause:** Module name in .ko doesn't match what you're trying to load
**Fix:**
```bash
# Check actual name
modinfo hid-logitech-new.ko | grep "^name:"
# Use that exact name
```

### Issue 3: No input device
**Cause:** Module didn't load or device not recognized
**Fix:**
```bash
# Check dmesg for errors
dmesg | tail -30
# Check if device is connected
lsusb | grep -i logitech
```

## Quick Fix Script

Save this as `load-module.sh`:

```bash
#!/bin/bash
set -e

cd ~/new-lg4ff

echo "Unloading existing modules..."
sudo modprobe -r hid_logitech 2>/dev/null || true
sudo rmmod hid_logitech_new 2>/dev/null || true
sudo rmmod hid-logitech-new 2>/dev/null || true

echo "Rebuilding..."
make clean
make

echo "Loading module..."
MODULE_NAME=$(modinfo hid-logitech-new.ko | grep "^name:" | awk '{print $2}')
echo "Module name: $MODULE_NAME"

sudo insmod hid-logitech-new.ko

echo "Verifying..."
lsmod | grep "hid_logitech" || echo "Module not found in lsmod!"
dmesg | tail -5

echo "Finding input devices..."
evtest 2>&1 | head -20
```

Make it executable and run:
```bash
chmod +x load-module.sh
./load-module.sh
```
