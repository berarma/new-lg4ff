# Quick Fix Commands for Module Loading

## The Problem
- Module name mismatch: You tried `hid_logitech_new` but it's actually `hid-logitech-new`
- "File exists" error means the module is already loaded or there's a conflict

## Quick Solution (Use Makefile)

The Makefile has built-in targets that handle everything:

```bash
cd ~/new-lg4ff

# Clean, build, install, and load in one command
make load
```

This will:
1. Build the module
2. Install it
3. Remove old modules
4. Load the new one

## Manual Steps (if make load doesn't work)

```bash
cd ~/new-lg4ff

# Step 1: Unload ALL Logitech modules
sudo modprobe -r hid_logitech 2>/dev/null || true
sudo rmmod hid-logitech-new 2>/dev/null || true
sudo rmmod hid_logitech_new 2>/dev/null || true

# Step 2: Verify nothing is loaded
lsmod | grep -i "logitech"
# Should show nothing

# Step 3: Rebuild
make clean
make

# Step 4: Install
sudo make install

# Step 5: Load (use the correct name with hyphens!)
sudo modprobe hid-logitech-new

# Step 6: Verify
lsmod | grep "hid-logitech-new"
dmesg | tail -10
```

## Finding Your Input Device

After the module loads:

```bash
# Option 1: Use evtest to see all devices
evtest
# (Select your RS50 from the list)

# Option 2: Find it manually
for dev in /dev/input/event*; do
    if udevadm info -q name -n $dev 2>/dev/null | grep -qi "logitech\|rs50"; then
        echo "Found RS50: $dev"
    fi
done

# Option 3: Check /sys
find /sys/class/input -name "name" -exec grep -l -i "logitech\|rs50" {} \; 2>/dev/null
```

## If "File exists" Error Persists

This usually means another module is already handling the device:

```bash
# Check what's loaded
lsmod | grep "hid"

# Check dmesg for conflicts
dmesg | grep -i "logitech\|hid" | tail -20

# Try unloading the generic hid_logitech first
sudo modprobe -r hid_logitech
sudo modprobe -r hid_logitech_dj  # Sometimes this exists
sudo modprobe -r hid_logitech_hidpp  # Sometimes this exists

# Then try loading yours
sudo modprobe hid-logitech-new
```

## Complete Test Script

Run this to test everything:

```bash
#!/bin/bash
cd ~/new-lg4ff

echo "=== Unloading ==="
sudo modprobe -r hid_logitech 2>/dev/null
sudo rmmod hid-logitech-new 2>/dev/null

echo "=== Building ==="
make clean && make

echo "=== Installing ==="
sudo make install

echo "=== Loading ==="
sudo modprobe hid-logitech-new

echo "=== Status ==="
if lsmod | grep -q "hid-logitech-new"; then
    echo "✓ Module loaded!"
    dmesg | grep -i "logitech\|rs50" | tail -5
    echo ""
    echo "Input devices:"
    ls -la /dev/input/event* 2>/dev/null | head -5
else
    echo "✗ Failed to load"
    dmesg | tail -10
fi
```

## Common Module Names

- ✅ Correct: `hid-logitech-new` (with hyphens)
- ❌ Wrong: `hid_logitech_new` (with underscores)
- ❌ Wrong: `hid_logitech-new` (mixed)

The Makefile uses `hid-logitech-new`, so always use that!
