# RS50 Driver Testing Guide

This guide helps you test the Logitech RS50 driver implementation.

## Quick Start

Run the automated test script:
```bash
./rs50-test.sh
```

This script will guide you through all testing steps.

## Manual Testing Steps

### 1. Identify Your RS50 Device ID

**Before building the driver**, you need to identify the actual USB device ID:

```bash
# Simple method
lsusb | grep -i logitech

# Or use the diagnostic tool
gcc -o rs50-diagnose rs50-diagnose.c -lusb-1.0
sudo ./rs50-diagnose
```

Look for your RS50 in the output and note the Product ID (e.g., `0xc297`).

**Update the device ID** in:
- `hid-ids.h`: Change `USB_DEVICE_ID_LOGITECH_RS50_WHEEL` definition
- `99-logitech-rs50.rules`: Update the `ATTRS{idProduct}` value

### 2. Build and Install the Driver

```bash
# Build the module
make

# Install (choose one method)
# Method A: DKMS (recommended)
sudo dkms install /usr/src/new-lg4ff

# Method B: Manual
sudo make install
sudo make load
```

### 3. Verify Driver Loading

```bash
# Check if module is loaded
lsmod | grep hid_logitech

# Check kernel messages
dmesg | grep -i logitech | tail -20
```

You should see messages like:
```
logitech 0003:046D:XXXX.XXXX: Force feedback support for Logitech Gaming Wheels
```

### 4. Check Device Nodes

```bash
# List input devices
ls -l /dev/input/js* /dev/input/event*

# Your RS50 should appear as a joystick device
# Note the device number (e.g., js0, event0)
```

### 5. Test Input (Wheel, Pedals, Buttons)

**Install jstest if needed:**
```bash
sudo apt-get install joystick  # Debian/Ubuntu
```

**Test with jstest:**
```bash
jstest /dev/input/js0  # Replace js0 with your device
```

**What to test:**
- **Wheel axis**: Rotate the wheel left/right - should see axis 0 (X) change
- **Pedals**: Press throttle and brake - should see axis 1 and 2 change
- **Buttons**: Press all buttons - should see button numbers light up

**Alternative: Use evtest for more detailed info:**
```bash
sudo apt-get install evtest
sudo evtest /dev/input/event0  # Replace with your event device
```

### 6. Test Force Feedback

**Check FF capabilities:**
```bash
# Find your event device number
cat /sys/class/input/js0/device/event  # Replace js0 with your device

# Check FF capabilities
cat /sys/class/input/event0/device/capabilities/ff
# Should show a non-zero hex value if FF is supported
```

**Test with a game:**
- Use a racing game that supports force feedback (e.g., Assetto Corsa, rFactor)
- Configure the game to use your RS50
- Test various FF effects (spring, damper, constant force, etc.)

**Test sysfs gain control:**
```bash
# Find sysfs path
ls -la /sys/bus/hid/drivers/logitech/*/

# Check current gain (0-65535)
cat /sys/bus/hid/drivers/logitech/0003:046D:XXXX.XXXX/gain

# Set gain (example: 50%)
echo 32767 | sudo tee /sys/bus/hid/drivers/logitech/0003:046D:XXXX.XXXX/gain

# Test autocenter
echo 32767 | sudo tee /sys/bus/hid/drivers/logitech/0003:046D:XXXX.XXXX/autocenter
```

### 7. Test Sysfs Entries

The driver should create several sysfs entries for configuration:

```bash
SYSFS_PATH="/sys/bus/hid/drivers/logitech/0003:046D:XXXX.XXXX/"

# Check available entries
ls -la $SYSFS_PATH

# Test reading values
cat $SYSFS_PATH/gain
cat $SYSFS_PATH/autocenter
cat $SYSFS_PATH/range
cat $SYSFS_PATH/combine_pedals

# Test writing values (requires root)
echo 32767 | sudo tee $SYSFS_PATH/gain
echo 16384 | sudo tee $SYSFS_PATH/autocenter
```

**Expected entries:**
- `gain`: Global force feedback gain (0-65535)
- `autocenter`: Autocenter strength (0-65535)
- `range`: Wheel range in degrees (read-only, should show 270)
- `combine_pedals`: Pedal combination mode (0, 1, or 2)

### 8. Test Udev Rules

```bash
# Check if rules are installed
ls -la /etc/udev/rules.d/99-logitech-rs50.rules

# Install if missing
sudo cp 99-logitech-rs50.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

# Check device properties
udevadm info -q all -n /dev/input/js0 | grep -i logitech
```

### 9. Test Combined Pedals (if applicable)

