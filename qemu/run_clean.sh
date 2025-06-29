#!/bin/bash

# Change to script directory
cd "$(dirname "$0")"

if [ ! -f kernel.elf ]; then
    echo "kernel.elf not found. Running build first..."
    ./build.sh
    if [ $? -ne 0 ]; then
        echo "Build failed!"
        exit 1
    fi
fi

echo "=== Running iterator bug demo ==="
echo ""
echo "Expected output:"
echo "  - Starting iterator bug test..."
echo "  - Test 1: windows().enumerate()... PASSED"
echo "  - Test 2: windows().enumerate().filter_map()... (crashes here)"
echo ""
echo "Actual output:"
echo "----------------------------------------"

# Run QEMU and show only our serial output
qemu-system-i386 \
    -kernel kernel.elf \
    -serial stdio \
    -display none \
    -no-reboot \
    2>&1 | grep -E "^(Starting|Test|All tests|PANIC)" || true

echo "----------------------------------------"
echo ""
echo "The crash after 'Test 2:' confirms the iterator bug."