# Reply to Client: Module Name Mismatch

## Suggested Reply

**The module is actually installed successfully! The issue is a name mismatch.**

Looking at your `dkms.conf`, DKMS installs the module as `hid-logitech` (to replace the old one), not `hid-logitech-new`.

### Quick Fix: Use the Correct Name

Try loading it with the name DKMS gave it:

```bash
# Unload old module first (if it's loaded)
sudo modprobe -r hid-logitech

# Load the new module (it's installed as "hid-logitech")
sudo modprobe hid-logitech
```

Then verify:
```bash
# Check it's loaded
lsmod | grep hid_logitech

# Check dmesg for success
sudo dmesg | grep -i logitech | tail -5
```

You should see:
```
logitech 0003:046D:C276.0001: Force feedback support for Logitech Gaming Wheels
```

### Why This Happens

In `dkms.conf`, the module is configured to install as `hid-logitech` (to replace the in-kernel module), even though it's built as `hid-logitech-new`. The internal name is still `hid_logitech_new`, but modprobe uses the installed name.

### Alternative: Update depmod

If the above doesn't work, try:

```bash
sudo depmod -a
sudo modprobe hid-logitech
```

**The module is there - you just need to load it with the name `hid-logitech` instead of `hid-logitech-new`.**
