# Build Error Fix: gcc-12 Issues

## Problem 1: gcc-12 not found
The kernel was built with `gcc-12`, but your system doesn't have it installed. You'll see:
```
/bin/sh: 1: gcc-12: not found
```

## Problem 2: gcc-12 symlink points to wrong version
If you created a symlink from gcc-12 to gcc-11, you'll see:
```
gcc-12: error: unrecognized command-line option '-ftrivial-auto-var-init=zero'
```

This happens because gcc-11 doesn't support flags that gcc-12 uses.

## Solution: Fix gcc-12

### Step 1: Remove incorrect symlink (if exists)
```bash
# Check if symlink exists
ls -la /usr/bin/gcc-12

# If it's a symlink pointing to gcc or gcc-11, remove it:
sudo rm /usr/bin/gcc-12
```

### Step 2: Install/Reinstall real gcc-12
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install --reinstall gcc-12

# Verify it's the real gcc-12
gcc-12 --version
# Should show: gcc-12 (Ubuntu 12.3.0-...) 12.3.0
```

### Step 3: Build the module
```bash
make
sudo make install
sudo make load
```

### Quick Fix Script
Run the automated fix script:
```bash
sudo ./FIX_GCC12.sh
```

## Why This Happens
Kernel modules must be built with a compatible compiler. The kernel build system checks the compiler version and may prefer the exact version used to build the kernel. However, using a compatible GCC version (like gcc 11 when kernel was built with gcc 12) usually works fine for module building.

## Verification
After building, check that the module was created:
```bash
ls -lh *.ko
```

You should see `hid-logitech-new.ko` file.
