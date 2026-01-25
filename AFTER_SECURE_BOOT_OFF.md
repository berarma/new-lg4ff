# After Disabling Secure Boot: Next Steps

## Important: Reboot Required

If you just disabled Secure Boot, you **must reboot** for the change to take effect.

## Steps After Disabling Secure Boot

### 1. Reboot Your System
```bash
sudo reboot
```

### 2. After Reboot, Unload and Reload the Module

```bash
# Unload the old (tainted) module
sudo modprobe -r hid-logitech-new

# Load it fresh
sudo modprobe hid-logitech-new
```

### 3. Verify It's Working

Check dmesg for success messages:
```bash
sudo dmesg | grep -i logitech | tail -10
```

You should now see:
```
logitech 0003:046D:C276.0001: Force feedback support for Logitech Gaming Wheels
logitech 0003:046D:C276.0001: Hires timer: period = 2 ms
```

**NOT** the "module verification failed" message.

### 4. Check Module Status

```bash
# Verify module is loaded
lsmod | grep hid_logitech

# Should show: hid_logitech_new
```

### 5. Test the Device

```bash
# Check input devices
ls -l /dev/input/js* /dev/input/event*

# Test with jstest (if installed)
jstest /dev/input/js0  # Adjust number as needed

# Or run the test script
./rs50-test.sh
```

## If It Still Doesn't Work

If you still see errors after rebooting:

1. **Verify Secure Boot is actually off:**
   ```bash
   mokutil --sb-state
   ```
   Should show: "SecureBoot disabled"

2. **Check if module is still tainted:**
   ```bash
   cat /proc/sys/kernel/tainted
   ```
   If it shows a non-zero value, you may need to reboot again.

3. **Try manual unload/reload:**
   ```bash
   sudo rmmod hid-logitech-new
   sudo modprobe hid-logitech-new
   ```

4. **Check for conflicting modules:**
   ```bash
   lsmod | grep hid
   ```
   Make sure `hid_logitech` (old module) is not loaded. If it is:
   ```bash
   sudo modprobe -r hid-logitech
   sudo modprobe hid-logitech-new
   ```

## Expected Success Output

After everything works, `dmesg | grep logitech` should show:
- ✅ Device detected: `Logitech RS50 Base for PlayStation/PC`
- ✅ Force feedback support message
- ✅ No "verification failed" messages
- ✅ No "probe failed" errors

## Quick Checklist

- [ ] Rebooted after disabling Secure Boot
- [ ] Unloaded old module: `sudo modprobe -r hid-logitech-new`
- [ ] Reloaded module: `sudo modprobe hid-logitech-new`
- [ ] Checked dmesg for success messages
- [ ] Verified module loaded: `lsmod | grep hid_logitech`
- [ ] Tested device: `./rs50-test.sh` or `jstest`
