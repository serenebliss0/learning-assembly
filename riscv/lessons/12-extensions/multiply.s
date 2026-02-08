# multiply.s - M Extension: Multiplication and Division
# Requires -march=rv32im or higher

.section .data
msg_multiply:
    .string "=== Multiplication Examples ===\n"
msg_mul_len = . - msg_multiply

msg_divide:
    .string "\n=== Division Examples ===\n"
msg_div_len = . - msg_divide

result_msg:
    .string "Result: "
result_len = . - result_msg

newline:
    .string "\n"

# Buffer for number to string conversion
num_buffer:
    .space 12

.section .text
.globl _start

_start:
    # Print multiplication header
    li a7, 64
    li a0, 1
    la a1, msg_multiply
    li a2, msg_mul_len
    ecall
    
    # === Example 1: Simple multiplication ===
    # 12 × 5 = 60
    li t0, 12
    li t1, 5
    mul t2, t0, t1         # t2 = 12 × 5 = 60
    
    # Print result (simplified - just storing)
    mv s0, t2              # s0 = 60
    
    # === Example 2: Large multiplication (needs high word) ===
    # 0x80000000 × 2 = 0x100000000 (overflows 32 bits!)
    li t0, 0x80000000      # 2^31
    li t1, 2
    
    mul t2, t0, t1         # Lower 32 bits = 0x00000000
    mulhu t3, t0, t1       # Upper 32 bits = 0x00000001
    
    # Result is: t3:t2 = 0x0000000100000000
    mv s1, t2              # s1 = lower 32 bits
    mv s2, t3              # s2 = upper 32 bits
    
    # === Example 3: Signed vs Unsigned ===
    li t0, -1              # 0xFFFFFFFF
    li t1, -1              # 0xFFFFFFFF
    
    mul t2, t0, t1         # Lower bits: 0x00000001 (same for signed/unsigned)
    mulh t3, t0, t1        # Signed: (-1) × (-1) = +1, high = 0x00000000
    mulhu t4, t0, t1       # Unsigned: 0xFFFF... × 0xFFFF..., high = 0xFFFFFFFE
    
    mv s3, t2              # s3 = 1 (lower)
    mv s4, t3              # s4 = 0 (signed high)
    mv s5, t4              # s5 = 0xFFFFFFFE (unsigned high)
    
    # === Example 4: 64-bit multiplication result ===
    # Compute 1000000 × 1000000 = 1000000000000
    li t0, 1000000
    li t1, 1000000
    
    mul t2, t0, t1         # Lower 32 bits
    mulhu t3, t0, t1       # Upper 32 bits
    # Result: t3:t2 = 1000000000000 = 0xE8D4A51000
    
    mv s6, t2              # Lower word
    mv s7, t3              # Upper word
    
    # === Division Examples ===
    # Print division header
    li a7, 64
    li a0, 1
    la a1, msg_divide
    li a2, msg_div_len
    ecall
    
    # === Example 5: Simple division ===
    # 100 ÷ 7 = 14 remainder 2
    li t0, 100
    li t1, 7
    
    div t2, t0, t1         # t2 = 100 ÷ 7 = 14
    rem t3, t0, t1         # t3 = 100 % 7 = 2
    
    mv s8, t2              # s8 = quotient (14)
    mv s9, t3              # s9 = remainder (2)
    
    # === Example 6: Signed division ===
    # -100 ÷ 7 = -14 remainder -2
    li t0, -100
    li t1, 7
    
    div t2, t0, t1         # t2 = -100 ÷ 7 = -14
    rem t3, t0, t1         # t3 = -100 % 7 = -2
    
    mv s10, t2             # s10 = -14
    mv s11, t3             # s11 = -2
    
    # === Example 7: Unsigned division ===
    # 0xFFFFFFFF ÷ 2 (unsigned vs signed)
    li t0, -1              # 0xFFFFFFFF
    li t1, 2
    
    div t2, t0, t1         # Signed: -1 ÷ 2 = 0 (rounds toward zero)
    divu t3, t0, t1        # Unsigned: 0xFFFFFFFF ÷ 2 = 0x7FFFFFFF
    
    # === Example 8: Division by zero (undefined!) ===
    # Note: Division by zero returns specific values (not exception):
    # div:  returns -1
    # divu: returns 0xFFFFFFFF (all bits set)
    # rem:  returns dividend
    # remu: returns dividend
    
    li t0, 42
    li t1, 0               # Zero!
    
    div t2, t0, t1         # t2 = -1 (all bits set)
    rem t3, t0, t1         # t3 = 42 (dividend)
    
    # === Exit ===
    li a7, 93
    li a0, 0
    ecall

# Helper function: Print number (simplified version)
# Input: a0 = number to print
print_number:
    # This is a simplified placeholder
    # A full implementation would convert to decimal string
    ret
