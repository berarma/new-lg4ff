# Client Testing Checklist - Step by Step

## Instructions
Follow each step in order. Check off each item as you complete it. Report any issues.

---

## ✅ Step 1: Verify Module is Loaded

**Run:**
```bash
lsmod | grep "hid-logitech-new"
dmesg | grep -i "logitech\|rs50" | tail -10
```

**Check:**
- [ ] Module `hid-logitech-new` appears in output
- [ ] dmesg shows RS50 detected

**If not working:**
```bash
sudo modprobe hid-logitech-new
```

**Report:** Module loaded? Yes/No

---

## ✅ Step 2: Find Your Device

**Run:**
```bash
evtest
```
(Just look at the list, don't select yet)

**Check:**
- [ ] See device with "Logitech" or "RS50" in name
- [ ] Note the device number (e.g., event20)

**Report:** Device number? event___

---

## ✅ Step 3: Test Basic Input

**Run:**
```bash
sudo evtest /dev/input/event20
```
(Replace 20 with your device number)

**Do:**
- Don't touch the wheel
- Watch the terminal

**Check:**
- [ ] Events are appearing
- [ ] Values are around 32670-32767

**Report:**
- Events appearing? Yes/No
- Idle values: _______________

---

## ✅ Step 4: Test Large Movements

**Do (while evtest is running):**
1. Rotate wheel FULL LEFT → Note value
2. Rotate wheel FULL RIGHT → Note value  
3. Center wheel → Note value

**Check:**
- [ ] Full left: value close to 0 (0-1000)
- [ ] Full right: value close to 65535 (64535-65535)
- [ ] Center: value around 32767

**Report:**
- Full left: _____
- Full right: _____
- Center: _____
- Values change dramatically? Yes/No

---

## ✅ Step 5: Test Buttons

**Do (while evtest is running):**
- Press each button on the wheel

**Check:**
- [ ] Each press shows `EV_KEY` events
- [ ] Shows `value 1` when pressed, `value 0` when released

**Report:**
- Buttons work? Yes/No
- How many buttons? _____

---

## ✅ Step 6: Test Pedals (if RS50 has them)

**Do (while evtest is running):**
- Press gas, brake, clutch (if present)

**Check:**
- [ ] Pedal press changes values
- [ ] Values change smoothly

**Report:**
- Has pedals? Yes/No
- Pedals work? Yes/No

---

## ✅ Step 7: Exit evtest

**Do:**
- Press Ctrl+C to exit

**Check:**
- [ ] Exited successfully

---

## ✅ Step 8: Test in BeamNG

**Do:**
1. Start BeamNG.drive
2. Go to Settings → Controls
3. Select "Steering Wheel"
4. Configure controls
5. **Set Deadzone to 2-5%** (important!)
6. Test in game

**Check:**
- [ ] BeamNG detects wheel
- [ ] Steering works
- [ ] Buttons work
- [ ] No constant drift

**Report:**
- Works in BeamNG? Yes/No
- Any issues? _______________

---

## ✅ Step 9: Final Check

**Run:**
```bash
dmesg | grep -i "logitech\|rs50" | tail -5
lsmod | grep "hid-logitech-new"
```

**Check:**
- [ ] Everything still working
- [ ] No errors in dmesg

---

## 📋 Final Report

**Copy this and fill out:**

```
=== Test Results ===

Step 1 - Module: [ ] Pass [ ] Fail
Step 2 - Device: [ ] Pass [ ] Fail  
Step 3 - Basic Input: [ ] Pass [ ] Fail
Step 4 - Large Movements: [ ] Pass [ ] Fail
Step 5 - Buttons: [ ] Pass [ ] Fail
Step 6 - Pedals: [ ] Pass [ ] Fail [ ] N/A
Step 8 - BeamNG: [ ] Pass [ ] Fail

Overall: [ ] Working [ ] Partially [ ] Not Working

Issues: ________________
```

---

**Follow each step and report results!**
