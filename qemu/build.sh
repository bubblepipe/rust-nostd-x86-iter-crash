#!/bin/bash

# Change to the script's directory
cd "$(dirname "$0")"

echo "=== Building 32-bit QEMU bare-metal iterator bug demo ==="
echo "Rust version: $(rustc --version)"
echo ""

# Clean previous builds
rm -f *.o *.a kernel.elf

# Step 1: Assemble boot code
echo "1. Assembling boot code..."
nasm -f elf32 boot.asm -o boot.o
if [ $? -ne 0 ]; then
    echo "Failed to assemble boot code"
    exit 1
fi

# Step 2: Build runtime support
echo "2. Building runtime support..."
clang -target i686-unknown-none-elf -m32 -c -ffreestanding -nostdlib runtime.c -o runtime.o
if [ $? -ne 0 ]; then
    echo "Failed to compile runtime"
    exit 1
fi

# Step 3: Build Rust code
echo "3. Building Rust code..."
# Install i686 target if needed
rustup target add i686-unknown-linux-gnu 2>/dev/null || true

# Build for 32-bit
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
if command -v ld.lld &> /dev/null; then
    ld.lld -m elf_i386 \
        -T linker.ld \
        -nostdlib \
        --nmagic \
        boot.o \
        runtime.o \
        libmain.a \
        -o kernel.elf
else
    echo "Error: ld.lld not found. Please install LLVM/lld"
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
echo "  qemu-system-i386 -kernel kernel.elf -serial stdio -display none -no-reboot -d int,cpu_reset"
echo ""
echo "Expected serial output:"
echo "  Starting iterator bug test..."
echo "  Test 1: windows().enumerate()... PASSED"
echo "  Test 2: windows().enumerate().filter_map()... (crashes here)"
echo ""
echo "If the bug is fixed, you would see all tests complete!"