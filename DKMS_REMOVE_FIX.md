# How to Remove Old DKMS Module

## The Problem

DKMS won't let you install a new module if one with the same name and version already exists:
```
Error! DKMS tree already contains: new-lg4ff-0.5.0
You cannot add the same module/version combo more than once.
```

## Solution: Remove the Old Module First

### Step 1: Check What's Installed

First, see what DKMS modules are installed:
```bash
dkms status
```

This will show something like:
```
new-lg4ff, 0.5.0, 6.14.0-37-generic, x86_64: installed
```

### Step 2: Remove the Old Module

Remove the existing module using the correct syntax:
```bash
sudo dkms remove new-lg4ff/0.5.0 --all
```

The `--all` flag removes it from all kernel versions.

**Alternative syntax (if the above doesn't work):**
```bash
sudo dkms remove -m new-lg4ff -v 0.5.0 --all
```

### Step 3: Verify Removal

Check that it's gone:
```bash
dkms status
```

You should see no `new-lg4ff` entries (or it might show "removed" status).

### Step 4: Install the New Module

Now you can install the updated module:
```bash
sudo dkms install /usr/src/new-lg4ff
```

Or if you're in the source directory:
```bash
sudo dkms install $(pwd)
```

## Alternative: Force Reinstall

If you want to force reinstall without removing first, you can use:
```bash
sudo dkms remove new-lg4ff/0.5.0 --all
sudo dkms install /usr/src/new-lg4ff
```

## If You Get "Module Not Found" Error

If `dkms remove` says the module doesn't exist, try:
```bash
# List all DKMS modules
dkms status

# Remove with exact name/version shown
sudo dkms remove <exact-module-name>/<exact-version> --all
```

## Complete Clean Removal (Nuclear Option)

If you want to completely clean everything:
```bash
# Remove the module
sudo dkms remove new-lg4ff/0.5.0 --all

# Remove source (optional)
sudo rm -rf /usr/src/new-lg4ff-0.5.0

# Then reinstall fresh
sudo dkms install /usr/src/new-lg4ff
```

## Quick Reference

```bash
# Check status
dkms status

# Remove old module
sudo dkms remove new-lg4ff/0.5.0 --all

# Install new module
sudo dkms install /usr/src/new-lg4ff

# Verify
dkms status
lsmod | grep hid_logitech
```
