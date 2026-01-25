# Step-by-Step Testing Guide for RS50 Driver

This guide will walk you through testing the RS50 driver **one step at a time**. Each step is explained in detail so you know exactly what to do and what to expect.

---

## Before You Start

**What you need:**
- ✅ RS50 wheel connected via USB
- ✅ Terminal/command line access
- ✅ Sudo/administrator access
- ✅ Driver already installed (if not, see README.md)

**What we're testing:**
1. Is the driver loaded?
2. Can the computer see your wheel?
3. Does the wheel send input (steering, buttons)?
4. Does everything work in games?

---

## Step 1: Check if the Driver is Loaded

### What we're checking:
We want to make sure the Linux driver for your RS50 is actually running.

### What to do:
Open a terminal and type these commands **one at a time**:

```bash
lsmod | grep "hid-logitech-new"
```

**What this does:** Lists all loaded kernel modules and searches for the Logitech driver.

### What you should see:
✅ **GOOD:** You should see a line like:
```
hid_logitech_new       123456  0
```

❌ **BAD:** If you see nothing (empty output), the driver is not loaded.

### If the driver is NOT loaded:
Run this command to load it:
```bash
sudo modprobe hid-logitech-new
```

Then check again with the first command.

### Next, check kernel messages:
```bash
dmesg | grep -i "logitech\|rs50" | tail -10
```

**What this does:** Shows recent messages from the kernel about Logitech devices.

