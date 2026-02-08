# memory.s - RISC-V memory access demonstrations
# Shows alignment, endianness, and different access sizes

.section .data

# Aligned data
.align 2
aligned_word:
    .word 0x12345678

aligned_array:
    .word 1, 2, 3, 4, 5

# Byte array (naturally aligned)
byte_array:
    .byte 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88

# Mixed size data
mixed_data:
    .byte 0xAA
    .byte 0xBB
    .half 0xCCDD
    .word 0x11223344

# Test endianness
.align 2
test_value:
    .word 0xDEADBEEF

# Buffer for experiments
.align 2
buffer:
    .space 32

.section .text
.globl _start

_start:
    # Test 1: Verify endianness (little-endian)
    la t0, test_value
    lw t1, 0(t0)                # t1 = 0xDEADBEEF
    
    # Load individual bytes to verify little-endian
    lbu t2, 0(t0)               # t2 = 0xEF (LSB)
    lbu t3, 1(t0)               # t3 = 0xBE
    lbu t4, 2(t0)               # t4 = 0xAD
    lbu t5, 3(t0)               # t5 = 0xDE (MSB)
    
    # Test 2: Reconstruct word from bytes
    slli t3, t3, 8              # t3 = 0xBE00
    slli t4, t4, 16             # t4 = 0xAD0000
    slli t5, t5, 24             # t5 = 0xDE000000
    or t6, t2, t3               # t6 = 0xBEEF
    or t6, t6, t4               # t6 = 0xADBEEF
    or t6, t6, t5               # t6 = 0xDEADBEEF
    
    # Test 3: Different access sizes on same data
    la t0, aligned_word
    lw s0, 0(t0)                # s0 = 0x12345678 (full word)
    lhu s1, 0(t0)               # s1 = 0x00005678 (lower halfword)
    lhu s2, 2(t0)               # s2 = 0x00001234 (upper halfword)
    lbu s3, 0(t0)               # s3 = 0x00000078 (byte 0)
    lbu s4, 1(t0)               # s4 = 0x00000056 (byte 1)
    
    # Test 4: Sign extension vs unsigned
    la t0, byte_array
    sb zero, 0(t0)              # Store 0x00
    li t1, -1
    sb t1, 1(t0)                # Store 0xFF
    li t1, 127
    sb t1, 2(t0)                # Store 0x7F
    li t1, -128
    sb t1, 3(t0)                # Store 0x80
    
    # Load signed vs unsigned
    lb s0, 0(t0)                # s0 = 0x00000000
    lbu s1, 0(t0)               # s1 = 0x00000000
    lb s2, 1(t0)                # s2 = 0xFFFFFFFF (-1)
    lbu s3, 1(t0)               # s3 = 0x000000FF (255)
    lb s4, 2(t0)                # s4 = 0x0000007F (127)
    lb s5, 3(t0)                # s5 = 0xFFFFFF80 (-128)
    
    # Test 5: Array traversal
    la t0, aligned_array
    li t1, 0                    # sum
    li t2, 5                    # count
    
sum_loop:
    lw t3, 0(t0)                # Load element
    add t1, t1, t3              # Add to sum
    addi t0, t0, 4              # Next element
    addi t2, t2, -1
    bnez t2, sum_loop
    # t1 = 15 (sum of 1+2+3+4+5)
    
    # Test 6: Store different sizes
    la t0, buffer
    li t1, 0x12345678
    sw t1, 0(t0)                # Store word
    
    li t1, 0xABCD
    sh t1, 4(t0)                # Store halfword
    
    li t1, 0xFF
    sb t1, 6(t0)                # Store byte
    
    # Verify stored values
    lw s0, 0(t0)                # s0 = 0x12345678
    lhu s1, 4(t0)               # s1 = 0xABCD
    lbu s2, 6(t0)               # s2 = 0xFF
    
    # Test 7: Byte-wise copy
    la a0, byte_array
    la a1, buffer
    li a2, 8
    call byte_copy
    
    # Exit with success
    li a0, 0
    li a7, 93
    ecall

# Function: byte_copy
# Copy bytes from source to destination
# Input: a0 = source, a1 = dest, a2 = count
byte_copy:
    beqz a2, copy_done
copy_loop:
    lbu t0, 0(a0)               # Load byte
    sb t0, 0(a1)                # Store byte
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    bnez a2, copy_loop
copy_done:
    ret
