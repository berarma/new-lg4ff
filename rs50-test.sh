#!/bin/bash
# RS50 Testing Script
# This script helps test the Logitech RS50 driver implementation

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
INFO="${BLUE}ℹ${NC}"
WARN="${YELLOW}⚠${NC}"

echo "=========================================="
echo "  Logitech RS50 Driver Test Suite"
echo "=========================================="
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

test_pass() {
    echo -e "${PASS} $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${FAIL} $1"
    ((TESTS_FAILED++))
}

test_info() {
    echo -e "${INFO} $1"
}

test_warn() {
    echo -e "${WARN} $1"
}

# Step 1: Check if RS50 is connected
echo "=== Step 1: Device Detection ==="
RS50_FOUND=0
RS50_VID=""
RS50_PID=""

if command -v lsusb &> /dev/null; then
    test_info "Scanning for Logitech devices..."
    DEVICE_COUNT=0
    
    # Get lsusb output - try both methods
    USB_OUTPUT=$(lsusb 2>/dev/null | grep -i "logitech" || true)
    
    if [ -z "$USB_OUTPUT" ]; then
        # Try searching for vendor ID directly
        USB_OUTPUT=$(lsusb 2>/dev/null | grep -i "046d" || true)
    fi
    
    # Debug: show what we got (only if verbose or if nothing found)
    if [ -z "$USB_OUTPUT" ] && [ "${DEBUG:-0}" = "1" ]; then
        test_info "Debug: lsusb output was empty"
        test_info "Debug: Full lsusb output:"
        lsusb 2>&1 | head -5 || true
    fi
    
    if [ -n "$USB_OUTPUT" ]; then
        while IFS= read -r line; do
            # lsusb format: "Bus 001 Device 012: ID 046d:c276 Logitech, Inc. RS50 Base for PlayStation/PC"
            # Try multiple regex patterns to match different lsusb output formats
            PID=""
            if [[ $line =~ ID\ 046d:([0-9a-fA-F]{4}) ]]; then
                # Matches "ID 046d:XXXX"
                PID="${BASH_REMATCH[1]}"
            elif [[ $line =~ 046d:([0-9a-fA-F]{4}) ]]; then
                # Matches "046d:XXXX" anywhere in line
                PID="${BASH_REMATCH[1]}"
            fi
            
            if [ -n "$PID" ]; then
                # Extract product name from lsusb output (everything after "ID xxxx:xxxx ")
                PRODUCT_NAME=$(echo "$line" | sed -n 's/.*ID [0-9a-fA-F]*:[0-9a-fA-F]* //p')
                if [ -z "$PRODUCT_NAME" ]; then
                    # Try alternative extraction - everything after vendor:product
                    PRODUCT_NAME=$(echo "$line" | sed -n 's/.*046d:[0-9a-fA-F]* //p')
                fi
                if [ -z "$PRODUCT_NAME" ]; then
                    PRODUCT_NAME="Unknown"
                fi
                test_info "Found Logitech device: 046d:${PID} - ${PRODUCT_NAME}"
                ((DEVICE_COUNT++))
            fi
        done <<< "$USB_OUTPUT"
    fi
    
    if [ $DEVICE_COUNT -eq 0 ]; then
        test_warn "Could not automatically detect Logitech devices."
        
        # Check if we're in a VM
        if [ -d /sys/class/dmi/id ] && grep -qi "vmware\|virtualbox\|qemu\|kvm" /sys/class/dmi/id/product_name 2>/dev/null; then
            test_info "Detected virtual machine environment."
            test_info "Note: USB devices may need to be passed through to the VM."
            test_info "If the RS50 is connected to the host, configure USB passthrough in your VM settings."
            echo ""
        fi
        
        test_info "Showing all USB devices for debugging:"
        echo "----------------------------------------"
        lsusb 2>/dev/null | head -10 || test_info "lsusb command failed or returned no output"
        echo "----------------------------------------"
        echo ""
        test_info "Showing Logitech-related devices:"
        LOGITECH_OUTPUT=$(lsusb 2>/dev/null | grep -i "logitech" || true)
        VENDOR_OUTPUT=$(lsusb 2>/dev/null | grep -i "046d" || true)
        
        if [ -n "$LOGITECH_OUTPUT" ]; then
            echo "$LOGITECH_OUTPUT"
        else
            test_info "  (none found with 'logitech' in name)"
        fi
        
        if [ -n "$VENDOR_OUTPUT" ]; then
            echo "$VENDOR_OUTPUT"
        else
            test_info "  (none found with vendor ID 046d)"
        fi
        
        echo ""
        test_info "Please enter the RS50 Product ID manually."
        test_info "From 'lsusb | grep -i logitech', look for 'ID 046d:XXXX' where XXXX is the Product ID."
        test_info "If device is not connected, enter the known Product ID (e.g., c276) to continue testing."
        read -p "Enter RS50 Product ID (e.g., c276): " RS50_PID
        RS50_VID="046d"
        RS50_PID=$(echo "$RS50_PID" | tr '[:upper:]' '[:lower:]')
        # Remove any "046d:" prefix if user included it
        RS50_PID=$(echo "$RS50_PID" | sed 's/^046d://')
        # Remove any leading/trailing whitespace
        RS50_PID=$(echo "$RS50_PID" | xargs)
    else
    
        echo ""
        test_info "Please identify your RS50 from the list above."
        test_info "You can enter either:"
        test_info "  - Just the Product ID (e.g., c276)"
        test_info "  - Full format (e.g., 046d:c276)"
        read -p "Enter RS50 Product ID: " USER_INPUT
        
        # Parse input - handle both "c276" and "046d:c276" formats
        if [[ $USER_INPUT =~ ^046d:([0-9a-fA-F]{4})$ ]]; then
            # Full format provided: extract product ID
            RS50_PID="${BASH_REMATCH[1]}"
        elif [[ $USER_INPUT =~ ^([0-9a-fA-F]{4})$ ]]; then
            # Just product ID provided
            RS50_PID="$USER_INPUT"
        else
            test_fail "Invalid format. Expected hex product ID (e.g., c276 or 046d:c276)"
            exit 1
        fi
        
        RS50_VID="046d"
        
        # Convert to lowercase for consistency
        RS50_PID=$(echo "$RS50_PID" | tr '[:upper:]' '[:lower:]')
    fi
    
    # Verify device exists (but don't fail if it doesn't - might be in VM or not connected)
    if lsusb -d ${RS50_VID}:${RS50_PID} &> /dev/null 2>&1; then
        RS50_FOUND=1
        test_pass "RS50 found at ${RS50_VID}:${RS50_PID}"
    else
        test_warn "Could not verify RS50 at ${RS50_VID}:${RS50_PID} via lsusb"
        test_info "This is OK if:"
        test_info "  - Device is not currently connected"
        test_info "  - Running in a VM without USB passthrough"
        test_info "  - Device ID is correct but device needs to be plugged in"
        test_info "Continuing with provided device ID: ${RS50_VID}:${RS50_PID}"
        RS50_FOUND=1
    fi
