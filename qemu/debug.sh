#!/bin/bash

# Run with debugging to capture the instruction
echo "Running with instruction tracing..."
qemu-system-i386 -kernel kernel.elf -serial stdio -display none -no-reboot \
    -d in_asm,int,cpu_reset -D debug.log 2>&1 | tee output.log

echo ""
echo "=== Checking crash location ==="
# Extract the last few instructions before the crash
echo "Last instructions before crash:"
grep -B 10 "check_exception.*new 0x6" debug.log | grep "0x00101" || echo "No instructions found at crash address"

echo ""
echo "=== Extracting binary at crash point ==="
# Use objdump to see what's at address 0x101552
objdump -D kernel.elf | grep -A 5 -B 5 "101552" || echo "Address not found in objdump"