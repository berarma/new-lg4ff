# Fix: Module Name Mismatch After DKMS Install

## The Problem

DKMS installs successfully, but `modprobe hid-logitech-new` fails with:
```
FATAL: Module hid-logitech-new not found
```

## Root Cause

Looking at `dkms.conf`:
- `BUILT_MODULE_NAME[0]="hid-logitech-new"` (what it builds)
- `DEST_MODULE_NAME[0]="hid-logitech"` (what it installs as)

**DKMS is installing the module as `hid-logitech`, not `hid-logitech-new`!**

## Solution 1: Load with Correct Name (Quick Fix)

The module is installed, but with a different name. Try:

```bash
# Unload the old module first (if loaded)
sudo modprobe -r hid-logitech

# Load the new one (it's installed as "hid-logitech")
sudo modprobe hid-logitech
```

Then verify:
```bash
lsmod | grep hid_logitech
# Should show: hid_logitech_new (internal name)
```

## Solution 2: Update depmod (Alternative)

Sometimes `depmod` needs to be run manually:

```bash
sudo depmod -a
sudo modprobe hid-logitech-new
```

## Solution 3: Fix dkms.conf (Permanent Fix)

If you want to keep the name as `hid-logitech-new`, update `dkms.conf`:

```bash
# Edit dkms.conf
nano dkms.conf
```

Change:
```
DEST_MODULE_NAME[0]="hid-logitech"
```

To:
```
DEST_MODULE_NAME[0]="hid-logitech-new"
```

Then reinstall:
```bash
sudo dkms remove new-lg4ff/0.5.0 --all
sudo dkms install $(pwd)
sudo modprobe hid-logitech-new
```

## Solution 4: Verify Installation Location

Check where the module actually is:

```bash
# Find the module file
find /lib/modules/$(uname -r) -name "*logitech*.ko"

# Check what's in the updates directory
ls -la /lib/modules/$(uname -r)/updates/dkms/

# Check module dependencies
modinfo hid-logitech
modinfo hid-logitech-new
```

## Recommended Quick Fix

**Just use the installed name:**

```bash
# Unload old module
sudo modprobe -r hid-logitech 2>/dev/null || true

# Load new module (it's installed as "hid-logitech")
sudo modprobe hid-logitech

# Verify
lsmod | grep hid_logitech
sudo dmesg | grep -i logitech | tail -5
```

The module **is** installed - you just need to load it with the name DKMS gave it (`hid-logitech`), not the build name (`hid-logitech-new`).

## Why This Happens

DKMS uses `DEST_MODULE_NAME` to replace the in-kernel module. Since the original module is `hid-logitech`, DKMS installs the new one with the same name to replace it. The internal module name is still `hid_logitech_new`, but the file/modprobe name is `hid-logitech`.
