# arithmetic.s - Comprehensive RISC-V arithmetic operations demo
# Demonstrates addition, subtraction, immediate operations, and multi-word arithmetic

.section .data
result_msg: .string "Arithmetic operations complete\n"

.section .text
.globl _start

_start:
    # Basic addition
    li a0, 10
    li a1, 25
    add a2, a0, a1          # a2 = 10 + 25 = 35
    
    # Subtraction
    li a3, 100
    sub a4, a3, a2          # a4 = 100 - 35 = 65
    
    # Add immediate
    addi a5, a4, 50         # a5 = 65 + 50 = 115
    
    # Subtract using negative immediate
    addi a6, a5, -15        # a6 = 115 - 15 = 100
    
    # Negation (0 - x)
    sub a7, zero, a6        # a7 = 0 - 100 = -100
    
    # Demonstrate overflow
    li t0, 0x7FFFFFFF       # Maximum positive 32-bit signed int
    addi t1, t0, 1          # t1 = 0x80000000 (becomes most negative!)
    
    # Multi-word addition (64-bit on 32-bit hardware)
    # Let's add 0x1_00000005 + 0x0_FFFFFFFF = 0x2_00000004
    li t0, 0x00000005       # Lower 32 bits of first number
    li t1, 0x00000001       # Upper 32 bits of first number
    li t2, 0xFFFFFFFF       # Lower 32 bits of second number
    li t3, 0x00000000       # Upper 32 bits of second number
    
    add t4, t0, t2          # Add lower 32 bits
    sltu t5, t4, t0         # Check if carry (t4 < t0 means overflow)
    add t6, t1, t3          # Add upper 32 bits
    add t6, t6, t5          # Add carry to upper result
    # Result: t6:t4 = 0x2_00000004
    
    # Demonstrate absolute value
    li s0, -42
    call abs_value          # s0 becomes 42
    
    # Print success message
    li a0, 1
    la a1, result_msg
    li a2, 31
    li a7, 64
    ecall
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Absolute value function
# Input: s0 = signed integer
# Output: s0 = |s0|
abs_value:
    srai t0, s0, 31         # t0 = sign bit replicated (all 1s if negative)
    xor s0, s0, t0          # Flip bits if negative
    sub s0, s0, t0          # Add 1 if negative (subtracting -1)
    ret
