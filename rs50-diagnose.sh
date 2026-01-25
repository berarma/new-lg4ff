#!/bin/bash
# Simple script to check USB devices using lsusb
# Run: ./rs50-diagnose.sh

echo "=== Logitech USB Devices ==="
lsusb | grep -i logitech

echo ""
echo "=== Detailed RS50 Information ==="
echo "Please plug in your RS50 wheel and run:"
echo "  lsusb -v -d 046d:XXXX | less"
echo ""
echo "Replace XXXX with the product ID shown above."
echo ""
echo "Or use the C diagnostic tool:"
echo "  gcc -o rs50-diagnose rs50-diagnose.c -lusb-1.0"
echo "  sudo ./rs50-diagnose"
