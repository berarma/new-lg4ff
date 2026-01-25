# Complete Step-by-Step Testing Guide for RS50

## Overview
This guide will take you through testing the RS50 driver from start to finish. Follow each step in order and report results.

---

## Pre-Testing Checklist

Before starting, make sure:
- [ ] RS50 wheel is connected via USB
- [ ] You have sudo/root access
- [ ] You're in the project directory: `cd ~/new-lg4ff`
- [ ] You've rebuilt the driver: `make clean && make`

---

## Step 1: Verify Module is Loaded

### Commands:
```bash
# Check if module is loaded
lsmod | grep "hid-logitech-new"

# Check kernel messages
dmesg | grep -i "logitech\|rs50\|c276" | tail -10
```

### Expected Result:
✅ **PASS:** You see `hid-logitech-new` in the output  
✅ **PASS:** dmesg shows RS50 detected (look for "RS50" or "c276")

### If FAIL:
```bash
# Load the module
sudo modprobe hid-logitech-new

# Or if using manual install:
sudo make install
sudo modprobe hid-logitech-new
```

### Report:
- [ ] Module loaded? Yes/No
- [ ] RS50 detected in dmesg? Yes/No
- [ ] Copy relevant dmesg lines

---

## Step 2: Find Your Input Device

### Commands:
```bash
# List all input devices
ls -la /dev/input/event*

# Or use evtest to see all devices
evtest
# (Don't select anything yet, just see the list)
```

### Expected Result:
✅ **PASS:** You see a device with "Logitech" or "RS50" in the name  
✅ **PASS:** Device number is shown (e.g., event20)

### If FAIL:
```bash
# Check if device is connected
lsusb | grep -i logitech

# Check dmesg for errors
dmesg | tail -20
```

### Report:
- [ ] Found RS50 device? Yes/No
- [ ] Device number? (e.g., event20)
- [ ] Device name? (copy the full name)

---

## Step 3: Test Basic Input Detection

### Commands:
```bash
# Run evtest on your RS50 device (replace 20 with your device number)
sudo evtest /dev/input/event20
```

### What to Do:
1. **Don't touch the wheel yet**
2. **Watch the terminal** - you should see events appearing
3. **Note the values** you see (e.g., 32670, 32671, 32672)

### Expected Result:
✅ **PASS:** Events are appearing continuously  
✅ **PASS:** Values are in range 0-65535  
✅ **PASS:** Values are around 32670-32767 (center range)

### If FAIL:
- No events appear → Input not working, check Step 1
- Values are always 0 → Input not working, check dmesg for errors

### Report:
- [ ] Events appearing? Yes/No
- [ ] What values do you see when idle? (e.g., 32670-32672)
- [ ] Copy 3-5 lines of output

---

## Step 4: Test Large Wheel Movements

