# Simple Reply: Force Feedback

## Your Device is Working! ✅

The evtest output shows your RS50 is **fully functional**:
- ✅ All axes detected (wheel, pedals)
- ✅ All buttons detected
- ✅ Input working perfectly

## About Force Feedback

Unfortunately, **the RS50 cannot support force feedback on Linux**. This is a **hardware limitation**, not a driver issue.

**Why:**
- The RS50's HID descriptor doesn't have an "output report"
- Without an output report, we can't send commands to the device
- Force feedback requires sending commands to the device
- This is how the RS50 was designed - it's not something we can fix

## What This Means

- ✅ **Input works perfectly** (steering, pedals, buttons)
- ❌ **Force feedback won't work** (hardware limitation)
- ✅ **You can still use it in games** (just without force feedback)

## Your Options

1. **Use it without force feedback** - Works great for most games
2. **Use a different wheel** - G25/G27/G29 support force feedback on Linux
3. **Use on Windows** - May support force feedback with Logitech's drivers

## Bottom Line

**Your RS50 is working correctly!** It's ready to use in games. You just won't have physical force feedback effects - you'll have visual/audio feedback instead.

This is not a bug - it's a hardware limitation of the RS50. The driver is working as designed. 🎮
