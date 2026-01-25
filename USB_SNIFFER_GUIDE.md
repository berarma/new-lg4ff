# USB Sniffer Guide for RS50 Force Feedback

## Current Status

The RS50 driver is **working for input** (steering, buttons, pedals) but **force feedback is not working** because:

- All communication methods return **error -38 (EIO - Input/Output error)**
- This means the device is rejecting our commands
- The RS50 uses a **proprietary protocol** that Windows knows but Linux doesn't

## Why USB Sniffer is Needed

The Windows Logitech G HUB driver knows the secret protocol to send force feedback commands. We need to:

1. **Capture USB traffic** when Windows sends force feedback commands
2. **Analyze the protocol** (endpoint, format, initialization)
3. **Implement it** in the Linux driver

## What to Capture

### Step 1: Setup USB Sniffer

1. Connect RS50 to Windows machine
2. Install USB sniffer software (Wireshark with USBPcap, USBlyzer, or similar)
3. Start capture **before** opening G HUB

### Step 2: Capture Force Feedback Traffic

1. **Start USB capture**
2. **Open Logitech G HUB**
3. **Go to RS50 settings** → Force Feedback
4. **Test force feedback** (rotate wheel, feel resistance)
5. **Stop capture**

### Step 3: What to Look For

In the captured USB traffic, find:

1. **OUT transfers** (computer → RS50)
   - These are the force feedback commands
   - Look for transfers to **endpoint 0x01** or **0x02** (interrupt OUT)
   - Or **control transfers** (endpoint 0x00)

2. **Command format:**
   - What **endpoint** is used? (0x01, 0x02, etc.)
   - What **interface** is used? (0, 1, 2?)
   - What is the **command structure**? (7 bytes? 8 bytes?)
   - Is there a **report ID**? (0x00, 0x01, etc.)

3. **Initialization sequence:**
   - Are there **setup commands** sent before force feedback?
   - Any **feature reports** or **control transfers** during init?

4. **Force feedback commands:**
   - What do the **actual FF commands** look like?
   - How are they **formatted**?
   - What **values** change when force feedback is active?

## Example: What We're Currently Trying

The Linux driver is currently trying to send commands like:
```
1C 00 7E 00 00 00 00  (7 bytes)
```

But getting error -38 (EIO), meaning the device rejects them.

## What We Need from Sniffer

Please capture and share:

1. **USB endpoint** used for force feedback (e.g., 0x01, 0x02)
2. **Interface number** (0, 1, or 2?)
3. **Command format** (exact bytes sent)
4. **Initialization sequence** (any setup commands)
5. **Sample force feedback commands** (what bytes are sent when FF is active)

## How to Share Results

1. Export capture as **pcap file** or **text log**
2. Or take **screenshots** of the USB transfers
3. Focus on **OUT transfers** (computer → device)
4. Include **timestamps** if possible

## Next Steps

Once we have the USB sniffer data:

1. **Analyze the protocol** from the capture
2. **Identify the correct endpoint/interface**
3. **Understand the command format**
4. **Implement it** in the Linux driver
5. **Test and verify** force feedback works

## Current Driver Status

✅ **Working:**
- Steering wheel input
- Buttons
- Pedals
- No crashes

❌ **Not Working:**
- Force feedback (needs protocol reverse-engineering)

## Technical Details

**Device:** Logitech RS50 (USB ID: 046d:c276)  
**Current Error:** -38 (EIO) on all communication methods  
**Methods Tried:**
- HID_OUTPUT_REPORT (report IDs 0, 1, 2)
- HID_FEATURE_REPORT (report IDs 0, 1, 2)
- Interrupt OUT endpoint
- USB control transfers

All methods fail with EIO, indicating protocol mismatch.

---

**Once you have the USB sniffer capture, share it and we'll implement the correct protocol!**
