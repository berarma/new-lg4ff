# Instructions for Client: Testing with evtest

## Current Status
✅ You've successfully:
- Loaded the module
- Found the RS50 device (event20)
- Started evtest

## What to Do Right Now

### 1. Look at the Terminal
You should see something like:
```
Input device name: "Logitech RS50 Racing Wheel"
...
Testing ... (interrupt to exit)
```

### 2. Test the Wheel
**Slowly rotate the wheel left and right**

**Watch the terminal** - you should see lines appearing like:
```
Event: time 1234567.123456, type 3 (EV_ABS), code 0 (ABS_X), value 8192
Event: time 1234567.123500, type 3 (EV_ABS), code 0 (ABS_X), value 8500
```

### 3. What to Look For

**✅ GOOD (Input Working):**
- Numbers appear when you move the wheel
- The `value` number changes when you rotate
- Example: `value 8192` → `value 8500` → `value 7800`

**❌ BAD (Input Not Working):**
- No events appear when you move the wheel
- Events appear but `value` is always `0`
- Example: `value 0` → `value 0` → `value 0` (never changes)

### 4. Test Buttons
**Press any button on the wheel**

You should see:
```
Event: time 1234567.123700, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 1
Event: time 1234567.123800, type 1 (EV_KEY), code 288 (BTN_TRIGGER), value 0
```

### 5. When Done Testing
Press **Ctrl+C** to exit evtest

## What to Report

Please tell me:

1. **When you rotate the wheel, do you see events?**
   - Yes / No

2. **Do the values change when you rotate?**
   - Yes (values change) / No (always 0 or same)

3. **Do buttons work?**
   - Yes (events appear) / No (no events)

4. **Copy a few lines of output** when you move the wheel

## Quick Test

1. Rotate wheel slowly → Watch terminal
2. Press a button → Watch terminal  
3. Report what you see

That's it! Simple test to see if input is working.
