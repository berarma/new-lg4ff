# evtest Guide - Testing RS50 Input

## What You Did
You ran `evtest` and selected event device 20 (the RS50). Good!

## What You Should See Now

When evtest is running and connected to your device, you should see:

1. **Device information** - Shows the device name, capabilities, etc.
2. **A waiting message** - "Waiting for events..."
3. **Event output** - When you move the wheel or press buttons, you'll see lines like:

```
Event: time 1234567.123456, type 3 (EV_ABS), code 0 (ABS_X), value 8192
Event: time 1234567.123500, type 3 (EV_ABS), code 1 (ABS_Y), value 128
Event: time 1234567.123600, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 1
```

## What to Do Now

### Step 1: Test Wheel Movement
- **Slowly rotate the wheel** left and right
- **Watch the terminal** - you should see `ABS_X` events with changing values
- Values should change when you move the wheel
- If values stay at 0 or don't change = **INPUT NOT WORKING** ❌
- If values change = **INPUT WORKING** ✅

### Step 2: Test Buttons
- **Press any buttons** on the wheel
- **Watch the terminal** - you should see `EV_KEY` events
- Button press: `value 1`
- Button release: `value 0`
- If no events when pressing = **BUTTONS NOT WORKING** ❌
- If events appear = **BUTTONS WORKING** ✅

### Step 3: Test Pedals (if RS50 has them)
- **Press pedals** (gas, brake, clutch if present)
- **Watch for** `ABS_Y`, `ABS_Z`, or `ABS_RZ` events
- Values should change when you press pedals

## What the Output Means

### Good Output (Input Working):
```
Event: time 1234567.123456, type 3 (EV_ABS), code 0 (ABS_X), value 8192
Event: time 1234567.123500, type 3 (EV_ABS), code 0 (ABS_X), value 8500  ← Value changed!
Event: time 1234567.123600, type 3 (EV_ABS), code 0 (ABS_X), value 7800  ← Value changed!
Event: time 1234567.123700, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 1  ← Button pressed!
```

**This means:** ✅ Input is working! The wheel is sending data.

### Bad Output (Input Not Working):
```
Event: time 1234567.123456, type 3 (EV_ABS), code 0 (ABS_X), value 0
Event: time 1234567.123500, type 3 (EV_ABS), code 0 (ABS_X), value 0  ← Still 0!
Event: time 1234567.123600, type 3 (EV_ABS), code 0 (ABS_X), value 0  ← Still 0!
```

**This means:** ❌ Input is NOT working. Values don't change when you move the wheel.

## What to Report

After testing, please tell me:

1. **Does the wheel value (ABS_X) change when you rotate it?**
   - Yes → Input is working! ✅
   - No → Input is not working ❌

2. **Do button presses show events?**
   - Yes → Buttons work! ✅
   - No → Buttons don't work ❌

3. **What values do you see?**
   - Copy a few lines of output when you move the wheel
   - Especially note if values are always 0

## If Input Is NOT Working

If values stay at 0 or don't change:

1. **Check dmesg for errors:**
   ```bash
   dmesg | grep -i "logitech\|rs50\|c276\|error\|fail" | tail -20
   ```

2. **Check if module loaded correctly:**
   ```bash
   lsmod | grep "hid-logitech-new"
   dmesg | tail -20
   ```

3. **Try unplugging and replugging the wheel:**
   - Unplug USB
   - Wait 2 seconds
   - Plug back in
   - Check dmesg again

## If Input IS Working

Great! The fix worked! Now you can:

1. **Test in a game** (like BeamNG)
2. **Configure controls** in the game
3. **Test force feedback** (if the game supports it)

## Quick Test Checklist

- [ ] Run `evtest` and select event 20
- [ ] Rotate wheel → See ABS_X values change?
- [ ] Press buttons → See EV_KEY events?
- [ ] Press pedals (if present) → See ABS_Y/Z values change?
- [ ] Report results

## Example Good Session

```
$ sudo evtest /dev/input/event20
Input device name: "Logitech RS50 Racing Wheel"
...
Properties:
...
Testing ... (interrupt to exit)
Event: time 1234567.123456, type 3 (EV_ABS), code 0 (ABS_X), value 8192
Event: time 1234567.123500, type 3 (EV_ABS), code 0 (ABS_X), value 8500  ← Moving right
Event: time 1234567.123600, type 3 (EV_ABS), code 0 (ABS_X), value 7800  ← Moving left
Event: time 1234567.123700, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 1  ← Button!
Event: time 1234567.123800, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 0  ← Released
```

This shows everything is working! ✅

## Next Steps Based on Results

### If Working:
- Test in BeamNG or other games
- Configure game controls
- Enjoy! 🎮

### If NOT Working:
- Share the evtest output
- Share dmesg output
- We'll debug further
