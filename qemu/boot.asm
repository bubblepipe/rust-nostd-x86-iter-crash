; Minimal boot code for x86 bare metal
section .multiboot
align 4
multiboot_header:
    dd 0x1BADB002        ; magic
    dd 0x00000000        ; flags  
    dd -(0x1BADB002)     ; checksum

section .text
global _start
extern rust_main

bits 32
_start:
    ; Set up stack
    mov esp, stack_top
    
    ; Clear screen - write space to first VGA position
    mov edi, 0xb8000
    mov byte [edi], ' '
    mov byte [edi+1], 0x07
    
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
    resb 4096
stack_top: