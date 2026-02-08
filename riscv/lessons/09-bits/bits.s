# bits.s - Comprehensive bit manipulation demonstrations

.section .text
.globl _start

_start:
    # Test 1: Basic shift operations
    li t0, 1
    slli s0, t0, 0              # s0 = 1
    slli s1, t0, 1              # s1 = 2
    slli s2, t0, 2              # s2 = 4
    slli s3, t0, 3              # s3 = 8
    slli s4, t0, 4              # s4 = 16
    slli s5, t0, 5              # s5 = 32
    
    # Test 2: Shift right (divide by powers of 2)
    li t0, 256
    srli t1, t0, 1              # t1 = 128
    srli t2, t0, 2              # t2 = 64
    srli t3, t0, 3              # t3 = 32
    srli t4, t0, 4              # t4 = 16
    
    # Test 3: Arithmetic shift (preserve sign)
    li t0, -32                  # t0 = 0xFFFFFFE0
    srai t1, t0, 1              # t1 = -16 (0xFFFFFFF0)
    srai t2, t0, 2              # t2 = -8 (0xFFFFFFF8)
    srai t3, t0, 3              # t3 = -4 (0xFFFFFFFC)
    
    # Compare with logical shift
    srli t4, t0, 1              # t4 = 0x7FFFFFF0 (huge positive)
    
    # Test 4: Logical operations
    li t0, 0b11110000
    li t1, 0b10101010
    
    and s0, t0, t1              # s0 = 0b10100000
    or  s1, t0, t1              # s1 = 0b11111010
    xor s2, t0, t1              # s2 = 0b01011010
    xori s3, t0, -1             # s3 = 0b00001111 (NOT)
    
    # Test 5: Bit masking and extraction
    li t0, 0x12345678
    
    # Extract bytes
    andi s0, t0, 0xFF           # s0 = 0x78 (byte 0)
    srli t1, t0, 8
    andi s1, t1, 0xFF           # s1 = 0x56 (byte 1)
    srli t1, t0, 16
    andi s2, t1, 0xFF           # s2 = 0x34 (byte 2)
    srli s3, t0, 24             # s3 = 0x12 (byte 3)
    
    # Test 6: Set, clear, toggle bits
    li t0, 0b00001000
    
    # Set bit 5
    ori t1, t0, 0b00100000      # t1 = 0b00101000
    
    # Clear bit 3
    li t2, 0b11110111
    and t1, t1, t2              # t1 = 0b00100000
    
    # Toggle bit 6
    xori t1, t1, 0b01000000     # t1 = 0b01100000
    
    # Test 7: Bit operations with functions
    li a0, 0b10101010
    li a1, 5
    call test_bit
    mv s0, a0                   # s0 = 1 (bit 5 is set)
    
    li a0, 0b10101010
    li a1, 4
    call test_bit
    mv s1, a0                   # s1 = 0 (bit 4 is clear)
    
    # Test 8: Count set bits
    li a0, 0b11111111
    call count_bits
    mv s2, a0                   # s2 = 8
    
    li a0, 0b10101010
    call count_bits
    mv s3, a0                   # s3 = 4
    
    # Test 9: Find first set bit
    li a0, 0b00101000
    call find_first_set
    mv s4, a0                   # s4 = 3
    
    # Test 10: Reverse bits in byte
    li a0, 0b10110001
    call reverse_byte
    mv s5, a0                   # s5 = 0b10001101
    
    # Test 11: Rotate operations
    li a0, 0x12345678
    li a1, 4
    call rotate_left
    mv s6, a0                   # s6 = 0x23456781
    
    li a0, 0x12345678
    li a1, 4
    call rotate_right
    mv s7, a0                   # s7 = 0x81234567
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: test_bit
# Test if specific bit is set
# Input: a0 = value, a1 = bit position (0-31)
# Output: a0 = 1 if set, 0 if clear
test_bit:
    li t0, 1
    sll t0, t0, a1              # Create mask
    and t0, a0, t0              # Test bit
    snez a0, t0                 # Convert to 1 or 0
    ret

# Function: set_bit
# Set specific bit
# Input: a0 = value, a1 = bit position
# Output: a0 = value with bit set
set_bit:
    li t0, 1
    sll t0, t0, a1              # Create mask
    or a0, a0, t0               # Set bit
    ret

