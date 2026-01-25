#!/bin/bash
# Quick fix script for gcc-12 not found error
# This creates a symlink from gcc-12 to gcc if gcc-12 doesn't exist

if ! command -v gcc-12 &> /dev/null && command -v gcc &> /dev/null; then
    echo "gcc-12 not found, but gcc is available."
    echo "Creating a temporary symlink (requires sudo)..."
    
    # Check if we can create the symlink
    if [ -w /usr/bin ] 2>/dev/null; then
        ln -sf /usr/bin/gcc /usr/bin/gcc-12
        echo "✓ Symlink created: /usr/bin/gcc-12 -> /usr/bin/gcc"
    else
        echo "Need sudo to create symlink. Run:"
        echo "  sudo ln -sf /usr/bin/gcc /usr/bin/gcc-12"
        echo ""
        echo "Or install gcc-12:"
        echo "  sudo apt-get update && sudo apt-get install gcc-12"
        exit 1
    fi
else
    echo "gcc-12 already exists or gcc not found."
    exit 0
fi