else
    test_fail "lsusb not found. Please install usbutils package."
    exit 1
fi

echo ""

# Step 2: Check driver module
echo "=== Step 2: Driver Module Status ==="
if lsmod | grep -q "hid_logitech"; then
    MODULE_NAME=$(lsmod | grep "hid_logitech" | awk '{print $1}' | head -1)
    test_pass "Driver module loaded: ${MODULE_NAME}"
    
    if [[ "$MODULE_NAME" == "hid_logitech_new" ]]; then
        test_pass "Using new-lg4ff driver (correct)"
    else
        test_warn "Using in-kernel hid-logitech (may need to load new-lg4ff)"
        test_info "To use new-lg4ff driver:"
        test_info "  1. Build: make"
        test_info "  2. Install: sudo make install"
        test_info "  3. Load: sudo make load"
    fi
else
    test_fail "Driver module not loaded"
    echo ""
    
    # Check for build issues
    if [ -f "hid-logitech-new.ko" ]; then
        test_info "Module file exists but not loaded. Try: sudo make load"
    else
        test_info "Module not built yet. Checking for build issues..."
        
        # Check for gcc-12 issue
        if ! command -v gcc-12 &> /dev/null && command -v gcc &> /dev/null; then
            GCC_VERSION=$(gcc --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "unknown")
            test_warn "gcc-12 not found, but gcc ${GCC_VERSION} is available"
            test_info "The kernel was built with gcc-12, but you can build with available gcc:"
            test_info "  $ CC=gcc make"
            test_info "  $ CC=gcc sudo make install"
            test_info "  $ CC=gcc sudo make load"
            echo ""
        fi
    fi
    
    test_info "To build and load the driver:"
    test_info "  1. Build the module:"
    test_info "     $ make"
    test_info "     (or: $ CC=gcc make if you get gcc-12 errors)"
    test_info ""
    test_info "  2. Install the module:"
    test_info "     $ sudo make install"
    test_info ""
    test_info "  3. Load the module:"
    test_info "     $ sudo make load"
    test_info ""
    test_info "Or use DKMS (recommended):"
    test_info "     $ sudo dkms install /usr/src/new-lg4ff"
    echo ""
    read -p "Press Enter to continue testing (or Ctrl+C to exit and load driver first): " response
