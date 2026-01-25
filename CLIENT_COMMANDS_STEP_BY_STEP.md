# Step-by-Step Commands for RS50 Testing

Follow these commands **in order**. Copy and paste each command into your terminal.

---

## Step 1: Check if Driver is Loaded

**Command 1.1:**
```bash
lsmod | grep "hid-logitech-new"
```

**Expected:** Should show a line with `hid_logitech_new`

**If nothing appears, run:**
```bash
sudo modprobe hid-logitech-new
```

**Then check again:**
```bash
lsmod | grep "hid-logitech-new"
```

---

**Command 1.2:**
```bash
dmesg | grep -i "logitech\|rs50" | tail -10
```

**Expected:** Should show messages about RS50 or Logitech

**Report:** Copy any messages you see

---

## Step 2: Find Your Wheel Device

**Command 2.1:**
```bash
evtest
```

**What to do:**
- Look at the list for a device with "Logitech" or "RS50" in the name
- **Write down the device number** (e.g., event20)
- **Press Ctrl+C to exit** (don't select anything yet)

**Report:** Device number? event____

---

## Step 3: Test Basic Input Detection

**Command 3.1:**
```bash
sudo evtest /dev/input/event20
```
*(Replace `20` with your device number from Step 2)*

**What to do:**
- **Don't touch the wheel yet**
- Watch the terminal for events appearing
- Note the values you see (should be around 32670-32767)

**Expected:** Events should appear continuously with values around 32670-32767

**Report:** 
- Events appearing? Yes/No
- Idle values: _______________

**Keep this running!** Don't exit yet.

---

## Step 4: Test Large Wheel Movements

**While evtest is still running from Step 3:**

**Action 4.1: Rotate wheel FULL LEFT**
- Rotate wheel as far left as possible
- Hold for 2 seconds
- Watch terminal for the lowest value
- **Report:** Full left value: _____

**Action 4.2: Rotate wheel FULL RIGHT**
- Rotate wheel as far right as possible
- Hold for 2 seconds
- Watch terminal for the highest value
- **Report:** Full right value: _____

**Action 4.3: Return wheel to CENTER**
- Return wheel to center position
- Hold for 2 seconds
- Watch terminal for the center value
- **Report:** Center value: _____

**Expected values:**
- Full left: 0-1000
- Center: ~32767 (32600-32900)
- Full right: 64535-65535

**Keep evtest running!**

---

## Step 5: Test Buttons

**While evtest is still running:**

**Action 5.1: Press each button**
- Press each button on the wheel one by one
- Watch terminal for `EV_KEY` events
- Each press should show `value 1`
- Each release should show `value 0`

**Report:**
- How many buttons work? _____
- Do all buttons work? Yes/No

**Keep evtest running!**

---

## Step 6: Test Pedals (if RS50 has pedals)

**While evtest is still running:**

**Action 6.1: Press gas pedal**
- Press the gas/throttle pedal
- Watch for `ABS_Y` or `ABS_Z` events
- Note how values change

**Action 6.2: Press brake pedal**
- Press the brake pedal
- Watch for events
- Note how values change

**Action 6.3: Press clutch pedal (if present)**
- Press the clutch pedal
- Watch for events
- Note how values change

**Report:**
- Has pedals? Yes/No
- Pedals work? Yes/No
- What axis codes? (ABS_Y, ABS_Z, etc.)

**Now exit evtest:**
- Press **Ctrl+C** to stop evtest

---

## Step 7: Test in BeamNG.drive

**Commands (in game, not terminal):**

1. **Start BeamNG.drive**

2. **Go to:** Settings → Controls

3. **Select:** "Steering Wheel" or "Gamepad"

4. **Configure:**
   - Rotate wheel → Should detect steering
   - Press pedals → Should detect gas/brake
   - Press buttons → Should detect buttons

5. **Important Settings:**
   - **Deadzone:** Set to 2-5%
   - **Sensitivity:** 100% (or adjust as needed)
   - **Invert:** Only if wheel turns wrong direction

6. **Test in game:**
   - Rotate wheel → Car should steer
   - Press buttons → Actions should work
   - Press pedals → Car should accelerate/brake

**Report:**
- BeamNG detects wheel? Yes/No
- Steering works? Yes/No
- Buttons work? Yes/No
- Any issues? _______________

---

## Step 8: Final Verification

**Command 8.1:**
```bash
dmesg | grep -i "logitech\|rs50" | tail -5
```

**Expected:** No error messages

**Command 8.2:**
```bash
lsmod | grep "hid-logitech-new"
```

**Expected:** Module should appear in list

**Report:**
- Everything still working? Yes/No
- Any errors? _______________

---

## Quick Command Reference

**Check module:**
```bash
lsmod | grep "hid-logitech-new"
```

**Load module:**
```bash
sudo modprobe hid-logitech-new
```

**Find device:**
```bash
evtest
```

**Check kernel messages:**
```bash
dmesg | grep -i "logitech\|rs50" | tail -10
```

**Test input:**
```bash
sudo evtest /dev/input/event20
```
*(Replace 20 with your device number)*

**Check USB:**
```bash
lsusb | grep -i logitech
```

---

## Complete Test Report Template

```
=== RS50 Test Results ===

Step 1 - Module: [ ] Pass [ ] Fail
Step 2 - Device: [ ] Pass [ ] Fail (Device: event___)
Step 3 - Basic Input: [ ] Pass [ ] Fail (Idle: _____)
Step 4 - Movements: [ ] Pass [ ] Fail (Left: ___, Right: ___, Center: ___)
Step 5 - Buttons: [ ] Pass [ ] Fail (Working: ___)
Step 6 - Pedals: [ ] Pass [ ] Fail [ ] N/A
Step 7 - BeamNG: [ ] Pass [ ] Fail
Step 8 - Final: [ ] Pass [ ] Fail

Overall: [ ] Working [ ] Partially [ ] Not Working

Issues: ________________
```

---

**Run each command in order and report your results!**
