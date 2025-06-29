# How to Fix This Compiler Bug

## 1. Set Up Rust Compiler Development Environment

```bash
# Clone rust compiler
git clone https://github.com/rust-lang/rust.git
cd rust

# Configure for development
./configure --enable-debug --enable-optimize --enable-lld

# Build compiler (this takes a while!)
./x.py build
```

## 2. Understanding the Bug

The bug occurs in the interaction between three iterator adapters:
- `Windows<'_, T>` - Creates sliding windows over slices
- `Enumerate<I>` - Adds index to iterator items  
- `FilterMap<I, F>` - Filters and maps in one step

The crash happens when `FilterMap::next()` calls `Iterator::find_map()`.

## 3. Key Areas to Investigate

### A. Iterator Trait Implementation
Look at: `library/core/src/iter/adapters/filter_map.rs`

```rust
impl<I, F> Iterator for FilterMap<I, F>
where
    I: Iterator,
    F: FnMut(I::Item) -> Option<B>,
{
    fn next(&mut self) -> Option<B> {
        self.iter.find_map(&mut self.f)
    }
}
```

### B. Code Generation for x86
Check these files:
- `compiler/rustc_codegen_llvm/src/` - LLVM code generation
- `compiler/rustc_target/src/spec/i686_*` - Target specifications
- `compiler/rustc_codegen_ssa/src/mir/` - MIR to machine code

### C. ABI and Calling Conventions
- `compiler/rustc_target/src/abi/call/x86.rs` - x86 calling conventions
- `compiler/rustc_target/src/spec/abi.rs` - ABI definitions

## 4. Debugging Steps

### Step 1: Build a Debug Compiler
```bash
# Build with debug assertions
./x.py build --stage 1 compiler/rustc --debug
```

### Step 2: Compile Your Test with Debug Output
```bash
# Use your custom rustc
./build/x86_64-unknown-linux-gnu/stage1/bin/rustc \
    --target i686-unknown-linux-gnu \
    -Z verbose \
    -Z print-mir=all \
    -Z print-llvm-ir \
    test.rs
```

### Step 3: Compare Working vs Broken
Compile the same code for RISC-V and x86, then compare:
- MIR output
- LLVM IR
- Assembly generation

## 5. Likely Fix Locations

### Theory 1: Stack Alignment
The issue might be in stack alignment for closures on x86.

Check: `compiler/rustc_codegen_llvm/src/builder.rs`
```rust
// Look for stack alignment code
fn align_stack(...)
```

### Theory 2: Closure Calling Convention
The closure in filter_map might have wrong calling convention.

Check: `compiler/rustc_codegen_llvm/src/abi.rs`
```rust
// Look for closure ABI handling
fn adjust_for_cabi(...)
```

### Theory 3: Iterator Layout
The memory layout of the combined iterator might be wrong.

Check: `compiler/rustc_middle/src/ty/layout.rs`
```rust
// Look for iterator layout computation
```

## 6. Creating a Fix

Once you identify the issue, the fix might involve:

1. **Adjusting stack alignment** for iterator chains on x86:
```rust
// In codegen
if target.arch == "x86" && involves_closures {
    ensure_stack_alignment(16);
}
```

2. **Fixing calling convention** for closures in no_std:
```rust
// In ABI handling
match (target, is_no_std) {
    (X86, true) => use_different_convention(),
    _ => default_convention(),
}
```

3. **Adding special case** for this iterator pattern:
```rust
// In iterator codegen
if is_windows_enumerate_filter_map {
    generate_safer_code();
}
```

## 7. Testing Your Fix

### Create a regression test:
```rust
// tests/ui/iterators/issue-xxxxx-windows-enumerate-filter-map.rs
#![no_std]
#![no_main]

#[panic_handler]
fn panic(_: &PanicInfo) -> ! { loop {} }

#[no_mangle]
pub extern "C" fn main() {
    let data = [false; 4];
    let mut iter = data.windows(1).enumerate().filter_map(|(i, _)| Some(i));
    assert_eq!(iter.next(), Some(0));
}
```

### Run the test suite:
```bash
./x.py test tests/ui/iterators/
```

## 8. Submitting the Fix

1. Create a branch:
```bash
git checkout -b fix-x86-iterator-crash
```

2. Make your changes with good commit messages:
```bash
git commit -m "Fix x86 iterator crash with windows().enumerate().filter_map()

This fixes a code generation issue where the specific combination of
Windows, Enumerate, and FilterMap iterators would generate incorrect
code on x86 no_std targets, causing a segmentation fault.

The issue was in [specific location] where [specific problem].

Fixes #xxxxx"
```

3. Submit a PR with:
- Clear description of the problem
- Explanation of the fix
- Regression test
- Link to the original issue

## 9. Learning Resources

- [Rust Compiler Development Guide](https://rustc-dev-guide.rust-lang.org/)
- [Rust Compiler Source Code Walkthrough](https://www.youtube.com/watch?v=eQt48qYUUos)
- [Debugging the Rust Compiler](https://rustc-dev-guide.rust-lang.org/compiler-debugging.html)

## 10. Quick Investigation Commands

```bash
# See MIR for your test
rustc +nightly -Z dump-mir=all test.rs

# See LLVM IR
rustc +nightly --emit=llvm-ir test.rs

# See assembly with source annotations
rustc +nightly -C debuginfo=2 --emit=asm test.rs

# Compare x86 vs RISC-V
diff <(rustc --target=i686-unknown-linux-gnu --emit=llvm-ir test.rs -o -) \
     <(rustc --target=riscv64gc-unknown-none-elf --emit=llvm-ir test.rs -o -)
```

Start by comparing the LLVM IR between working (RISC-V) and broken (x86) targets - the difference will likely point you to the exact issue!