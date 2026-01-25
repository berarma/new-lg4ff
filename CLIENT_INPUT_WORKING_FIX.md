# Client Reply: Input IS Working! (But Needs Calibration)

## Good News! ✅

**The input IS working!** The device is sending events. The values you see (32670-32672) mean the wheel is detected and communicating.

## What You're Seeing

The output shows:
```
Event: type 3 (EV_ABS), code 0 (ABS_X), value 32670
Event: type 3 (EV_ABS), code 0 (ABS_X), value 32671
Event: type 3 (EV_ABS), code 0 (ABS_X), value 32672
```

**What this means:**
- ✅ Device is detected
- ✅ Input events are being generated
- ✅ Values are in the normal range (0-65535, center is ~32767)
- ⚠️ Small fluctuations (32670-32672) even when not moving

## The Issue

The wheel is sending **tiny constant changes** (1-2 units) even when you're not touching it. This is called "noise" or "jitter" and is common with analog devices.

**Why this matters:**
- Games might interpret these tiny changes as constant movement
- BeamNG might think the wheel is always slightly turned
- This can cause the wheel to drift or not center properly

## Solutions

### Solution 1: Test Larger Movements First

**Before fixing, let's confirm larger movements work:**

1. **Rotate the wheel significantly** (full turn left, then right)
2. **Watch the values** - they should change dramatically
3. **Report back:**
   - Do values change a lot when you turn the wheel? (should go from ~0 to ~65535)
   - Or do they stay around 32670-32672?

**If values don't change much when you turn the wheel:**
- This indicates a different problem (wrong axis mapping or calibration issue)
- We'll need to investigate further

**If values DO change a lot when you turn:**
- Input is working correctly! ✅
- The small fluctuations are just noise
- We can fix with deadzone (see Solution 2)

### Solution 2: Add Deadzone (Recommended)

Games usually handle this with a "deadzone" setting, but we can also check if the driver needs calibration.

**In BeamNG:**
1. Go to Controls → Steering Wheel Settings
2. Look for "Deadzone" or "Center Deadzone" setting
3. Set it to 2-5% to ignore small fluctuations
4. This will make the game ignore values between 32600-32800 (approximately)

**Check if driver supports calibration:**
```bash
# Check if there are calibration settings
cat /sys/module/hid_logitech_new/parameters/* 2>/dev/null

# Or check device-specific settings
find /sys -name "*logitech*" -o -name "*rs50*" 2>/dev/null | head -10
```

### Solution 3: Hardware Check

The small fluctuations could be:
1. **Normal analog noise** - Most wheels have 1-2 unit jitter
2. **Wheel not perfectly centered** - Physical position slightly off
3. **Wiring issue** - Loose connection causing noise

**Test:**
- Unplug and replug the USB cable
- Try a different USB port
- Check if the wheel is physically centered

## What to Test Now

### Test 1: Large Movement
```
1. Rotate wheel FULL LEFT
   → What value do you see? (should be close to 0 or low number)

2. Rotate wheel FULL RIGHT  
   → What value do you see? (should be close to 65535 or high number)

3. Center the wheel
   → What value do you see? (should be around 32767)
```

**Report the values for each position.**

### Test 2: Button Test
```
1. Press any button on the wheel
2. Do you see EV_KEY events?
3. Do they show value 1 when pressed, 0 when released?
```

## Expected Behavior

**Normal wheel behavior:**
- Center position: ~32767 (or 32670-32672 with small noise)
- Full left: ~0-1000
- Full right: ~64535-65535
- Small noise when centered: ±5 units is normal

**If your values match this:**
- ✅ Everything is working correctly!
- Just need to set deadzone in games

**If your values don't match:**
- We may need to adjust calibration or axis mapping

## Next Steps

1. **Test large movements** - Rotate wheel fully left/right and report values
2. **Test buttons** - Press buttons and confirm they work
3. **Try in BeamNG** - Set deadzone to 2-5% and test
4. **Report results** - Let me know what you find

## Summary

**Status:** ✅ Input is working! Device is detected and sending events.

**Issue:** Small fluctuations (32670-32672) when wheel is idle - this is normal noise.

**Fix:** Set deadzone in games (2-5%) to ignore small fluctuations.

**Action:** Test large movements to confirm full range works, then configure deadzone in BeamNG.