If your RS50 has separate throttle and brake pedals that can be combined:

```bash
# Set combine_pedals to 2 (combines throttle and brake)
echo 2 | sudo tee /sys/bus/hid/drivers/logitech/0003:046D:XXXX.XXXX/combine_pedals

# Test with jstest - should see combined axis
jstest /dev/input/js0
```

## Testing Checklist

Use this checklist to ensure everything works:

- [ ] RS50 USB device ID identified and updated in code
- [ ] Driver builds without errors
- [ ] Driver loads successfully (`lsmod | grep hid_logitech`)
- [ ] Device appears in kernel messages (`dmesg | grep logitech`)
- [ ] Input device nodes created (`/dev/input/js*`, `/dev/input/event*`)
- [ ] Wheel axis responds correctly (test with `jstest`)
- [ ] Throttle pedal works (test with `jstest`)
- [ ] Brake pedal works (test with `jstest`)
- [ ] All buttons work (test with `jstest`)
- [ ] Force feedback capabilities detected
- [ ] Sysfs entries exist and are accessible
- [ ] Gain can be read and written
- [ ] Autocenter can be read and written
- [ ] Range shows correct value (270 degrees)
- [ ] Udev rules installed and active
- [ ] Force feedback works in games/applications
- [ ] No kernel errors or warnings

## Troubleshooting

### Device Not Detected

1. **Check USB connection:**
   ```bash
   lsusb | grep -i logitech
   ```

2. **Verify device ID is correct:**
   - Check `hid-ids.h` has the correct device ID
   - Check `99-logitech-rs50.rules` has matching ID

3. **Check driver is loaded:**
   ```bash
   lsmod | grep hid_logitech
   sudo modprobe hid-logitech-new
   ```

4. **Check kernel messages:**
   ```bash
   dmesg | tail -50
   ```

### Force Feedback Not Working

1. **Verify FF capabilities:**
   ```bash
   cat /sys/class/input/event0/device/capabilities/ff
   # Should be non-zero
   ```

2. **Check sysfs gain:**
   ```bash
   cat /sys/bus/hid/drivers/logitech/*/gain
   # Try setting it higher if too low
   ```

3. **Test with a known working game:**
   - Some games may not support all wheels
   - Try multiple games to isolate the issue

### Wrong Wheel Range

If the wheel range is incorrect (not 270 degrees):

1. **Check current range:**
   ```bash
   cat /sys/bus/hid/drivers/logitech/*/range
   ```

2. **Update in code:**
   - Edit `hid-lg4ff.c`
   - Find RS50 entry in `lg4ff_devices` array
   - Adjust `min_range` and `max_range` values
   - Rebuild and reload driver

### Input Not Working

1. **Check device permissions:**
   ```bash
   ls -l /dev/input/js0
   # Should be readable by your user or in 'input' group
   ```

2. **Test with evtest:**
   ```bash
   sudo evtest /dev/input/event0
   # More detailed than jstest
   ```

3. **Check for conflicting drivers:**
   ```bash
   lsmod | grep -i logitech
   # Should only show hid_logitech_new
   ```

## Advanced Testing

### Monitor Force Feedback Levels

```bash
# Watch peak FF level (clipping detection)
watch -n 0.1 'cat /sys/bus/hid/drivers/logitech/*/peak_ffb_level'
```

### Test Individual FF Effects

Create a simple test program or use existing tools:
- `fftest` (if available)
- Custom applications using Linux FF API
- Games with FF test modes

### Performance Testing

Monitor driver performance:
```bash
# Check for errors/warnings
dmesg | grep -i "logitech\|error\|warn"

# Monitor system resources
top -p $(pgrep -f hid-logitech)
```

## Reporting Issues

If you encounter problems:

1. **Collect information:**
   ```bash
   # Kernel version
   uname -r
   
   # Driver version
   modinfo hid-logitech-new
   
   # Device info
   lsusb -v -d 046d:XXXX
   
   # Kernel messages
   dmesg | grep -i logitech > logitech-dmesg.txt
   
   # Sysfs entries
   ls -la /sys/bus/hid/drivers/logitech/*/ > sysfs-entries.txt
   ```

2. **Test results:**
   - Which tests passed/failed
   - Specific error messages
   - Steps to reproduce issues

3. **Hardware info:**
   - RS50 model/variant
   - USB device ID
   - Any modifications to the wheel

## Next Steps After Testing

Once testing is complete:

1. **Verify all functionality works**
2. **Document any deviations from expected behavior**
3. **Update device ID if placeholder was used**
4. **Adjust capabilities if hardware differs from assumptions**
5. **Prepare for upstream submission** (if applicable)
