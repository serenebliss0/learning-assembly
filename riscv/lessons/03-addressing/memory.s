# memory.s - Memory access operations
# This program demonstrates loading and storing data

.section .data
# Define various data types
byte_val:    .byte 0x42                    # Single byte
half_val:    .half 0x1234                  # Halfword (16-bit)
word_val:    .word 0x12345678              # Word (32-bit)

array:       .word 10, 20, 30, 40, 50      # Array of words
string_data: .string "Hello!"              # String (null-terminated)

msg:         .string "Memory ops done!\n"

.section .bss
# Uninitialized data
buffer:      .space 100                    # Reserve 100 bytes

.section .text
.globl _start

_start:
    # === Loading Different Sizes ===
    
    # Load byte (signed)
    la t0, byte_val            # t0 = address of byte_val
    lb t1, 0(t0)               # t1 = signed byte at t0
    
    # Load byte (unsigned)
    lbu t2, 0(t0)              # t2 = unsigned byte
    
    # Load halfword (16-bit)
    la t0, half_val
    lh t1, 0(t0)               # Load signed halfword
    lhu t2, 0(t0)              # Load unsigned halfword
    
    # Load word (32-bit)
    la t0, word_val
    lw t1, 0(t0)               # Load full word
    
    # === Storing Different Sizes ===
    
    # Store word
    li t0, 0x12345678
    la t1, buffer
    sw t0, 0(t1)               # Store word at buffer
    
    # Store halfword (only lower 16 bits)
    li t0, 0xABCD
    sh t0, 4(t1)               # Store at buffer+4
    
    # Store byte (only lower 8 bits)
    li t0, 0x42
    sb t0, 8(t1)               # Store at buffer+8
    
    # === Array Access ===
    
    la t0, array               # t0 = base address of array
    
    # Access array[0]
    lw t1, 0(t0)               # t1 = 10
    
    # Access array[1]
    lw t2, 4(t0)               # t2 = 20 (offset by 4 bytes)
    
    # Access array[2]
    lw t3, 8(t0)               # t3 = 30 (offset by 8 bytes)
    
    # Calculate: array[i] where i is in t4
    li t4, 3                   # i = 3
    slli t5, t4, 2             # t5 = i * 4 (word size)
    add t5, t0, t5             # t5 = base + offset
    lw t6, 0(t5)               # t6 = array[3] = 40
    
    # Print completion message
    li a0, 1
    la a1, msg
    li a2, 17
    li a7, 64
    ecall
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
