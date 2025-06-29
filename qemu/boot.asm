; 32-bit multiboot kernel
section .multiboot
align 4
multiboot_header:
    dd 0x1BADB002        ; magic
    dd 0x00000003        ; flags (align modules to 4KB)
    dd -(0x1BADB002 + 0x00000003) ; checksum

section .text
global _start
extern rust_main

bits 32
_start:
    ; Set up stack
    mov esp, stack_top
    
    ; Enable SSE/SSE2
    ; Set CR4.OSFXSR (bit 9) to enable SSE
    mov eax, cr4
    or eax, 0x200       ; Set OSFXSR bit
    mov cr4, eax
    
    ; Set CR0.EM to 0 to disable FPU emulation
    mov eax, cr0
    and eax, ~0x4       ; Clear EM bit
    or eax, 0x2         ; Set MP bit
    mov cr0, eax
    
    ; Call Rust code
    call rust_main
    
    ; Hang if we return
hang:
    cli
    hlt
    jmp hang

section .bss
align 16
stack_bottom:
    resb 16384 ; 16 KB stack
stack_top: