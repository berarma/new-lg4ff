# Fix: "Module hid-logitech-new not found"

## The Error

```
modprobe: FATAL: Module hid-logitech-new not found.
```

This means the module **isn't currently loaded** (which is fine) or **wasn't installed properly**.

## Diagnosis Steps

### 1. Check if Module is Actually Loaded

```bash
lsmod | grep hid_logitech
```

If you see `hid_logitech_new`, it's loaded. If you see nothing or only `hid_logitech`, it's not loaded.

### 2. Check if Module File Exists

```bash
# Check DKMS installation
find /lib/modules/$(uname -r) -name "hid-logitech-new.ko"

# Or check manual installation
ls -la /lib/modules/$(uname -r)/extra/hid-logitech-new.ko
```

If the file doesn't exist, the module wasn't installed properly.

### 3. Check DKMS Status

```bash
dkms status
```

Should show `new-lg4ff` as installed.

## Solutions

### Solution 1: Module Not Installed - Install It

If the module file doesn't exist:

**Using DKMS:**
```bash
# Make sure you're in the source directory
cd ~/Downloads/new-lg4ff00_complete

# Install via DKMS
sudo dkms install $(pwd)
```

**Or manual install:**
```bash
cd ~/Downloads/new-lg4ff00_complete
make
sudo make install
```

### Solution 2: Module Installed But Not Loaded - Load It

If the module file exists but isn't loaded:

```bash
# Try to load it
sudo modprobe hid-logitech-new

# If that fails, try with full path
sudo insmod /lib/modules/$(uname -r)/updates/dkms/hid-logitech-new.ko
# OR
sudo insmod /lib/modules/$(uname -r)/extra/hid-logitech-new.ko
```

### Solution 3: Check for Conflicting Module

The old `hid-logitech` module might be loaded instead:

```bash
# Check what's loaded
lsmod | grep hid

# If hid_logitech (old) is loaded, unload it first
sudo modprobe -r hid-logitech

# Then load the new one
sudo modprobe hid-logitech-new
```

### Solution 4: Rebuild and Reinstall

If nothing works, rebuild from scratch:

```bash
cd ~/Downloads/new-lg4ff00_complete

# Clean
make clean

# Remove old DKMS module
sudo dkms remove new-lg4ff/0.5.0 --all

# Rebuild
make

# Reinstall
sudo make install
# OR
sudo dkms install $(pwd)

# Load
sudo modprobe hid-logitech-new
```

## Quick Diagnostic Commands

Run these to diagnose:

```bash
# 1. Check what's loaded
lsmod | grep hid

# 2. Check if module file exists
find /lib/modules/$(uname -r) -name "*logitech*.ko"

# 3. Check DKMS status
dkms status

# 4. Check kernel messages
sudo dmesg | grep -i logitech | tail -20

# 5. Try to load
sudo modprobe hid-logitech-new
```

## Expected Results After Fix

Once fixed, you should see:

```bash
# Module loaded
$ lsmod | grep hid_logitech
hid_logitech_new     123456  0

# Success in dmesg
$ sudo dmesg | grep logitech | tail -3
logitech 0003:046D:C276.0001: Force feedback support for Logitech Gaming Wheels
logitech 0003:046D:C276.0001: Hires timer: period = 2 ms
```

## Common Issues

1. **Module not built:** Run `make` first
2. **Module not installed:** Run `sudo make install` or `sudo dkms install`
3. **Wrong kernel version:** Make sure kernel headers match: `uname -r`
4. **Module name mismatch:** Verify it's `hid-logitech-new.ko` not `hid_logitech_new.ko`
