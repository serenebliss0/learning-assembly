#risc-v has 32 general purpose registers 
#today we're gonna learn about them!

.section .data
result_msg:
    .string "If you can read this in terminal, your code isnt cooked\n"
result_msg_len = . - result_msg - 1
msg:
    .string "Register operations complete\n"
msg_len = . - msg - 1


.section .text
.globl _start

_start:

# x0 is the zero register
# it will always read 0
# dont bother trying to change its value
# it will just read 0

addi x5, x0, 100 #x5 = 0 +100 = 100
# addi is add immediate
# use it to add registers and numbers
# you're gonna see that `i` a lot here so get used to it
add x6, x0,x0 # x6 = 0 + 0 = 0

addi x0, x5, 50 # this wont do anything


# temporary registers
# t0-t6 are the temp registers (for temporary values)

li t0, 42
li t1, 58
add t2, t0, t1 # t2 = 42 + 58 = 100

# arithmetic registers
li a0, 10
li a1, 20
add a2, a0, a1 # add
sub a3, a1, a0 # subtract

# bitwise operators

li t0, 0b101011011010 # 0xADA
li t1, 0b010100100101 # 0x525

and t2, t0, t1 
or t3, t0, t1
xor t4, t0, t1

# but then how do you do not operations?
# risc-v doesn't have a built in NOT operation but...
# we can do the same with xor
li t0, 5
xori t1, t0, -1
# we used -1 cuz that equil to 0b11111111111111111111111111111111
# so basically its gonna flip everything

# we can use this logic to make NAND  and NOR

#NAND
and t2, t0, t1
xori t2, t2, -1 

#NOR
or t2, t0, t1
xori t2, t2, -1

# even XNOR
xor t2, t0, t1
xori t2, t2, -1


# Shift Operations

# li a2, 56
li t0, 8
#shift left logical
slli t1, t0, 2 # shifts the value by two positions left

#shift right logical
srli t2, t0, 1 # shifts t0 by 1 position right

# fun fact: you can multiply and divide using shift operations
# for example 8 >> 2 will be 8 / 4 = 2; rightward is divide
# 8 << 2 is 8 * 4 = 32; leftward is multiply

li t0, -8
srai t3, t0, 1

# left shift is chill so don't worry about that
#in right shift there are two types: arithmetic and logical


# arithmetic shift is sign aware. it preserves the sign bit
# if the number is +ve it behaves like logical (fills in with 0s)
# if its negative, its gonna fill with 1s instead



# comparison operators


# happy message
li a7, 64 
li a0, 1
la a1, msg
li a2, msg_len
ecall


# exit program (ps if you don't add this its not gonna run)
li a7, 93
li a0, 0
ecall