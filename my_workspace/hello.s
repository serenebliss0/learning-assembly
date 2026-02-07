.section .data
msg:
    .string "Hello, RISC-V!\n"

.section .text
.globl _start

_start:
    # Write system call
    li a0, 1           # file descriptor (stdout)
    la a1, msg         # message address
    li a2, 15          # message length
    li a7, 64          # syscall number for write
    ecall

    # Exit system call
    li a0, 0           # exit code
    li a7, 93          # syscall number for exit
    ecall