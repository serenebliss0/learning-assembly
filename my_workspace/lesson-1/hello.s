.section .data # storing consts and init variables!
msg: #variable name for the string
        .string "Hello World! From RISC-V!\n"
.section .text 
.globl _start #tells the linker where the program starts

_start: #start of program

li a0, 1 # the 1 means stdoutput
la a1, msg #a1 is the pointer to the data
li a2, 26 # the number of bytes to write
li a7, 64 #system call (the 64 is write)
ecall

#li means load intermediate
#it loads a const value to the register

#la is load address
#it locates the address of a label (var name) into the register

#ecall speaks for itself
#it calls the os


#this is how comments are in asm

#exit the program like this
li a0, 0 #exit code 0 means success (think of this like in C++)
li a7, 93 #93 is the syscall number for exit
ecall #call the operating system
