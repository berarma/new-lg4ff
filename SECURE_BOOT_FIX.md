# Secure Boot Issue: "Loading of unsigned module is rejected"

## The Problem

When you see repeated messages in `dmesg`:
```
Loading of unsigned module is rejected
```

This means **Secure Boot is enabled** and preventing the unsigned kernel module from loading.

## Understanding Secure Boot

Secure Boot is a security feature that:
- ✅ Prevents malicious or unsigned code from loading
- ✅ Protects against rootkits and bootkits
- ❌ Also blocks legitimate unsigned kernel modules (like custom drivers)

## Solutions

You have **two options**:

### Option 1: Disable Secure Boot (Easier, Less Secure)

**Pros:**
- Quick and easy
- No additional setup needed
- Works immediately

**Cons:**
- Reduces system security
- May not be allowed in some corporate/enterprise environments

**Steps:**
1. Reboot your computer
2. Enter BIOS/UEFI settings (usually F2, F10, F12, or Del during boot)
3. Find "Secure Boot" option (usually under Security or Boot settings)
4. Disable Secure Boot
5. Save and exit
6. Reboot
7. Load the module: `sudo modprobe hid-logitech-new`

### Option 2: Sign the Module (More Secure, Recommended)

**Pros:**
- Maintains Secure Boot security
- More professional approach
- Required for production systems

**Cons:**
- More complex setup
- Requires creating signing keys

**Steps:**

1. **Create a signing key:**
   ```bash
   # Generate a key pair
   openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=Your Name/"
   
   # Import the key
   sudo mokutil --import MOK.der
   ```
   You'll be prompted to set a password. **Remember this password!**

2. **Reboot and enroll the key:**
   - During reboot, you'll see a blue screen (MOK Manager)
   - Select "Enroll MOK"
   - Enter the password you set
   - Confirm enrollment
   - Continue boot

3. **Sign the module:**
   ```bash
   # Sign the module
   sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der /lib/modules/$(uname -r)/updates/dkms/hid-logitech-new.ko
   
   # Or if using manual install:
   sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der /lib/modules/$(uname -r)/extra/hid-logitech-new.ko
   ```

4. **Load the module:**
   ```bash
   sudo modprobe hid-logitech-new
   ```

## Recommendation

**For testing/development:** Option 1 (disable Secure Boot) is fine and faster.

**For production/long-term use:** Option 2 (sign the module) is better and maintains security.

## Verify After Fix

After either solution, verify it works:
```bash
# Check dmesg - should see no more rejection messages
dmesg | tail -20

# Check module is loaded
lsmod | grep hid_logitech

# Test the driver
./rs50-test.sh
```

## Quick Decision Guide

- **Just testing?** → Disable Secure Boot (Option 1)
- **Production system?** → Sign the module (Option 2)
- **Corporate/Enterprise?** → Sign the module (Option 2) - may be required by policy
- **Personal machine?** → Either works, your choice

## Additional Notes

- After disabling Secure Boot, you may need to reload the module: `sudo modprobe -r hid-logitech-new && sudo modprobe hid-logitech-new`
- If you sign the module, you'll need to re-sign it after every kernel update or module rebuild
- Some systems have "Setup Mode" that allows loading unsigned modules temporarily
