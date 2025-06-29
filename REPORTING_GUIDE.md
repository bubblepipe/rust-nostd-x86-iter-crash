# Where to Report This Bug

## Primary Location: Rust GitHub Repository

Report the bug at: https://github.com/rust-lang/rust/issues/new/choose

Select the "Bug Report" template.

## Bug Report Title Suggestion

`Iterator chain windows().enumerate().filter_map() causes segfault on x86 no_std targets`

## What to Include

1. **Minimal Reproducer** - Include the code from main.rs
2. **Environment Details** - Rust version, host, target
3. **Reproduction Steps** - How to build and run (can link to this repo)
4. **Expected vs Actual** - Should return Some(0), but crashes
5. **Analysis** - Mention it's specific to x86 no_std, works on other targets

## Additional Places to Get Attention

1. **Rust Internals Forum**: https://internals.rust-lang.org/
   - Post under "Compiler" category
   - Good for discussing the technical details

2. **Rust Zulip**: https://rust-lang.zulipchat.com/
   - Channel: #t-compiler
   - Good for real-time discussion with compiler team

## Example Bug Report Structure

```markdown
### Summary
The iterator chain `slice.windows(n).enumerate().filter_map(closure)` causes a segmentation fault on x86 (both i686 and x86_64) targets in no_std environments.

### Minimal Reproducer
[Include code]

### Environment
- rustc version: 1.87.0-nightly (2025-02-20) through 1.90.0-nightly (2025-06-28)
- Host: aarch64-apple-darwin
- Target: i686-unknown-linux-gnu, x86_64-unknown-none

### Steps to Reproduce
1. Clone https://github.com/[your-username]/iter_crash
2. cd iter_crash/qemu
3. ./build.sh
4. ./run_clean.sh

### Expected Behavior
Iterator should return Some(0)

### Actual Behavior
Program crashes with triple fault / segmentation fault

### Additional Information
- Works correctly on riscv64gc-unknown-none-elf
- Works correctly with std
- Only fails with the specific combination windows().enumerate().filter_map()
```

## Tags to Use

When creating the issue, add these labels (if you have permission):
- `C-bug` (Category: Bug)
- `T-compiler` (Team: Compiler)
- `O-x86` (OS/Target: x86)
- `A-codegen` (Area: Code generation)
- `I-crash` (Issue: Causes crash)

## Before Submitting

1. Search existing issues for similar bugs:
   - Search for "windows enumerate filter_map"
   - Search for "no_std x86 crash"
   - Search for "iterator segfault"

2. Consider running with latest nightly first to confirm it's not already fixed

## Link to Your Repository

Make your iter_crash repository public on GitHub so you can link to it in the bug report. This provides a complete reproducible example.