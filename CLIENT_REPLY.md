# Reply to Client: Vendor ID Question

## Suggested Reply

**Yes, you should keep out the vendor information (046d) from the product ID definition.**

Here's why:

### How USB Device IDs Work in This Code

1. **Vendor ID is defined separately:**
   ```c
   #define USB_VENDOR_ID_LOGITECH		0x046d
   ```
   This is already defined in `hid-ids.h` (around line 800) and is shared by all Logitech devices.

2. **Product ID only needs the product part:**
   ```c
   #define USB_DEVICE_ID_LOGITECH_RS50_WHEEL	0xc276
   ```
   Only the product ID (`c276`) is needed here, formatted as `0xc276`.

3. **They're combined when registering the device:**
   In `hid-lg.c`, the device is registered using both:
   ```c
   { HID_USB_DEVICE(USB_VENDOR_ID_LOGITECH, USB_DEVICE_ID_LOGITECH_RS50_WHEEL),
       .driver_data = LG_NOGET | LG_FF4 },
   ```
   The `HID_USB_DEVICE` macro combines the vendor ID (`0x046d`) with the product ID (`0xc276`) automatically.

### The Correct Format

**In `hid-ids.h`:**
```c
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL	0xc276
```

**NOT:**
```c
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL 046d:c276  // ❌ Wrong - syntax error
#define USB_DEVICE_ID_LOGITECH_RS50_WHEEL 0x046dc276 // ❌ Wrong - includes vendor
```

### Why This Design?

- **Reusability:** The vendor ID (`0x046d`) is defined once and used for all Logitech devices
- **Clarity:** Product IDs are clearly separated and easy to identify
- **Standard Practice:** This matches how the Linux kernel defines USB device IDs

### Summary

- ✅ Use only the product ID: `0xc276`
- ✅ Vendor ID (`0x046d`) is already defined elsewhere
- ✅ They're automatically combined when the device is registered
- ❌ Don't include `046d:` in the product ID definition

This is the same pattern used for all other Logitech wheels in the codebase (MOMO, G25, G27, etc.).
