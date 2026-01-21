# hello.s - Your first RISC-V assembly program
# This program prints "Hello, RISC-V!" and exits

.section .data
msg:
    .string "Hello, RISC-V!\n"
    
.section .text
.globl _start

_start:
    # Write message to stdout
    li a0, 1           # file descriptor (1 = stdout)
    la a1, msg         # address of message
    li a2, 15          # length of message
    li a7, 64          # syscall number for write
    ecall              # make system call

    # Exit program
    li a0, 0           # exit code 0 (success)
    li a7, 93          # syscall number for exit
    ecall              # make system call
