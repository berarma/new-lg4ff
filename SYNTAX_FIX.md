# Syntax Fix: RS50 Device ID Format

## The Issue

If you see this in `hid-ids.h`:
```c
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL 046d:c276
```

This is **WRONG** and will cause a compilation error. The format `046d:c276` is:
- ✅ Correct format for `lsusb` output (shows vendor:product)
- ❌ **NOT valid C syntax** - cannot be used in C code

## The Fix

The correct format should be:
```c
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL	0xc276
```

## Explanation

1. **In `lsusb` output:** You see `046d:c276` where:
   - `046d` = Logitech vendor ID
   - `c276` = RS50 product ID

2. **In C header files:** We only define the **product ID** part:
   - Must start with `0x` (C hexadecimal prefix)
   - Only the product ID: `0xc276`
   - The vendor ID (`0x046d`) is handled elsewhere in the code

3. **Why this matters:**
   - C compiler expects `0x` prefix for hex numbers
   - The colon `:` is not valid in a numeric constant
   - This will cause: `error: invalid suffix "c276" on integer constant`

## How to Fix

**In `hid-ids.h`, line ~838:**

**WRONG:**
```c
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL 046d:c276
```

**CORRECT:**
```c
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL	0xc276
```

## Verification

After fixing, verify the format matches other device IDs in the file:
```c
#define USB_DEVICE_ID_LOGITECH_MOMO_WHEEL	0xc295
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL	0xc276  ← Should look like this
#define USB_DEVICE_ID_LOGITECH_DFP_WHEEL	0xc298
```

All should use the `0x` prefix and only the product ID (last 4 hex digits).

## Quick Fix Command

If you need to fix it quickly:
```bash
sed -i 's/046d:c276/0xc276/g' hid-ids.h
```

Or manually edit the file and change:
- `046d:c276` → `0xc276`
