# Logitech RS50 Racing Wheel Setup Guide

## Device Identification

The RS50 driver uses a placeholder USB device ID (0xc296) that needs to be updated with the actual device ID from your wheel.

### Step 1: Identify Your RS50 USB Device ID

**Option A: Using lsusb (Simple)**
```bash
# Plug in your RS50 wheel, then run:
lsusb | grep -i logitech
```

Look for a device with vendor ID `046d` (Logitech). The product ID will be shown as `046d:XXXX` where XXXX is the device ID in hexadecimal.

**Option B: Using the Diagnostic Tool**
```bash
# Compile the diagnostic tool (requires libusb-1.0-dev):
gcc -o rs50-diagnose rs50-diagnose.c -lusb-1.0

# Run it (requires root):
sudo ./rs50-diagnose
```

This will show detailed information about all connected Logitech devices, including the RS50.

### Step 2: Update the Device ID

Once you have the actual USB device ID, update the following files:

1. **hid-ids.h**: Update the `USB_DEVICE_ID_LOGITECH_RS50_WHEEL` definition:
   ```c
   #define USB_DEVICE_ID_LOGITECH_RS50_WHEEL	0xXXXX  // Replace XXXX with actual ID
   ```

2. **99-logitech-rs50.rules**: Update the udev rule:
   ```
   ATTRS{idProduct}=="XXXX"  // Replace XXXX with actual ID (lowercase hex)
   ```

### Step 3: Build and Install

```bash
# Build the module
make

# Install (using DKMS recommended)
sudo dkms install /usr/src/new-lg4ff

# Or install manually
sudo make install
sudo make load
```

### Step 4: Install Udev Rules

```bash
# Copy the udev rules file
sudo cp 99-logitech-rs50.rules /etc/udev/rules.d/

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### Step 5: Verify Installation

After plugging in your RS50:

1. **Check kernel messages:**
   ```bash
   dmesg | grep -i logitech
   ```
   You should see a message like:
   ```
   logitech 0003:046D:XXXX.XXXX: Force feedback support for Logitech Gaming Wheels
   ```

2. **Check input device:**
   ```bash
   ls -l /dev/input/js* /dev/input/event*
   ```
   Your RS50 should appear as a joystick device.

3. **Test with jstest:**
   ```bash
   # Install jstest if needed: sudo apt-get install joystick
   jstest /dev/input/js0  # Adjust js0 to your device number
   ```

4. **Check sysfs entries:**
   ```bash
   ls -la /sys/bus/hid/drivers/logitech/*/
   ```
   You should see entries for gain, range, autocenter, etc.

## Device Capabilities

The RS50 driver is configured with the following capabilities (may need adjustment based on actual hardware):

- **Force Feedback**: Full support for all standard FF effects
- **Wheel Range**: 270 degrees (40-270 degrees adjustable)
- **Inputs**: Wheel axis, pedals, buttons
- **Effects Supported**: Constant, Spring, Damper, Autocenter, Periodic (Sine, Square, Triangle, Saw), Ramp, Friction

## Troubleshooting

### Device Not Detected

1. Verify the USB device ID is correct in `hid-ids.h`
2. Check that the module is loaded: `lsmod | grep hid_logitech`
3. Check kernel messages: `dmesg | tail -50`

### Force Feedback Not Working

1. Verify the device supports force feedback (check with `jstest`)
2. Check sysfs entries exist: `/sys/bus/hid/drivers/logitech/*/gain`
3. Test with a simple FF application

### Wrong Wheel Range

If the wheel range is incorrect, you may need to adjust the min_range and max_range values in `hid-lg4ff.c` for the RS50 entry in the `lg4ff_devices` array.

## Contributing

If you discover the actual USB device ID or need to adjust capabilities, please:

1. Update the device ID in `hid-ids.h` and `99-logitech-rs50.rules`
2. Test all functionality (inputs, force feedback, range)
3. Report any issues or submit improvements

## Notes

- The RS50 is assumed to have similar capabilities to the MOMO wheel (270-degree range)
- If your RS50 has different capabilities, the driver may need adjustments
- The placeholder device ID (0xc296) should be replaced with the actual ID from your device
