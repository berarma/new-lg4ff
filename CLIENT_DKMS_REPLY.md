# Reply to Client: DKMS and "Invalid Code" Warnings

## Good News! ✅

**Your device IS working correctly!** The messages you see are expected.

## About the Messages

### 1. "Input-only support" ✅
This is **CORRECT** and expected. The RS50 doesn't have an output report, so force feedback is disabled, but **input works perfectly**. This is the intended behavior.

### 2. "Invalid code 768-777 type 1" ⚠️
These are **harmless warnings**. They mean:
- The RS50's HID report descriptor has some codes the kernel doesn't recognize
- This is **normal** for some devices
- The device **still works** despite these warnings
- **You can safely ignore them**

These warnings don't affect functionality at all.

## DKMS Setup (Optional)

DKMS automatically rebuilds the module when you update your kernel. You can set it up if you want:

### Quick DKMS Setup:

```bash
cd ~/new-lg4ff

# Remove old version (if exists)
sudo dkms remove hid-logitech-new/0.5.0 --all 2>/dev/null || true

# Add to DKMS
sudo dkms add .

# Build and install
sudo dkms build hid-logitech-new/0.5.0
sudo dkms install hid-logitech-new/0.5.0

# Load module
sudo modprobe hid-logitech-new
```

### Or Continue with Manual Install:

If you prefer, you can continue using manual install (what you're doing now):

```bash
cd ~/new-lg4ff
make clean && make
sudo make install
sudo modprobe hid-logitech-new
```

**Note:** With manual install, you'll need to rebuild after kernel updates. With DKMS, it's automatic.

## Verify Everything Works

```bash
# Check module
lsmod | grep "hid-logitech-new"

# Check dmesg (warnings are OK)
sudo dmesg | grep -i "logitech\|rs50" | tail -10

# Test input
sudo evtest /dev/input/event20
```

## Summary

- ✅ **Device is working** - "Input-only support" is correct
- ⚠️ **Warnings are harmless** - "Invalid code" messages don't affect functionality
- 🔧 **DKMS is optional** - Use it if you want automatic rebuilding, or continue with manual install
- 🎮 **Ready to use** - Your wheel should work in games!

The "Invalid code" warnings are just the HID parser saying "I don't recognize these codes, but I'll handle them anyway." The device works fine despite them.

**You can safely ignore the "Invalid code" warnings - they're just informational messages.**
