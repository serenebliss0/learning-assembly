# RISC-V Basic Operations Examples
# Common arithmetic, logical, and comparison operations

.data
msg1:    .string "Addition: 5 + 3 = "
msg2:    .string "\nSubtraction: 10 - 4 = "
msg3:    .string "\nMultiplication: 6 * 7 = "
msg4:    .string "\nDivision: 20 / 4 = "
msg5:    .string "\nRemainder: 17 % 5 = "
msg6:    .string "\nAND: 0xFF & 0x0F = "
msg7:    .string "\nOR: 0xF0 | 0x0F = "
msg8:    .string "\nXOR: 0xFF ^ 0xAA = "
msg9:    .string "\nShift left: 1 << 3 = "
msg10:   .string "\nShift right: 16 >> 2 = "
newline: .string "\n"

.text
.globl main

main:
    # ========================================
    # Arithmetic Operations
    # ========================================
    
    # Addition
    la a0, msg1
    li a7, 4
    ecall
    li a0, 5
    li a1, 3
    add a0, a0, a1        # a0 = 5 + 3 = 8
    li a7, 1
    ecall
    
    # Subtraction
    la a0, msg2
    li a7, 4
    ecall
    li a0, 10
    li a1, 4
    sub a0, a0, a1        # a0 = 10 - 4 = 6
    li a7, 1
    ecall
    
    # Multiplication (requires M extension)
    la a0, msg3
    li a7, 4
    ecall
    li a0, 6
    li a1, 7
    mul a0, a0, a1        # a0 = 6 * 7 = 42
    li a7, 1
    ecall
    
    # Division (requires M extension)
    la a0, msg4
    li a7, 4
    ecall
    li a0, 20
    li a1, 4
    div a0, a0, a1        # a0 = 20 / 4 = 5
    li a7, 1
    ecall
    
    # Remainder (requires M extension)
    la a0, msg5
    li a7, 4
    ecall
    li a0, 17
    li a1, 5
    rem a0, a0, a1        # a0 = 17 % 5 = 2
    li a7, 1
    ecall
    
    # ========================================
    # Logical Operations
    # ========================================
    
    # AND
    la a0, msg6
    li a7, 4
    ecall
    li a0, 0xFF
    li a1, 0x0F
    and a0, a0, a1        # a0 = 0xFF & 0x0F = 0x0F (15)
    li a7, 1
    ecall
    
    # OR
    la a0, msg7
    li a7, 4
    ecall
    li a0, 0xF0
    li a1, 0x0F
    or a0, a0, a1         # a0 = 0xF0 | 0x0F = 0xFF (255)
    li a7, 1
    ecall
    
    # XOR
    la a0, msg8
    li a7, 4
    ecall
    li a0, 0xFF
    li a1, 0xAA
    xor a0, a0, a1        # a0 = 0xFF ^ 0xAA = 0x55 (85)
    li a7, 1
    ecall
    
    # ========================================
    # Shift Operations
    # ========================================
    
    # Shift left
    la a0, msg9
    li a7, 4
    ecall
    li a0, 1
    slli a0, a0, 3        # a0 = 1 << 3 = 8
    li a7, 1
    ecall
    
    # Shift right
    la a0, msg10
    li a7, 4
    ecall
    li a0, 16
    srli a0, a0, 2        # a0 = 16 >> 2 = 4
    li a7, 1
    ecall
    
    # Print final newline
    la a0, newline
    li a7, 4
    ecall
    
    # Exit
    li a7, 10
    ecall

# ========================================
# Additional Examples (for reference)
# ========================================

# Set less than (signed)
example_slt:
    li t0, 5
    li t1, 10
    slt t2, t0, t1        # t2 = 1 (5 < 10)
    ret

# Set less than (unsigned)
example_sltu:
    li t0, -1             # 0xFFFFFFFF (unsigned: 4294967295)
    li t1, 10
    sltu t2, t0, t1       # t2 = 0 (4294967295 > 10)
    ret

# Load upper immediate
example_lui:
    lui t0, 0x12345       # t0 = 0x12345000
    ret

# Add upper immediate to PC
example_auipc:
    auipc t0, 0x1000      # t0 = PC + 0x1000000
    ret