### What you should see:
✅ **GOOD:** You should see messages mentioning "RS50" or "Logitech" or "c276" (the RS50's USB ID).

Example of good output:
```
[12345.678] logitech 0003:046D:C276.0001: Logitech RS50 Racing Wheel detected
```

❌ **BAD:** No messages about Logitech or RS50.

### Report:
- [ ] Driver loaded? Yes / No
- [ ] RS50 detected in messages? Yes / No
- [ ] Copy any relevant messages you see

---

## Step 2: Find Your Wheel Device

### What we're checking:
We want to find which input device number your RS50 is using (like event20, event21, etc.).

### What to do:
Type this command:
```bash
evtest
```

**What this does:** Lists all input devices (keyboards, mice, gamepads, wheels, etc.)

### What you should see:
A numbered list like this:
```
/dev/input/event0:  Power Button
/dev/input/event1:  Sleep Button
/dev/input/event2:  AT Translated Set 2 keyboard
...
/dev/input/event20: Logitech RS50 Racing Wheel
...
```

### What to look for:
✅ **GOOD:** Find a line that says "Logitech" or "RS50" or "Racing Wheel"
- **Write down the number** (e.g., event20)

❌ **BAD:** No device with "Logitech" or "RS50" in the name.

### If you don't see your wheel:
1. Make sure the USB cable is connected
2. Try unplugging and replugging the USB cable
3. Check if the wheel lights up (if it has lights)
4. Run: `lsusb | grep -i logitech` to see if USB detects it

### Report:
- [ ] Found RS50 device? Yes / No
- [ ] Device number? event____ (write the number)
- [ ] Device name? (copy the full name from the list)

**Important:** Don't select anything in evtest yet! Just look at the list, then press **Ctrl+C** to exit.

---

## Step 3: Test Basic Input Detection

### What we're checking:
We want to see if the wheel is sending any data at all, even when you're not touching it.

### What to do:
Run evtest on your specific device (replace `20` with your device number from Step 2):

```bash
sudo evtest /dev/input/event20
```

**What this does:** Connects to your RS50 and shows all input events in real-time.

### What you should see:
1. **Device information** - Shows capabilities, axes, buttons
2. **A message:** "Waiting for events..."
3. **Events appearing** - Even when you're not touching the wheel!

### Important: Don't touch the wheel yet!
Just watch the terminal. You should see lines appearing like:

```
Event: time 1234567.123456, type 3 (EV_ABS), code 0 (ABS_X), value 32670
Event: time 1234567.123500, type 3 (EV_ABS), code 0 (ABS_X), value 32671
Event: time 1234567.123600, type 3 (EV_ABS), code 0 (ABS_X), value 32670
```

### What the values mean:
- **ABS_X** = Wheel position (steering axis)
- **value** = The position value (0 = full left, 32767 = center, 65535 = full right)
- **When idle:** Values should be around 32670-32767 (near center)

### What you should see:
✅ **GOOD:** 
- Events are appearing continuously
- Values are around 32670-32767 (center range)
- Values might fluctuate slightly (this is normal - small noise)

❌ **BAD:**
- No events appearing at all
- Values are always 0
- Values never change

### Report:
- [ ] Events appearing? Yes / No
- [ ] What values do you see when idle? (e.g., "32670-32672")
- [ ] Copy 3-5 lines of output

**Keep evtest running!** Don't exit yet - we'll use it for the next steps.

---

## Step 4: Test Large Wheel Movements

### What we're checking:
We want to verify the wheel can detect full rotation left and right, and that the values change correctly.

### What to do:
**While evtest is still running** (from Step 3), do these movements:

### Movement 1: Full Left
1. **Rotate the wheel FULL LEFT** (as far as it can go)
2. **Hold it there for 2 seconds**
3. **Watch the terminal** - look at the `value` numbers
4. **Note the lowest value** you see

### What you should see:
✅ **GOOD:** Values should be close to **0** (like 0-1000 range)
- Example: `value 500`, `value 200`, `value 0`

❌ **BAD:** Values stay high (like 30000+) or don't change much

### Movement 2: Full Right
1. **Rotate the wheel FULL RIGHT** (as far as it can go)
2. **Hold it there for 2 seconds**
3. **Watch the terminal** - look at the `value` numbers
4. **Note the highest value** you see

### What you should see:
✅ **GOOD:** Values should be close to **65535** (like 64535-65535 range)
- Example: `value 65000`, `value 65500`, `value 65535`

❌ **BAD:** Values stay low (like 10000) or don't change much

### Movement 3: Return to Center
1. **Return the wheel to CENTER** (straight position)
2. **Hold it there for 2 seconds**
3. **Watch the terminal** - look at the `value` numbers
4. **Note the center value** you see

### What you should see:
✅ **GOOD:** Values should be around **32767** (like 32600-32900 range)
- Example: `value 32700`, `value 32767`, `value 32800`

❌ **BAD:** Values are far from 32767 when centered

### Summary of expected values:
- **Full left:** 0-1000
- **Center:** ~32767 (32600-32900)
- **Full right:** 64535-65535

### Report:
- [ ] Full left value: _____ (write the number)
- [ ] Full right value: _____ (write the number)
- [ ] Center value: _____ (write the number)
- [ ] Do values change dramatically when you move the wheel? Yes / No

**Keep evtest running!** We'll test buttons next.

---

## Step 5: Test Buttons

### What we're checking:
We want to verify all buttons on the wheel work correctly.

### What to do:
**While evtest is still running**, press each button on your wheel one by one.

### What you should see:
When you press a button, you should see **two events**:

**When you PRESS the button:**
```
Event: time 1234567.123456, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 1
```

**When you RELEASE the button:**
```
Event: time 1234567.123500, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 0
```

### What the values mean:
- **EV_KEY** = Button/key event
- **code** = Which button (BTN_TRIGGER, BTN_1, BTN_2, etc.)
- **value 1** = Button pressed
- **value 0** = Button released

### What you should see:
✅ **GOOD:**
- Each button press shows an event with `value 1`
- Each button release shows an event with `value 0`
- Different buttons show different codes (BTN_1, BTN_2, BTN_TRIGGER, etc.)

❌ **BAD:**
- No events when pressing buttons
- Events appear but wrong buttons respond
- Some buttons don't work

### Test each button:
1. Press button 1 → Watch for event
2. Release button 1 → Watch for event
3. Press button 2 → Watch for event
4. Release button 2 → Watch for event
5. Continue for all buttons...

### Report:
- [ ] How many buttons work? _____ (count them)
- [ ] Do all buttons work? Yes / No / Some
- [ ] Copy 2-3 button event lines (the actual output)

**Keep evtest running!** We'll test pedals next (if your RS50 has them).

---

## Step 6: Test Pedals (if RS50 has pedals)

### What we're checking:
We want to verify pedals (gas, brake, clutch) work correctly.

### What to do:
**While evtest is still running**, press each pedal one by one.

### What to look for:
Pedals usually show up as different axes:
- **ABS_Y** = Usually gas/throttle
- **ABS_Z** = Usually brake
- **ABS_RZ** = Usually clutch (if present)

### Test Gas Pedal:
1. **Press the gas pedal** (throttle)
2. **Watch the terminal** - look for `ABS_Y` or `ABS_Z` events
3. **Note how the value changes** as you press

### What you should see:
✅ **GOOD:**
- Values change when you press the pedal
- Values change smoothly (not jumping around)
- Different values for different pedal positions

Example:
```
Event: type 3 (EV_ABS), code 1 (ABS_Y), value 0      ← Not pressed
Event: type 3 (EV_ABS), code 1 (ABS_Y), value 16384  ← Half pressed
Event: type 3 (EV_ABS), code 1 (ABS_Y), value 32767  ← Fully pressed
```

❌ **BAD:**
- No events when pressing pedals
- Values don't change
- Values jump erratically

### Test Brake Pedal:
1. **Press the brake pedal**
2. **Watch for events** (might be `ABS_Z` or `ABS_RZ`)
3. **Note how the value changes**

### Test Clutch Pedal (if present):
1. **Press the clutch pedal**
2. **Watch for events**
3. **Note how the value changes**

### Report:
- [ ] Does RS50 have pedals? Yes / No
- [ ] Do pedals work? Yes / No
- [ ] What axis codes do you see? (ABS_Y, ABS_Z, ABS_RZ, etc.)
- [ ] Do values change smoothly? Yes / No

**Now you can exit evtest:** Press **Ctrl+C** to stop it.

---

## Step 7: Test in BeamNG.drive (or your racing game)

### What we're checking:
We want to verify the wheel works correctly in an actual game.

### Preparation:
1. **Close evtest** (if still running) - Press Ctrl+C
2. **Start BeamNG.drive** (or your preferred racing game)

### In BeamNG.drive:

#### Step 7a: Go to Settings
1. **Open the game**
2. **Go to Settings** (usually in main menu)
3. **Go to Controls** (or Input Settings)

#### Step 7b: Select Input Device
1. **Look for "Input Device" or "Controller"**
2. **Select "Steering Wheel"** or **"Gamepad"**
3. **Your RS50 should appear in the list** - select it

#### Step 7c: Configure Controls
1. **Steering:** Should auto-detect when you rotate the wheel
   - Rotate wheel left → Should show "Left"
   - Rotate wheel right → Should show "Right"
   
2. **Gas/Brake:** Map to pedals (if you have them)
   - Press gas pedal → Should detect
   - Press brake pedal → Should detect

3. **Buttons:** Map as needed
   - Press each button → Game should detect it

#### Step 7d: Important Settings
1. **Deadzone:** Set to **2-5%** (this is important!)
   - This prevents small fluctuations from causing drift
   - Go to Advanced Settings if needed

2. **Sensitivity:** Adjust as needed (usually 100% is fine)

3. **Invert:** Only enable if the wheel turns the wrong direction

#### Step 7e: Test in Game
1. **Start a race or free drive**
2. **Rotate the wheel** → Car should steer
3. **Press buttons** → Actions should trigger
4. **Press pedals** (if present) → Car should accelerate/brake

### What you should see:
✅ **GOOD:**
- Wheel controls steering smoothly
- Buttons work in game
- Pedals work in game (if present)
- No constant drift (car doesn't steer by itself)
- Wheel responds correctly to your movements

❌ **BAD:**
- Wheel not detected in game settings
- Wheel detected but no response
- Constant drift (car steers by itself)
- Wheel turns wrong direction
- Buttons don't work in game

### If you have problems:

**Problem: Wheel not detected**
- Check Step 1 (is driver loaded?)
- Try restarting the game
- Check game's controller settings

**Problem: Constant drift**
- Increase deadzone to 5-10%
- Check if wheel is physically centered
- Check if values are stable in evtest when centered

**Problem: Wrong direction**
- Enable "Invert" in game settings
- Or check axis mapping

**Problem: Buttons don't work**
- Check if buttons work in evtest (Step 5)
- If they work in evtest but not in game → Game mapping issue
- Remap buttons in game settings

### Report:
- [ ] BeamNG detects wheel? Yes / No
- [ ] Steering works? Yes / No
- [ ] Buttons work? Yes / No
- [ ] Pedals work? (if applicable) Yes / No
- [ ] Any issues? Describe: ________________

---

## Step 8: Final Verification

### What we're checking:
We want to make sure everything is still working and there are no errors.

### What to do:
Run these final checks:

```bash
# Check kernel messages one more time
dmesg | grep -i "logitech\|rs50" | tail -5
```

**What to look for:**
✅ **GOOD:** No error messages, just detection messages
❌ **BAD:** Error messages or warnings

```bash
# Verify module is still loaded
lsmod | grep "hid-logitech-new"
```

**What to look for:**
✅ **GOOD:** Module appears in the list
❌ **BAD:** Module not in the list

### Final Checklist:
- [ ] Module loaded and stable
- [ ] Input events working (from Step 3)
- [ ] Large movements work (full range from Step 4)
- [ ] Buttons work (from Step 5)
- [ ] Pedals work (from Step 6, if applicable)
- [ ] Works in BeamNG/game (from Step 7)
- [ ] No constant drift (deadzone set correctly)
- [ ] No errors in dmesg

---

## Complete Test Report

Copy this template and fill it out with your results:

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
Working buttons: _____ / _____ (how many work / how many total)

Step 6 - Pedals:
[ ] Yes [ ] No [ ] N/A (if no pedals)
Working: ________________

Step 7 - BeamNG/Game:
[ ] Yes [ ] No
Issues: ________________

Step 8 - Final Check:
[ ] Yes [ ] No
Errors: ________________

Overall Status:
[ ] Working [ ] Partially Working [ ] Not Working

Notes: ________________
```

---

## Troubleshooting Common Issues

### Issue: No events in evtest
**Solution:**
1. Check Step 1 - is the module loaded?
2. Check USB connection: `lsusb | grep logitech`
3. Try unplugging and replugging USB
4. Check dmesg for errors: `dmesg | tail -20`

### Issue: Values don't change when moving wheel
**Solution:**
1. Make sure you're moving the wheel significantly (not tiny movements)
2. Check you're looking at the right axis (ABS_X)
3. Check dmesg for errors

### Issue: Constant drift in games
**Solution:**
1. Set deadzone to 5-10% in game settings
2. Check if wheel is physically centered
3. Check if values are stable in evtest when centered

### Issue: Buttons don't work
**Solution:**
1. Check if buttons work in evtest (Step 5)
2. If they work in evtest but not in game → Game mapping issue
3. Remap buttons in game settings

### Issue: Module won't load
**Solution:**
1. Check if you have the correct kernel headers: `uname -r`
2. Rebuild the module: `make clean && make`
3. Check for errors during build
4. Try manual install: `sudo make install && sudo modprobe hid-logitech-new`

---

## What to Do Next

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

## Quick Reference Commands

**Check module:**
```bash
lsmod | grep "hid-logitech-new"
```

**Check device:**
```bash
evtest
```

**Check kernel messages:**
```bash
dmesg | grep -i "logitech\|rs50" | tail -10
```

**Test input:**
```bash
sudo evtest /dev/input/event20  # Replace 20 with your device number
```

**Check USB:**
```bash
lsusb | grep -i logitech
```

---

**Follow each step in order and report your results!**
