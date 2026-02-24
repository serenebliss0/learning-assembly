#risc-v has 32 general purpose registers 

.section .data
result_msg:
    .string "Register operations complete!\n"

.section .text
.globl _start

_start:

# x0 is the zero register
# it will always read 0
# dont bother trying to change its value
# it will just read 0

addi x5, x0, 100 #x5 = 0 +100 = 100
//add i is add intermediate
# use it to add registers and numbers