fi

echo ""

# Step 3: Check kernel messages
echo "=== Step 3: Kernel Messages ==="
if dmesg | grep -qi "logitech.*${RS50_PID}"; then
    test_pass "RS50 detected in kernel messages"
    dmesg | grep -i "logitech.*${RS50_PID}" | tail -3 | while read line; do
        test_info "  $line"
    done
else
    test_warn "RS50 not found in kernel messages (device may not be connected)"
    test_info "Recent Logitech-related kernel messages:"
    dmesg | grep -i "logitech" | tail -5 || test_info "  (none found)"
    test_info ""
    test_info "This is expected if:"
    test_info "  - Device is not currently plugged in"
    test_info "  - Driver module is not loaded yet"
    test_info "  - Device needs to be connected after driver is loaded"
fi

echo ""

# Step 4: Check input devices
echo "=== Step 4: Input Device Nodes ==="
JS_DEVICE=""
EVENT_DEVICE=""

# Find joystick device
for js in /dev/input/js*; do
    if [ -e "$js" ]; then
        # Try to identify if it's the RS50
        JS_NUM=$(basename $js | sed 's/js//')
        if [ -f "/sys/class/input/js${JS_NUM}/device/name" ]; then
            DEVICE_NAME=$(cat /sys/class/input/js${JS_NUM}/device/name 2>/dev/null || echo "")
            if [[ "$DEVICE_NAME" == *"Logitech"* ]] || [[ "$DEVICE_NAME" == *"RS50"* ]]; then
                JS_DEVICE="$js"
                test_pass "Found joystick device: $js ($DEVICE_NAME)"
                break
            fi
        fi
    fi
done

if [ -z "$JS_DEVICE" ]; then
    test_warn "Could not identify RS50 joystick device"
    test_info "Available joystick devices:"
    ls -1 /dev/input/js* 2>/dev/null || test_info "  None found"
    read -p "Enter RS50 joystick device path (e.g., /dev/input/js0): " JS_DEVICE
fi

# Find event device
if [ -n "$JS_DEVICE" ]; then
    JS_NUM=$(basename $JS_DEVICE | sed 's/js//')
    if [ -f "/sys/class/input/js${JS_NUM}/device/event" ]; then
        EVENT_NUM=$(cat /sys/class/input/js${JS_NUM}/device/event 2>/dev/null | grep -o '[0-9]\+' || echo "")
        if [ -n "$EVENT_NUM" ] && [ -e "/dev/input/event${EVENT_NUM}" ]; then
            EVENT_DEVICE="/dev/input/event${EVENT_NUM}"
            test_pass "Found event device: $EVENT_DEVICE"
        fi
    fi
fi

if [ -z "$EVENT_DEVICE" ]; then
    test_warn "Could not identify RS50 event device"
    test_info "Available event devices:"
    ls -1 /dev/input/event* 2>/dev/null | head -5
fi

echo ""

# Step 5: Test input with jstest (if available)
echo "=== Step 5: Input Testing ==="
if [ -n "$JS_DEVICE" ] && command -v jstest &> /dev/null; then
    test_info "Testing with jstest..."
    test_info "Move the wheel, press pedals, and press buttons."
    test_info "Press Ctrl+C to stop jstest and continue."
    echo ""
    read -p "Press Enter to start jstest (or 's' to skip): " response
    if [[ ! "$response" == "s" ]]; then
        timeout 10 jstest --normal "$JS_DEVICE" 2>/dev/null || jstest "$JS_DEVICE" &
        JSTEST_PID=$!
        sleep 2
        kill $JSTEST_PID 2>/dev/null || true
        test_pass "jstest completed (check output above for axis/button responses)"
    fi
