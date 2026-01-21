; hello.asm - Your first x86 assembly program
; This program prints "Hello, World!" and exits

section .data
    ; Define our message
    msg db 'Hello, World!', 10    ; 10 is newline character
    len equ $ - msg                ; Calculate length of message

section .text
    global _start

_start:
    ; Write message to stdout
    mov rax, 1          ; System call number for sys_write
    mov rdi, 1          ; File descriptor 1 = stdout
    mov rsi, msg        ; Address of message
    mov rdx, len        ; Length of message
    syscall             ; Call the kernel

    ; Exit program
    mov rax, 60         ; System call number for sys_exit
    xor rdi, rdi        ; Exit code 0 (success)
    syscall             ; Call the kernel
