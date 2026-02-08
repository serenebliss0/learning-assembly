# alignment.s - Demonstrates memory alignment issues and solutions

.section .data

# Properly aligned data
.align 2
aligned_words:
    .word 0x11111111
    .word 0x22222222
    .word 0x33333333

# Byte array for testing alignment
.align 2
byte_buffer:
    .space 32

# Test data for unaligned access
.align 0
misaligned_data:
    .byte 0xFF                  # Offset by 1
    .word 0x12345678            # Now at offset 1 (misaligned!)
    .byte 0xAA
    .word 0xDEADBEEF            # At offset 6 (misaligned!)

.section .text
.globl _start

_start:
    # Test 1: Check address alignment
    la t0, aligned_words
    call check_alignment        # a0 = alignment (should be 4)
    
    # Test 2: Load aligned words (safe and fast)
    la t0, aligned_words
    lw s0, 0(t0)                # s0 = 0x11111111
    lw s1, 4(t0)                # s1 = 0x22222222
    lw s2, 8(t0)                # s2 = 0x33333333
    
    # Test 3: Handle misaligned word (byte-by-byte method)
    la t0, misaligned_data
    addi a0, t0, 1              # Point to misaligned word
    call load_unaligned_word
    mv s3, a0                   # s3 = 0x12345678
    
    # Test 4: Another misaligned word
    la t0, misaligned_data
    addi a0, t0, 6              # Point to second misaligned word
    call load_unaligned_word
    mv s4, a0                   # s4 = 0xDEADBEEF
    
    # Test 5: Align pointer before storing
    la t0, byte_buffer
    addi t0, t0, 1              # Make it misaligned
    call align_to_word          # a0 = aligned address
    
    # Store at aligned address
    li t1, 0xAAAAAAAA
    sw t1, 0(a0)                # Safe
    li t1, 0xBBBBBBBB
    sw t1, 4(a0)                # Safe
    
    # Test 6: Store word to potentially misaligned address
    la a0, byte_buffer
    addi a0, a0, 9              # Misaligned address
    li a1, 0x12345678
    call store_unaligned_word
    
    # Verify by loading byte-by-byte
    la t0, byte_buffer
    addi t0, t0, 9
    lbu s5, 0(t0)               # s5 = 0x78
    lbu s6, 1(t0)               # s6 = 0x56
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: check_alignment
# Check alignment of address
# Input: t0 = address
# Output: a0 = alignment (1, 2, 4, or higher)
check_alignment:
    mv a0, t0
    
    # Check word alignment (4 bytes)
    andi t1, a0, 0x3
    beqz t1, aligned_4
    
    # Check halfword alignment (2 bytes)
    andi t1, a0, 0x1
    beqz t1, aligned_2
    
    # Byte aligned only
    li a0, 1
    ret

aligned_2:
    li a0, 2
    ret

aligned_4:
    li a0, 4
    ret

# Function: load_unaligned_word
# Safely load a potentially misaligned word
# Input: a0 = address
# Output: a0 = word value
load_unaligned_word:
    # Check if actually aligned
    andi t0, a0, 0x3
    beqz t0, load_aligned
    
    # Unaligned: load byte-by-byte
    mv t2, a0                   # Save address
    lbu t0, 0(t2)               # Byte 0 (LSB)
    lbu t1, 1(t2)               # Byte 1
    lbu t3, 2(t2)               # Byte 2
    lbu t4, 3(t2)               # Byte 3 (MSB)
    
    # Reconstruct word (little-endian)
    slli t1, t1, 8
    slli t3, t3, 16
    slli t4, t4, 24
    or a0, t0, t1
    or a0, a0, t3
    or a0, a0, t4
    ret

load_aligned:
    lw a0, 0(a0)                # Fast aligned load
    ret

# Function: align_to_word
# Align address to word boundary
# Input: t0 = address
# Output: a0 = aligned address (rounded down)
align_to_word:
    mv a0, t0
    andi a0, a0, ~3             # Clear lower 2 bits
    ret

# Function: store_unaligned_word
# Safely store word to potentially misaligned address
# Input: a0 = address, a1 = value
store_unaligned_word:
    # Check if aligned
    andi t0, a0, 0x3
    beqz t0, store_aligned
    
    # Unaligned: store byte-by-byte
    mv t2, a0                   # Save address
    mv t3, a1                   # Save value
    
    # Extract and store bytes
    andi t0, t3, 0xFF
    sb t0, 0(t2)                # Byte 0
    
    srli t3, t3, 8
    andi t0, t3, 0xFF
    sb t0, 1(t2)                # Byte 1
    
    srli t3, t3, 8
    andi t0, t3, 0xFF
    sb t0, 2(t2)                # Byte 2
    
    srli t3, t3, 8
    sb t3, 3(t2)                # Byte 3
    ret

store_aligned:
    sw a1, 0(a0)                # Fast aligned store
    ret