elif [ -n "$JS_DEVICE" ]; then
    test_warn "jstest not installed. Install with: sudo apt-get install joystick"
    test_info "You can manually test with: jstest $JS_DEVICE"
else
    test_warn "Cannot test input - device not identified"
fi

echo ""

# Step 6: Check sysfs entries
echo "=== Step 6: Sysfs Entries ==="
SYSFS_PATH=""
for path in /sys/bus/hid/drivers/logitech/*/; do
    if [ -d "$path" ] && dmesg | grep -q "$(basename $path)"; then
        # Check if this device matches our RS50
        if [ -f "${path}name" ]; then
            DEVICE_NAME=$(cat "${path}name" 2>/dev/null || echo "")
            if dmesg | grep -q "$(basename $path).*${RS50_PID}"; then
                SYSFS_PATH="$path"
                break
            fi
        fi
    fi
done

if [ -z "$SYSFS_PATH" ]; then
    # Try to find any logitech sysfs path
    SYSFS_PATH=$(find /sys/bus/hid/drivers/logitech -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
fi

if [ -n "$SYSFS_PATH" ] && [ -d "$SYSFS_PATH" ]; then
    test_pass "Found sysfs path: $SYSFS_PATH"
    
    # Check for expected sysfs entries
    EXPECTED_ENTRIES=("gain" "autocenter" "range" "combine_pedals")
    for entry in "${EXPECTED_ENTRIES[@]}"; do
        if [ -f "${SYSFS_PATH}${entry}" ] || [ -f "${SYSFS_PATH}${entry}" ]; then
            test_pass "  ${entry} entry exists"
            if [ "$entry" == "gain" ] || [ "$entry" == "autocenter" ]; then
                VALUE=$(cat "${SYSFS_PATH}${entry}" 2>/dev/null || echo "")
                test_info "    Current value: $VALUE"
            fi
        else
            test_warn "  ${entry} entry not found"
        fi
    done
else
    test_fail "Sysfs entries not found"
    test_info "Expected path: /sys/bus/hid/drivers/logitech/*/"
fi

echo ""

# Step 7: Force Feedback Test
echo "=== Step 7: Force Feedback Capabilities ==="
if [ -n "$EVENT_DEVICE" ]; then
    if command -v ff-test &> /dev/null; then
        test_info "Testing force feedback with ff-test..."
        # This would require a custom ff-test tool
        test_warn "ff-test tool not standard - manual testing recommended"
    else
        test_info "Force feedback can be tested with:"
        test_info "  - Games that support force feedback"
        test_info "  - Custom test applications"
        test_info "  - Check /sys/bus/hid/drivers/logitech/*/gain for gain control"
    fi
    
    # Check if device supports force feedback
    if [ -f "/sys/class/input/$(basename $EVENT_DEVICE)/device/capabilities/ff" ]; then
        FF_CAPS=$(cat "/sys/class/input/$(basename $EVENT_DEVICE)/device/capabilities/ff" 2>/dev/null || echo "0")
        if [ "$FF_CAPS" != "0" ]; then
            test_pass "Force feedback capabilities detected: 0x${FF_CAPS}"
        else
            test_warn "Force feedback capabilities not detected"
        fi
    fi
else
    test_warn "Cannot test force feedback - event device not identified"
fi

echo ""

# Step 8: Udev Rules
echo "=== Step 8: Udev Rules ==="
if [ -f "/etc/udev/rules.d/99-logitech-rs50.rules" ]; then
    test_pass "Udev rules file installed"
    if udevadm test-builtin uaccess "$(udevadm info -q path -n $JS_DEVICE 2>/dev/null || echo '')" 2>/dev/null | grep -q "logitech-rs50"; then
        test_pass "Udev rules active"
    else
        test_warn "Udev rules may need reload: sudo udevadm control --reload-rules"
    fi
else
    test_warn "Udev rules not installed"
    test_info "Install with: sudo cp 99-logitech-rs50.rules /etc/udev/rules.d/"
fi

echo ""

# Summary
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some tests failed. Review the output above.${NC}"
    exit 1
fi
