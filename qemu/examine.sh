#!/bin/bash

# Change to script directory
cd "$(dirname "$0")"

echo "=== Examining kernel.elf ==="
echo ""

# Find the section containing address 0x101552
echo "1. Finding section containing crash address 0x101552:"
readelf -S kernel.elf | grep -E "^\s*\[|101[0-9a-f]{3}" || readelf -S kernel.elf | grep .text

echo ""
echo "2. Disassembling around address 0x101552:"
# Try to disassemble around the crash point
objdump -d kernel.elf --start-address=0x101540 --stop-address=0x101560 2>/dev/null || \
    objdump -d kernel.elf | grep -A 10 -B 10 "101552:" || \
    echo "Could not find address in disassembly"

echo ""
echo "3. Hex dump of the area:"
# Get a hex dump of the bytes at that location
objdump -s kernel.elf --start-address=0x101540 --stop-address=0x101560 2>/dev/null || \
    echo "Could not dump hex at that address"

echo ""
echo "4. Looking for the rust_main function:"
objdump -d kernel.elf | grep -A 50 "<rust_main>:" | head -60

echo ""
echo "5. Full disassembly of .text section:"
objdump -d kernel.elf | grep -A 200 "section .text:" | head -210