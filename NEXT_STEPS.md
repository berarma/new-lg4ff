# Next Steps: Testing and Client Delivery

## ✅ Current Status
- [x] RS50 driver implementation complete
- [x] Build environment fixed (gcc-12 working)
- [x] Driver builds successfully

## Step 1: Verify Device ID is Correct

Before testing, make sure the RS50 device ID is set correctly:

1. **Check the device ID in code:**
   ```bash
   grep -n "RS50\|c276" hid-ids.h
   grep -n "RS50\|c276" 99-logitech-rs50.rules
   ```

2. **The device ID should be `0xc276`** (from your lsusb output: `046d:c276`)

3. **If it's still the placeholder (`0xc296`), update it:**
   - In `hid-ids.h`: Change `USB_DEVICE_ID_LOGITECH_RS50_WHEEL` to `0xc276`
   - In `99-logitech-rs50.rules`: Change `c296` to `c276`

## Step 2: Build and Load the Driver

```bash
# Clean any previous builds
make clean

# Build the module
make

# Verify the .ko file was created
ls -lh *.ko

# Install the module
sudo make install

# Load the module
sudo make load

# Verify it's loaded
lsmod | grep hid_logitech
```

You should see `hid_logitech_new` in the output.

## Step 3: Test with Physical Hardware

### Option A: If you have the RS50 connected

1. **Connect the RS50 wheel** (with USB passthrough if in VM)

2. **Run the test script:**
   ```bash
   ./rs50-test.sh
   ```

3. **Check kernel messages:**
   ```bash
   dmesg | grep -i logitech | tail -10
   ```
   You should see messages about RS50 being detected.

4. **Test input:**
   ```bash
   # Install if needed: sudo apt-get install joystick
   jstest /dev/input/js0  # Adjust js0 to your device
   ```
   - Rotate the wheel - axis 0 should change
   - Press pedals - axes 1 and 2 should change
   - Press buttons - button numbers should light up

5. **Test force feedback:**
   - Use a racing game that supports force feedback
   - Or test sysfs entries:
     ```bash
     ls -la /sys/bus/hid/drivers/logitech/*/
     cat /sys/bus/hid/drivers/logitech/*/gain
     ```

### Option B: If client will test (recommended)

Since the client mentioned they have the RS50 for testing, you can prepare everything for them to test.

## Step 4: Prepare for Client Delivery

### Files to Include

1. **Core driver files** (already in repo):
   - `hid-ids.h` (with RS50 device ID)
   - `hid-lg.c` (with RS50 registration)
   - `hid-lg4ff.c` (with RS50 force feedback support)
   - `99-logitech-rs50.rules` (udev rules)

2. **Documentation** (already created):
   - `RS50_IMPLEMENTATION.md` - Implementation details
   - `RS50_SETUP.md` - Setup instructions
   - `RS50_TESTING.md` - Testing guide
   - `README.md` - Updated with RS50 support

3. **Testing tools** (already created):
   - `rs50-test.sh` - Automated test script
   - `rs50-diagnose.c` - Device diagnostic tool
   - `rs50-diagnose.sh` - Simple diagnostic script

4. **Build files**:
   - `Makefile` - Build configuration
   - `dkms.conf` - DKMS configuration (if using DKMS)

### Create Delivery Package

```bash
# Create a summary of changes
git status
git diff  # Review all changes

# Or create a patch file
git format-patch origin/master --stdout > rs50-support.patch
```

### Client Testing Instructions

Provide the client with:

1. **Quick Start:**
   ```bash
   # 1. Verify device ID matches their RS50
   lsusb | grep -i logitech
   # Should show: 046d:c276 (or their device ID)
   
   # 2. Update device ID if different (in hid-ids.h and 99-logitech-rs50.rules)
   
   # 3. Build and install
   make
   sudo make install
   sudo make load
   
   # 4. Connect RS50 and test
   ./rs50-test.sh
   ```

2. **Reference Documentation:**
   - `RS50_SETUP.md` - Detailed setup guide
   - `RS50_TESTING.md` - Comprehensive testing guide

## Step 5: Verification Checklist

Before sending to client, verify:

- [ ] Device ID is correct (`0xc276` or client's actual ID)
- [ ] Driver builds without errors
- [ ] All documentation is complete
- [ ] Test scripts are executable
- [ ] Udev rules file is correct
- [ ] README mentions RS50 support
- [ ] Code follows kernel coding standards
- [ ] No linter errors

## Step 6: Code Review Items

Check these implementation details:

- [ ] RS50 added to device table in `hid-lg.c`
- [ ] RS50 added to `lg4ff_devices` array in `hid-lg4ff.c`
- [ ] Device ID defined in `hid-ids.h`
- [ ] Udev rules created
- [ ] Input mapping correct (HID_GD_MULTIAXIS)
- [ ] Force feedback capabilities match hardware
- [ ] Wheel range settings appropriate (40-270 degrees)

## Step 7: Send to Client

### What to Include:

1. **The entire repository** (or a patch file)
2. **Quick start instructions:**
   ```
   1. Update device ID if needed (check with lsusb)
   2. Build: make
   3. Install: sudo make install
   4. Load: sudo make load
   5. Connect RS50
   6. Test: ./rs50-test.sh
   ```

3. **Key files to highlight:**
   - Modified: `hid-ids.h`, `hid-lg.c`, `hid-lg4ff.c`
   - New: `99-logitech-rs50.rules`
   - Documentation: `RS50_SETUP.md`, `RS50_TESTING.md`

4. **Testing expectations:**
   - Client should test with their actual RS50 hardware
   - They can run diagnostics and provide feedback
   - They should verify all functionality (inputs, force feedback)

## Step 8: Client Feedback Loop

Ask the client to:

1. **Test and report:**
   - Does the device get detected?
   - Do inputs work (wheel, pedals, buttons)?
   - Does force feedback work?
   - Any errors in dmesg?

2. **Provide diagnostics:**
   ```bash
   # Run diagnostic tool
   gcc -o rs50-diagnose rs50-diagnose.c -lusb-1.0
   sudo ./rs50-diagnose
   
   # Check kernel messages
   dmesg | grep -i logitech > logitech-dmesg.txt
   
   # Test input
   jstest /dev/input/js0 > jstest-output.txt
   ```

3. **Report any issues:**
   - Build errors
   - Runtime errors
   - Missing functionality
   - Incorrect behavior

## Quick Command Reference

```bash
# Build
make

# Install
sudo make install

# Load
sudo make load

# Unload (to restore original driver)
sudo make unload

# Check status
lsmod | grep hid_logitech
dmesg | grep -i logitech

# Test
./rs50-test.sh
jstest /dev/input/js0

# Check sysfs
ls -la /sys/bus/hid/drivers/logitech/*/
```

## Next Actions

1. **If you have RS50 hardware:** Test it now following Step 3
2. **If client will test:** Prepare delivery package (Step 4-7)
3. **Either way:** Verify device ID is correct before proceeding

Good luck! 🎮
