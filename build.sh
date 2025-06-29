#!/bin/bash

echo "Building iterator crash reproducer..."
echo "Rust version: $(rustc --version)"

# Add target if not already added
rustup target add x86_64-unknown-none 2>/dev/null || true

# Build
rustc --target x86_64-unknown-none \
    -C panic=abort \
    -C opt-level=0 \
    main.rs \
    -o iter_crash

echo "Build complete. Binary: iter_crash"
echo ""
echo "Note: This binary cannot be run directly."
echo "It demonstrates a compiler bug where the iterator chain"
echo "windows().enumerate().filter_map() causes a crash on x86_64 no_std."