### Commands:
(Still in evtest - don't exit yet)

### What to Do:
1. **Rotate wheel FULL LEFT** (as far as it goes)
   - Watch the terminal
   - Note the lowest value you see
   - Hold it there for 2 seconds

2. **Rotate wheel FULL RIGHT** (as far as it goes)
   - Watch the terminal
   - Note the highest value you see
   - Hold it there for 2 seconds

3. **Return wheel to CENTER**
   - Watch the terminal
   - Note the center value

### Expected Result:
✅ **PASS:** Full left shows values close to 0 (0-1000 range)  
✅ **PASS:** Full right shows values close to 65535 (64535-65535 range)  
✅ **PASS:** Center shows values around 32767 (32600-32900 range)

### If FAIL:
- Values don't change much → Axis mapping issue
- Values stay the same → Input not working properly
- Values go wrong direction → Axis inverted

### Report:
- [ ] Full left value: _____
- [ ] Full right value: _____
- [ ] Center value: _____
- [ ] Do values change dramatically? Yes/No

---

## Step 5: Test Buttons

### Commands:
(Still in evtest)

### What to Do:
1. **Press each button** on the wheel one by one
2. **Watch the terminal** for `EV_KEY` events
3. **Note which buttons work**

### Expected Result:
✅ **PASS:** Each button press shows:
```
Event: type 1 (EV_KEY), code XXX (BTN_XXX), value 1
Event: type 1 (EV_KEY), code XXX (BTN_XXX), value 0
```
- `value 1` = button pressed
- `value 0` = button released

### If FAIL:
- No events when pressing → Buttons not working
- Events appear but wrong buttons → Button mapping issue

### Report:
- [ ] How many buttons work? _____
- [ ] Do all buttons work? Yes/No
- [ ] Copy 2-3 button event lines

---

## Step 6: Test Pedals (if RS50 has them)

### Commands:
(Still in evtest)

### What to Do:
1. **Press gas pedal** (if present)
   - Watch for `ABS_Y` or `ABS_Z` events
   - Note the value range

2. **Press brake pedal** (if present)
   - Watch for `ABS_RZ` or similar events
   - Note the value range

3. **Press clutch pedal** (if present)
   - Watch for events
   - Note the value range

### Expected Result:
✅ **PASS:** Pedal press changes values from low to high (or high to low)  
✅ **PASS:** Values change smoothly as you press

### If FAIL:
- No events when pressing pedals → Pedals not detected
- Values don't change → Pedal axis not working

### Report:
- [ ] Does RS50 have pedals? Yes/No
- [ ] Do pedals work? Yes/No
- [ ] What axis codes do you see? (ABS_Y, ABS_Z, ABS_RZ, etc.)

---

## Step 7: Exit evtest and Check Summary

### Commands:
```bash
# Press Ctrl+C to exit evtest
```

### Summary Check:
Review what you found:
- [ ] Input events working? Yes/No
- [ ] Large movements work? Yes/No
- [ ] Buttons work? Yes/No
- [ ] Pedals work? (if applicable) Yes/No

---

## Step 8: Test in BeamNG.drive

### Preparation:
1. **Close evtest** (if still running)
2. **Start BeamNG.drive**

### In BeamNG:
1. **Go to Settings → Controls**
2. **Select "Steering Wheel" or "Gamepad"**
3. **Configure controls:**
   - Steering: Should auto-detect wheel rotation
   - Gas: Map to pedal (if present)
   - Brake: Map to pedal (if present)
   - Buttons: Map as needed

4. **Important Settings:**
   - **Deadzone:** Set to 2-5% (this ignores small fluctuations)
   - **Sensitivity:** Adjust as needed
   - **Invert:** Only if wheel turns wrong direction

5. **Test in game:**
   - Rotate wheel → Car should steer
   - Press buttons → Actions should trigger
   - Press pedals → Car should accelerate/brake

### Expected Result:
✅ **PASS:** Wheel controls steering in game  
✅ **PASS:** Buttons work in game  
✅ **PASS:** Pedals work in game (if present)  
✅ **PASS:** No constant drift (deadzone prevents small fluctuations)

### If FAIL:
- Wheel not detected → Check Step 1 (module loaded?)
- Wheel detected but no response → Check axis mapping in game settings
- Constant drift → Increase deadzone to 5-10%
- Wrong direction → Enable "Invert" in game settings

### Report:
- [ ] BeamNG detects wheel? Yes/No
- [ ] Steering works? Yes/No
- [ ] Buttons work? Yes/No
- [ ] Any issues? Describe

---

## Step 9: Test Force Feedback (if applicable)

### Note:
Force feedback may not work if RS50 doesn't have an output report. This is expected.

### Commands:
```bash
# Check if force feedback is available
dmesg | grep -i "force feedback\|ff\|output report"

# Check device capabilities
cat /sys/class/input/input*/device/name | grep -i logitech
# Then check that device's capabilities
```

### In BeamNG:
1. **Go to Settings → Force Feedback**
2. **Enable force feedback** (if option exists)
3. **Test:**
   - Drive into a wall → Should feel resistance
   - Hit bumps → Should feel vibration
   - Turn wheel → Should feel centering force

### Expected Result:
✅ **PASS:** Force feedback works (if supported)  
⚠️ **OK:** Force feedback not available (if RS50 doesn't support it - this is normal)

### Report:
- [ ] Force feedback available? Yes/No
- [ ] Force feedback works? Yes/No/Not applicable

---

## Step 10: Final Verification

### Commands:
```bash
# Final check - everything should be working
dmesg | grep -i "logitech\|rs50" | tail -5

# Verify module is still loaded
lsmod | grep "hid-logitech-new"
```

### Final Checklist:
- [ ] Module loaded and stable
- [ ] Input events working
- [ ] Large movements work (full range)
- [ ] Buttons work
- [ ] Pedals work (if applicable)
- [ ] Works in BeamNG
- [ ] No constant drift (deadzone set)

---

## Troubleshooting

### Problem: No events in evtest
**Solution:**
1. Check module is loaded (Step 1)
2. Check device is connected: `lsusb | grep logitech`
3. Try unplugging and replugging USB
4. Check dmesg for errors

### Problem: Values don't change when moving wheel
**Solution:**
1. Check you're moving the wheel significantly (not just tiny movements)
2. Check axis mapping - might be wrong axis
3. Check dmesg for errors

### Problem: Constant drift in games
**Solution:**
1. Set deadzone to 5-10% in game settings
2. Check if wheel is physically centered
3. Check if values are stable when wheel is centered

### Problem: Buttons don't work
**Solution:**
1. Check button events in evtest (Step 5)
2. If events appear in evtest but not in game → Game mapping issue
3. If no events in evtest → Hardware or driver issue

---

## Complete Test Report Template

Copy this and fill it out:

```
=== RS50 Driver Test Report ===

Step 1 - Module Loaded:
[ ] Yes [ ] No
dmesg output: ________________

Step 2 - Device Found:
[ ] Yes [ ] No
Device: /dev/input/event___

Step 3 - Basic Input:
[ ] Yes [ ] No
Idle values: _______________

Step 4 - Large Movements:
[ ] Yes [ ] No
Full left: _____
Full right: _____
Center: _____

Step 5 - Buttons:
[ ] Yes [ ] No
Working buttons: _____ / _____

Step 6 - Pedals:
[ ] Yes [ ] No (N/A if no pedals)
Working: ________________

Step 7 - BeamNG:
[ ] Yes [ ] No
Issues: ________________

Step 8 - Force Feedback:
[ ] Yes [ ] No [ ] N/A
Status: ________________

Overall Status:
[ ] Working [ ] Partially Working [ ] Not Working
Notes: ________________
```

---

## Next Steps After Testing

### If Everything Works:
✅ **Success!** The driver is working correctly.  
✅ Set deadzone in games to handle small fluctuations.  
✅ Enjoy using your RS50!

### If Something Doesn't Work:
1. **Note which step failed**
2. **Copy error messages from dmesg**
3. **Copy evtest output**
4. **Report back with details**

We'll fix any issues based on your test results.

---

## Quick Reference

**Key Commands:**
```bash
# Check module
lsmod | grep "hid-logitech-new"

# Check device
evtest

# Check dmesg
dmesg | grep -i "logitech\|rs50" | tail -10

# Test input
sudo evtest /dev/input/event20  # Replace 20 with your device
```

**Key Values:**
- Center: ~32767 (or 32670-32700 with noise)
- Full left: ~0-1000
- Full right: ~64535-65535
- Small fluctuations: Normal (use deadzone)

---

**Follow this guide step by step and report results for each step!**
