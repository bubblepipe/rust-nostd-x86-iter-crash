# QEMU Bare Metal Iterator Bug Demo

This folder contains a minimal bare-metal environment to demonstrate the iterator bug in QEMU.

## Prerequisites

- NASM assembler: `brew install nasm` (macOS) or `apt install nasm` (Linux)
- QEMU: `brew install qemu` (macOS) or `apt install qemu-system-x86` (Linux)
- Rust nightly with i686 target: `rustup target add i686-unknown-none`

## Files

- `boot.asm` - Minimal bootloader with multiboot header
- `main.rs` - Rust code demonstrating the iterator bug
- `linker.ld` - Linker script for bare metal
- `i686-bare-metal.json` - Custom target specification
- `build.sh` - Build script
- `run.sh` - Run script for QEMU

## Building

```bash
./build.sh
```

## Running

```bash
./run.sh
```

## The Bug

The specific iterator chain that causes the crash:
```rust
array.windows(1).enumerate().filter_map(|(i, _)| Some(i))
```

This crashes when calling `.next()` on x86_64 no_std environments.