# Context for Rust Compiler Bug Investigation

## Bug Summary
We discovered a compiler bug where the iterator chain `slice.windows(n).enumerate().filter_map(closure)` causes a segmentation fault on x86 targets (both i686 and x86_64) in no_std environments. The same code works fine on RISC-V and other architectures.

## Key Findings

1. **Crash Location**: The crash occurs when calling `.next()` on the filter_map iterator
2. **Assembly Analysis**: The generated code shows `filter_map::next` calls `Iterator::find_map` which seems to have issues
3. **No Stack Overflow**: Debug showed the iterator is only 16 bytes and no excessive stack usage
4. **Triple Fault**: QEMU shows a triple fault at address 0x00101562 (double fault handler also faults)

## Reproduction
- Repository: `/Users/bubblepipe/repo/iter_crash/`
- Minimal code that crashes:
```rust
let data: [bool; 4] = [false, true, false, false];
let mut iter = data.windows(1).enumerate().filter_map(|(i, _)| Some(i));
let _ = iter.next(); // CRASH HERE
```

## What Works vs What Crashes
- ✅ `windows(n)` alone
- ✅ `windows(n).enumerate()`  
- ✅ `windows(n).filter_map()`
- ✅ `enumerate().filter_map()` on regular slices
- ❌ `windows(n).enumerate().filter_map()` - only this specific combination

## Suspected Causes
1. **Stack alignment issue** - x86 requires 16-byte alignment, might be violated
2. **Calling convention mismatch** - Closure ABI might be wrong for no_std x86
3. **Iterator layout issue** - The combined iterator state might have alignment problems
4. **Missing intrinsics** - Some compiler intrinsic might not be linked properly

## Investigation Areas in rustc

### Primary Suspects
1. `library/core/src/iter/adapters/filter_map.rs` - The FilterMap implementation
2. `compiler/rustc_codegen_llvm/src/abi.rs` - ABI and calling convention handling
3. `compiler/rustc_target/src/abi/call/x86.rs` - x86-specific calling conventions
4. `compiler/rustc_codegen_ssa/src/mir/block.rs` - MIR to machine code generation

### Debugging Approach
1. Compare LLVM IR between working (RISC-V) and broken (x86) targets
2. Look for differences in:
   - Stack alignment code
   - Closure calling conventions
   - Iterator memory layout
   - Parameter passing

### Quick Commands to Start
```bash
# In rustc directory, build stage 1 compiler
./x.py build --stage 1

# Compare LLVM IR for the test case
./build/*/stage1/bin/rustc --target i686-unknown-linux-gnu --emit=llvm-ir test.rs -o x86.ll
./build/*/stage1/bin/rustc --target riscv64gc-unknown-none-elf --emit=llvm-ir test.rs -o riscv.ll
diff x86.ll riscv.ll

# Get MIR output
./build/*/stage1/bin/rustc -Z dump-mir=all test.rs
```

## Next Steps
1. Set up rustc development environment
2. Create minimal test case in rustc test suite
3. Compare codegen between working and broken targets
4. Identify the specific codegen difference causing the crash
5. Implement fix (likely in ABI handling or stack alignment)
6. Add regression test
7. Submit PR

The bug is well-isolated and reproducible, which should make it easier to track down in the compiler code. Focus on the x86-specific code generation paths, especially around closure calling conventions in no_std contexts.