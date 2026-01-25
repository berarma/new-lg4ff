# Fix: "probe with driver logitech failed with error -1" and "no inputs found"

## The Problem

Module is loaded (`hid_logitech_new` shows in `lsmod`), but:
```
probe with driver logitech failed with error -1
no inputs found
```

## Analysis

The "no inputs found" error comes from the force feedback initialization code. This means:
1. ✅ Device is detected (046D:C276)
2. ✅ Module is loaded
3. ❌ HID report descriptor parsing or input initialization is failing
4. ❌ Force feedback setup can't find expected inputs

## Possible Causes

### 1. Multiple HID Interfaces

The RS50 might expose multiple HID interfaces, and the driver might be trying to probe the wrong one. Notice in dmesg:
- `0003:046D:C276.0013` - probe failed
- `0003:046D:C276.0014` - no inputs found  
- `0003:046D:C276.0015` - no inputs found

The device has multiple interfaces, and some might not be joystick inputs.

### 2. HID Report Descriptor Issue

The RS50 might have a different HID report descriptor structure than expected.

### 3. Input Mapping Issue

The input mapping might not be correctly configured for RS50.

## Solutions

### Solution 1: Check Full dmesg for More Details

```bash
# Get more context around the errors
sudo dmesg | grep -A 5 -B 5 "046D:C276" | tail -30
```

Look for any additional error messages or warnings.

### Solution 2: Verify Device Registration

Check if RS50 is properly registered:

```bash
# Check if device is in the driver table
grep -n "RS50\|c276" /sys/module/hid_logitech_new/parameters/* 2>/dev/null || echo "No parameters"

# Check HID device info
cat /sys/bus/hid/devices/*/uevent | grep -i "046D:C276" -A 10
```

### Solution 3: Check HID Report Descriptor

The device might need a custom report descriptor fix. Check if there are any "Invalid code" messages:

```bash
sudo dmesg | grep -i "invalid code"
```

If you see messages like "Invalid code 768 type 1", the HID report descriptor might need fixing.

### Solution 4: Try Unloading and Reloading

Sometimes the probe order matters:

```bash
# Unload everything
sudo modprobe -r hid-logitech
sudo modprobe -r hid-generic

# Reload in order
sudo modprobe hid-generic
sudo modprobe hid-logitech

# Check dmesg
sudo dmesg | grep -i logitech | tail -10
```

### Solution 5: Check if Input Devices Are Created Anyway

Even with "no inputs found", some devices might still work:

```bash
# Check for input devices
ls -la /dev/input/js* /dev/input/event*

# Try jstest anyway
jstest /dev/input/js0  # Adjust number
```

### Solution 6: Verify RS50 Implementation

Double-check that RS50 is correctly added to all necessary places:

1. **Device table** (`hid-lg.c` line ~908):
   ```c
   { HID_USB_DEVICE(USB_VENDOR_ID_LOGITECH, USB_DEVICE_ID_LOGITECH_RS50_WHEEL),
       .driver_data = LG_NOGET | LG_FF4 },
   ```

2. **Input mapping** (`hid-lg.c` line ~711):
   ```c
   case USB_DEVICE_ID_LOGITECH_RS50_WHEEL:
       field->application = HID_GD_MULTIAXIS;
   ```

3. **Force feedback table** (`hid-lg4ff.c` line ~246):
   ```c
   {USB_DEVICE_ID_LOGITECH_RS50_WHEEL,
       lg4ff_wheel_effects, 40, 270, 0, NULL},
   ```

## Diagnostic Commands

Run these to gather more information:

```bash
# 1. Full device info
lsusb -v -d 046d:c276 | less

# 2. HID device details
find /sys/bus/hid/devices -name "*046D:C276*" -exec cat {}/uevent \;

# 3. Check all logitech-related messages
sudo dmesg | grep -i logitech > logitech-dmesg.txt
cat logitech-dmesg.txt

# 4. Check module parameters
modinfo hid-logitech-new

# 5. Check if inputs exist despite error
ls -la /dev/input/ | grep -E "js|event"
```

## Expected vs Actual

**Expected after successful probe:**
```
logitech 0003:046D:C276.0001: Force feedback support for Logitech Gaming Wheels
logitech 0003:046D:C276.0001: Hires timer: period = 2 ms
```

**Actual (current error):**
```
logitech 0003:046D:C276.0013: probe with driver logitech failed with error -1
logitech 0003:046D:C276.0014: no inputs found
```

## Next Steps

1. **Gather diagnostics** using the commands above
2. **Check if inputs work anyway** - sometimes the error is misleading
3. **Review HID report descriptor** - might need custom handling
4. **Check if it's an interface selection issue** - RS50 might have multiple interfaces

The fact that the module loads and device is detected is good progress. The probe failure suggests the HID parsing or input initialization needs investigation.