# Function: clear_bit
# Clear specific bit
# Input: a0 = value, a1 = bit position
# Output: a0 = value with bit cleared
clear_bit:
    li t0, 1
    sll t0, t0, a1              # Create mask
    not t0, t0                  # Invert mask
    and a0, a0, t0              # Clear bit
    ret

# Function: toggle_bit
# Toggle specific bit
# Input: a0 = value, a1 = bit position
# Output: a0 = value with bit toggled
toggle_bit:
    li t0, 1
    sll t0, t0, a1              # Create mask
    xor a0, a0, t0              # Toggle bit
    ret

# Function: count_bits
# Count number of set bits (population count)
# Input: a0 = value
# Output: a0 = number of set bits
count_bits:
    li t0, 0                    # count = 0
    li t1, 32                   # remaining bits
    mv t2, a0                   # working copy
    
count_loop:
    beqz t1, count_done
    andi t3, t2, 1              # Check lowest bit
    add t0, t0, t3              # Add to count
    srli t2, t2, 1              # Shift to next bit
    addi t1, t1, -1
    j count_loop
    
count_done:
    mv a0, t0
    ret

# Function: find_first_set
# Find position of first (lowest) set bit
# Input: a0 = value
# Output: a0 = bit position, or -1 if no bits set
find_first_set:
    beqz a0, ffs_none
    
    li t0, 0                    # position = 0
    mv t1, a0
    
ffs_loop:
    andi t2, t1, 1              # Check lowest bit
    bnez t2, ffs_found          # Found it
    
    srli t1, t1, 1              # Next bit
    addi t0, t0, 1
    j ffs_loop
    
ffs_found:
    mv a0, t0
    ret

ffs_none:
    li a0, -1
    ret

# Function: reverse_byte
# Reverse bits in a byte (lower 8 bits)
# Input: a0 = byte value
# Output: a0 = reversed byte
reverse_byte:
    li t0, 0                    # result
    li t1, 8                    # bit count
    mv t2, a0                   # working copy
    
reverse_loop:
    beqz t1, reverse_done
    slli t0, t0, 1              # Shift result left
    andi t3, t2, 1              # Get lowest bit of input
    or t0, t0, t3               # Add to result
    srli t2, t2, 1              # Shift input right
    addi t1, t1, -1
    j reverse_loop
    
reverse_done:
    mv a0, t0
    ret

# Function: rotate_left
# Rotate value left by N bits
# Input: a0 = value, a1 = rotation amount (0-31)
# Output: a0 = rotated value
rotate_left:
    # Left part: value << n
    sll t0, a0, a1
    
    # Right part: value >> (32 - n)
    li t1, 32
    sub t1, t1, a1
    srl t2, a0, t1
    
    # Combine
    or a0, t0, t2
    ret

# Function: rotate_right
# Rotate value right by N bits
# Input: a0 = value, a1 = rotation amount (0-31)
# Output: a0 = rotated value
rotate_right:
    # Right part: value >> n
    srl t0, a0, a1
    
    # Left part: value << (32 - n)
    li t1, 32
    sub t1, t1, a1
    sll t2, a0, t1
    
    # Combine
    or a0, t0, t2
    ret

# Function: isolate_lowest_set
# Isolate the lowest set bit
# Input: a0 = value
# Output: a0 = value with only lowest bit set
isolate_lowest_set:
    neg t0, a0                  # t0 = -a0
    and a0, a0, t0              # a0 & -a0
    ret

# Function: clear_lowest_set
# Clear the lowest set bit
# Input: a0 = value
# Output: a0 = value with lowest bit cleared
clear_lowest_set:
    addi t0, a0, -1             # t0 = a0 - 1
    and a0, a0, t0              # a0 & (a0 - 1)
    ret

# Function: is_power_of_2
# Check if value is a power of 2
# Input: a0 = value
# Output: a0 = 1 if power of 2, 0 otherwise
is_power_of_2:
    beqz a0, not_power          # 0 is not a power of 2
    
    addi t0, a0, -1             # t0 = a0 - 1
    and t1, a0, t0              # a0 & (a0 - 1)
    beqz t1, is_power
    
not_power:
    li a0, 0
    ret

is_power:
    li a0, 1
    ret
