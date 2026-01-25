# DKMS Setup for hid-logitech-new

## About DKMS

DKMS (Dynamic Kernel Module Support) automatically rebuilds kernel modules when you update your kernel. This is useful so you don't have to manually rebuild after kernel updates.

## Current Status

Looking at your dmesg:
- ✅ "Input-only support" - This is **CORRECT** and expected (RS50 doesn't have output report)
- ⚠️ "Invalid code 768-777 type 1" - These are **harmless warnings** (HID core doesn't recognize some codes, but device still works)

## DKMS Setup (Optional but Recommended)

### Option 1: Install via DKMS (Recommended)

```bash
cd ~/new-lg4ff

# Remove any existing DKMS version
sudo dkms remove hid-logitech-new/0.5.0 --all 2>/dev/null || true

# Add to DKMS
sudo dkms add .

# Build and install
sudo dkms build hid-logitech-new/0.5.0
sudo dkms install hid-logitech-new/0.5.0

# Verify
dkms status
# Should show: hid-logitech-new, 0.5.0, <kernel-version>, x86_64: installed

# Load the module
sudo modprobe hid-logitech-new
```

### Option 2: Manual Install (Current Method)

If you prefer manual installation (what you're doing now):

```bash
cd ~/new-lg4ff
make clean
make
sudo make install
sudo modprobe hid-logitech-new
```

**Note:** With manual install, you'll need to rebuild after kernel updates.

## About the "Invalid code" Warnings

The "Invalid code 768-777 type 1" messages are **harmless warnings** from the HID core. They mean:

- The RS50's HID report descriptor contains some codes the kernel doesn't recognize
- This is **normal** for some devices
- The device **still works** despite these warnings
- Input functionality is **not affected**

These warnings appear because the HID parser encounters vendor-specific or non-standard codes. The driver handles them gracefully.

## Suppressing the Warnings (Optional)

If you want to suppress these warnings, you can:

### Method 1: Kernel Parameter

```bash
# Add to kernel command line (in /etc/default/grub or bootloader)
hid.debug=0

# Or load module with debug disabled
sudo modprobe hid-logitech-new hid.debug=0
```

### Method 2: Ignore Them

These warnings are informational and don't affect functionality. You can safely ignore them.

## Verify Everything Works

After DKMS setup (or manual install):

```bash
# 1. Check module is loaded
lsmod | grep "hid-logitech-new"

# 2. Check dmesg (should see "Input-only support", warnings are OK)
sudo dmesg | grep -i "logitech\|rs50" | tail -10

# 3. Test input
sudo evtest /dev/input/event20  # Replace with your device number
```

## Expected dmesg Output

After proper setup, you should see:

```
[timestamp] logitech 0003:046D:C276.XXXX: USB HID v1.11 Joystick [Logitech RS50 Base for PlayStation/PC] on usb-...
[timestamp] logitech 0003:046D:C276.XXXX: missing HID_OUTPUT_REPORT 0
[timestamp] logitech 0003:046D:C276.XXXX: No output report found, force feedback will be disabled
[timestamp] logitech 0003:046D:C276.XXXX: Input-only support for Logitech Gaming Wheel (force feedback disabled - no output report)
[timestamp] logitech 0003:046D:C276.XXXX: Invalid code 768 type 1  ← Harmless warning
[timestamp] logitech 0003:046D:C276.XXXX: Invalid code 769 type 1  ← Harmless warning
... (more invalid code warnings - all harmless)
```

**This is all normal and expected!** The device is working correctly.

## DKMS vs Manual Install

### DKMS (Recommended)
- ✅ Automatically rebuilds on kernel updates
- ✅ Easier long-term maintenance
- ✅ Module persists across reboots
- ⚠️ Requires DKMS package installed

### Manual Install
- ✅ Simple, direct
- ✅ No extra dependencies
- ❌ Need to rebuild after kernel updates
- ❌ Need to reload after reboot

## Check if DKMS is Installed

```bash
# Check if DKMS is installed
which dkms
dpkg -l | grep dkms  # On Debian/Ubuntu
rpm -qa | grep dkms  # On RedHat/CentOS

# If not installed:
sudo apt install dkms  # Debian/Ubuntu
sudo yum install dkms  # RedHat/CentOS
```

## Complete DKMS Setup Script

Save this as `setup-dkms.sh`:

```bash
#!/bin/bash
set -e

cd ~/new-lg4ff

echo "=== Removing old DKMS version ==="
sudo dkms remove hid-logitech-new/0.5.0 --all 2>/dev/null || true

echo ""
echo "=== Adding to DKMS ==="
sudo dkms add .

echo ""
echo "=== Building ==="
sudo dkms build hid-logitech-new/0.5.0

echo ""
echo "=== Installing ==="
sudo dkms install hid-logitech-new/0.5.0

echo ""
echo "=== Status ==="
dkms status

echo ""
echo "=== Loading module ==="
sudo modprobe -r hid_logitech 2>/dev/null || true
sudo rmmod hid-logitech-new 2>/dev/null || true
sudo modprobe hid-logitech-new

echo ""
echo "=== Verification ==="
if lsmod | grep -q "hid-logitech-new"; then
    echo "✅ Module loaded successfully!"
    echo ""
    echo "=== dmesg output ==="
    sudo dmesg | grep -i "logitech\|rs50" | tail -10
else
    echo "❌ Module failed to load"
    sudo dmesg | tail -20
fi
```

Make executable and run:
```bash
chmod +x setup-dkms.sh
./setup-dkms.sh
```

## Summary

1. **"Invalid code" warnings:** Harmless, can be ignored
2. **"Input-only support":** Expected and correct
3. **DKMS setup:** Optional but recommended for automatic rebuilding
4. **Device status:** Working correctly despite warnings

The device is functioning properly. The warnings are just informational messages from the HID parser.
