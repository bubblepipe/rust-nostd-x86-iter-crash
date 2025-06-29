#!/bin/bash

# Change to the script's directory
cd "$(dirname "$0")"

echo "=== Building QEMU bare-metal iterator bug demo ==="
echo "Rust version: $(rustc --version)"
echo ""

# Clean previous builds
rm -f *.o *.a kernel.elf

# Step 1: Assemble boot code
echo "1. Assembling boot code..."
# Use NASM which is more portable
nasm -f elf32 boot.asm -o boot.o
if [ $? -ne 0 ]; then
    echo "Failed to assemble boot.s"
    exit 1
fi

# Step 2: Build runtime support
echo "2. Building runtime support..."
clang -target i686-unknown-linux-gnu -c -ffreestanding -nostdlib runtime.c -o runtime.o
if [ $? -ne 0 ]; then
    echo "Failed to compile runtime"
    exit 1
fi

# Step 3: Build Rust code
echo "3. Building Rust code..."
# First ensure we have the target
rustup target add i686-unknown-linux-gnu 2>/dev/null || true

rustc --target i686-unknown-linux-gnu \
    --crate-type staticlib \
    -C panic=abort \
    -C opt-level=0 \
    -C relocation-model=static \
    -C code-model=kernel \
    main.rs \
    -o libmain.a
if [ $? -ne 0 ]; then
    echo "Failed to compile Rust code"
    exit 1
fi

# Step 4: Link everything
echo "4. Linking..."
# Try to find a cross-platform linker
if command -v ld.lld &> /dev/null; then
    ld.lld -m elf_i386 \
        -T linker.ld \
        -nostdlib \
        --nmagic \
        boot.o \
        runtime.o \
        libmain.a \
        -o kernel.elf
elif command -v i686-elf-ld &> /dev/null; then
    i686-elf-ld \
        -T linker.ld \
        -nostdlib \
        --nmagic \
        boot.o \
        runtime.o \
        libmain.a \
        -o kernel.elf
else
    echo "Error: No suitable linker found. Install lld or i686-elf-binutils"
    exit 1
fi
if [ $? -ne 0 ]; then
    echo "Failed to link"
    exit 1
fi

echo ""
echo "=== Build successful! ==="
echo ""
echo "Run with:"
echo "  qemu-system-i386 -kernel kernel.elf"
echo ""
echo "Expected output in VGA (top-left corner):"
echo "  S  - Start (always shown)"
echo "  S1 - Test 1 passed (windows().enumerate() works)"
echo "  S1 - Then crash (windows().enumerate().filter_map() fails)"
echo ""
echo "If the bug is fixed, you would see: S12!"