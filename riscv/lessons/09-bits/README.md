# Lesson 09: Bit Manipulation

Bit manipulation is fundamental to low-level programming. RISC-V provides powerful instructions for shifting, masking, and logical operations.

## Learning Objectives

By the end of this lesson, you'll:
- Master shift operations (SLL, SRL, SRA)
- Use logical operations (AND, OR, XOR, NOT)
- Test and set individual bits
- Extract and insert bit fields
- Work with bit masks
- Implement bit rotation patterns
- Apply bit manipulation tricks

## Shift Operations

**Logical Shift Left (SLL):**
```asm
sll rd, rs1, rs2            # rd = rs1 << rs2
slli rd, rs1, imm           # rd = rs1 << imm (0-31)
```

Shifts left, filling with zeros. Each shift left multiplies by 2.

**Logical Shift Right (SRL):**
```asm
srl rd, rs1, rs2            # rd = rs1 >> rs2 (logical)
srli rd, rs1, imm           # rd = rs1 >> imm (logical)
```

Shifts right, filling with zeros. Treats value as unsigned.

**Arithmetic Shift Right (SRA):**
```asm
sra rd, rs1, rs2            # rd = rs1 >> rs2 (arithmetic)
srai rd, rs1, imm           # rd = rs1 >> imm (arithmetic)
```

Shifts right, preserving sign bit. Divides signed numbers by powers of 2.

### Shift Examples

```asm
li t0, 8                    # t0 = 0x00000008

# Logical shift left
slli t1, t0, 2              # t1 = 32 (8 * 4)
slli t2, t0, 4              # t2 = 128 (8 * 16)

# Logical shift right
li t0, 128                  # t0 = 0x00000080
srli t1, t0, 3              # t1 = 16 (128 / 8)

# Arithmetic shift right (signed)
li t0, -16                  # t0 = 0xFFFFFFF0
srai t1, t0, 2              # t1 = -4 (sign preserved)
```

## Logical Operations

**AND:**
```asm
and rd, rs1, rs2            # rd = rs1 & rs2
andi rd, rs1, imm           # rd = rs1 & imm
```

Result bit is 1 only if both input bits are 1.

**OR:**
```asm
or rd, rs1, rs2             # rd = rs1 | rs2
ori rd, rs1, imm            # rd = rs1 | imm
```

Result bit is 1 if either input bit is 1.

**XOR:**
```asm
xor rd, rs1, rs2            # rd = rs1 ^ rs2
xori rd, rs1, imm           # rd = rs1 ^ imm
```

Result bit is 1 if input bits are different.

**NOT (via XOR with -1):**
```asm
xori rd, rs1, -1            # rd = ~rs1
```

Inverts all bits.

### Logical Examples

```asm
li t0, 0b11001100
li t1, 0b10101010

and t2, t0, t1              # t2 = 0b10001000
or  t3, t0, t1              # t3 = 0b11101110
xor t4, t0, t1              # t4 = 0b01100110
xori t5, t0, -1             # t5 = 0b00110011 (NOT t0)
```

## Truth Tables

**AND:**
```
A  B  |  A&B
0  0  |   0
0  1  |   0
1  0  |   0
1  1  |   1
```

**OR:**
```
A  B  |  A|B
0  0  |   0
0  1  |   1
1  0  |   1
1  1  |   1
```

**XOR:**
```
A  B  |  A^B
0  0  |   0
0  1  |   1
1  0  |   1
1  1  |   0
```

## The Code - Bit Operations

```asm
# bits.s - Comprehensive bit manipulation demonstrations

.section .text
.globl _start

_start:
    # Test 1: Shift operations
    li t0, 1
    slli s0, t0, 0              # s0 = 1
    slli s1, t0, 1              # s1 = 2
    slli s2, t0, 2              # s2 = 4
    slli s3, t0, 3              # s3 = 8
    slli s4, t0, 4              # s4 = 16
    
    # Test 2: Shift right operations
    li t0, 128
    srli t1, t0, 1              # t1 = 64
    srli t2, t0, 2              # t2 = 32
    srli t3, t0, 3              # t3 = 16
    
    # Test 3: Arithmetic shift (sign extension)
    li t0, -16                  # t0 = 0xFFFFFFF0
    srai t1, t0, 1              # t1 = -8 (0xFFFFFFF8)
    srai t2, t0, 2              # t2 = -4 (0xFFFFFFFC)
    
    # Compare with logical shift
    srli t3, t0, 1              # t3 = 0x7FFFFFF8 (unsigned)
    
    # Test 4: Logical operations
    li t0, 0b11110000
    li t1, 0b10101010
    
    and t2, t0, t1              # t2 = 0b10100000
    or  t3, t0, t1              # t3 = 0b11111010
    xor t4, t0, t1              # t4 = 0b01011010
    
    # Test 5: Bit masking
    li t0, 0x12345678
    
    # Extract lower byte
    andi t1, t0, 0xFF           # t1 = 0x78
    
    # Extract lower halfword
    andi t2, t0, 0xFFFF         # t2 = 0x5678
    
    # Extract upper halfword
    srli t3, t0, 16
    andi t3, t3, 0xFFFF         # t3 = 0x1234
    
    # Test 6: Set, clear, toggle bits
    li t0, 0b00001000           # Bit 3 is set
    
    # Set bit 5
    ori t1, t0, 0b00100000      # t1 = 0b00101000
    
    # Clear bit 3
    andi t2, t1, ~0b00001000    # t2 = 0b00100000
    
    # Toggle bit 6
    xori t3, t2, 0b01000000     # t3 = 0b01100000
    
    # Test 7: Test if bit is set
    li t0, 0b01010101
    li a0, 6                    # Test bit 6
    call test_bit
    # a0 = 1 (bit is set)
    
    # Test 8: Count set bits
    li a0, 0b01010101
    call count_bits
    # a0 = 4
    
    # Test 9: Reverse bits
    li a0, 0x12345678
    call reverse_bits_byte
    # a0 = 0x1E6A2C48
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: test_bit
# Test if a specific bit is set
# Input: t0 = value, a0 = bit position
# Output: a0 = 1 if set, 0 if clear
test_bit:
    li t1, 1
    sll t1, t1, a0              # Create mask (1 << bit_pos)
    and t2, t0, t1              # Test bit
    snez a0, t2                 # a0 = 1 if non-zero
    ret

# Function: count_bits
# Count number of set bits (population count)
# Input: a0 = value
# Output: a0 = count
count_bits:
    li t0, 0                    # count = 0
    li t1, 32                   # bit position
    mv t2, a0                   # working value
    
count_loop:
    beqz t1, count_done
    andi t3, t2, 1              # Check lowest bit
    add t0, t0, t3              # Add to count
    srli t2, t2, 1              # Shift right
    addi t1, t1, -1
    j count_loop
    
count_done:
    mv a0, t0
    ret

# Function: reverse_bits_byte
# Reverse bits in each byte of word
# Input: a0 = value
# Output: a0 = reversed
reverse_bits_byte:
    # Save registers
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    
    mv s0, a0                   # Save input
    li s1, 0                    # Result
    
    # Process byte 0
    andi a0, s0, 0xFF
    call reverse_byte
    or s1, s1, a0
    
    # Process byte 1
    srli a0, s0, 8
    andi a0, a0, 0xFF
    call reverse_byte
    slli a0, a0, 8
    or s1, s1, a0
    
    # Process byte 2
    srli a0, s0, 16
    andi a0, a0, 0xFF
    call reverse_byte
    slli a0, a0, 16
    or s1, s1, a0
    
    # Process byte 3
    srli a0, s0, 24
    call reverse_byte
    slli a0, a0, 24
    or s1, s1, a0
    
    mv a0, s1
    
    # Restore
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

# Function: reverse_byte
# Reverse bits in a byte
# Input: a0 = byte (lower 8 bits)
# Output: a0 = reversed byte
reverse_byte:
    li t0, 0                    # result
    li t1, 8                    # bit count
    
reverse_byte_loop:
    beqz t1, reverse_byte_done
    slli t0, t0, 1              # Shift result left
    andi t2, a0, 1              # Get lowest bit
    or t0, t0, t2               # Add to result
    srli a0, a0, 1              # Shift input right
    addi t1, t1, -1
    j reverse_byte_loop
    
reverse_byte_done:
    mv a0, t0
    ret
```

## Breaking It Down

### Shift Left (Multiply by 2^n)

```asm
slli t1, t0, 3              # t1 = t0 * 8
```

Shifting left by N is equivalent to multiplying by 2^N:
- Shift left 1: multiply by 2
- Shift left 2: multiply by 4
- Shift left 3: multiply by 8
- Shift left 10: multiply by 1024

### Shift Right (Divide by 2^n)

```asm
srli t1, t0, 2              # t1 = t0 / 4 (unsigned)
srai t1, t0, 2              # t1 = t0 / 4 (signed)
```

Use `srli` for unsigned, `srai` for signed division by powers of 2.

### Bit Masking

```asm
andi t1, t0, 0xFF           # Extract lower 8 bits
```

AND with a mask keeps only desired bits, clearing others.

### Setting Bits

```asm
ori t1, t0, 0b00001000      # Set bit 3
```

OR with a mask sets specific bits to 1.

### Clearing Bits

```asm
andi t1, t0, ~0b00001000    # Clear bit 3
```

AND with inverted mask clears specific bits to 0.

### Toggling Bits

```asm
xori t1, t0, 0b00001000     # Toggle bit 3
```

XOR with a mask flips specific bits.

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 -o bits.o bits.s

# Link
riscv64-unknown-elf-ld -m elf32lriscv -o bits bits.o

# Run
qemu-riscv32 bits
```

## The Code - Bit Fields

```asm
# bitfields.s - Bit field extraction and insertion

.section .data
# Example: RGB color value (24-bit)
# Format: [unused:8][R:8][G:8][B:8]
color:
    .word 0x00FF8040            # Red=255, Green=128, Blue=64

.section .text
.globl _start

_start:
    # Test 1: Extract color components
    lw a0, color
    call extract_red
    mv s0, a0                   # s0 = 255
    
    lw a0, color
    call extract_green
    mv s1, a0                   # s1 = 128
    
    lw a0, color
    call extract_blue
    mv s2, a0                   # s2 = 64
    
    # Test 2: Create new color
    li a0, 100                  # Red
    li a1, 200                  # Green
    li a2, 50                   # Blue
    call make_rgb
    mv s3, a0                   # s3 = 0x0064C832
    
    # Test 3: Modify color component
    lw a0, color
    li a1, 180                  # New green value
    call set_green
    mv s4, a0
    
    # Test 4: Extract bit field (generic)
    li a0, 0x12345678
    li a1, 12                   # Start bit
    li a2, 8                    # Width
    call extract_bitfield
    # a0 = 0x56
    
    # Test 5: Insert bit field
    li a0, 0x12345678
    li a1, 0xAB                 # Value to insert
    li a2, 8                    # Start bit
    li a3, 8                    # Width
    call insert_bitfield
    # a0 = 0x1234AB78
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: extract_red
# Extract red component from RGB color
# Input: a0 = color (0x00RRGGBB)
# Output: a0 = red (0-255)
extract_red:
    srli a0, a0, 16             # Shift right 16 bits
    andi a0, a0, 0xFF           # Mask to 8 bits
    ret

# Function: extract_green
# Extract green component from RGB color
# Input: a0 = color (0x00RRGGBB)
# Output: a0 = green (0-255)
extract_green:
    srli a0, a0, 8              # Shift right 8 bits
    andi a0, a0, 0xFF           # Mask to 8 bits
    ret

# Function: extract_blue
# Extract blue component from RGB color
# Input: a0 = color (0x00RRGGBB)
# Output: a0 = blue (0-255)
extract_blue:
    andi a0, a0, 0xFF           # Mask to 8 bits
    ret

# Function: make_rgb
# Create RGB color from components
# Input: a0 = red, a1 = green, a2 = blue
# Output: a0 = color (0x00RRGGBB)
make_rgb:
    andi a0, a0, 0xFF           # Ensure 8-bit
    andi a1, a1, 0xFF
    andi a2, a2, 0xFF
    
    slli a0, a0, 16             # Red to bits 23-16
    slli a1, a1, 8              # Green to bits 15-8
    # Blue already in bits 7-0
    
    or a0, a0, a1
    or a0, a0, a2
    ret

# Function: set_green
# Set green component of RGB color
# Input: a0 = color, a1 = new green value
# Output: a0 = modified color
set_green:
    # Clear green bits
    li t0, 0xFF00
    not t0, t0                  # Invert mask
    and a0, a0, t0              # Clear green
    
    # Set new green
    andi a1, a1, 0xFF           # Ensure 8-bit
    slli a1, a1, 8              # Position green
    or a0, a0, a1               # Combine
    ret

# Function: extract_bitfield
# Extract arbitrary bit field from value
# Input: a0 = value, a1 = start_bit, a2 = width
# Output: a0 = extracted field
extract_bitfield:
    # Shift right to start position
    srl a0, a0, a1
    
    # Create mask: (1 << width) - 1
    li t0, 1
    sll t0, t0, a2              # t0 = 1 << width
    addi t0, t0, -1             # t0 = (1 << width) - 1
    
    # Apply mask
    and a0, a0, t0
    ret

# Function: insert_bitfield
# Insert value into bit field
# Input: a0 = original, a1 = value, a2 = start_bit, a3 = width
# Output: a0 = modified value
insert_bitfield:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    
    mv s0, a0                   # Save original
    
    # Create mask for field
    li t0, 1
    sll t0, t0, a3              # t0 = 1 << width
    addi t0, t0, -1             # t0 = (1 << width) - 1
    
    # Mask value to width
    and a1, a1, t0
    
    # Position value
    sll s1, a1, a2              # s1 = value << start_bit
    
    # Create clearing mask
    sll t0, t0, a2              # Position mask
    not t0, t0                  # Invert
    
    # Clear field in original
    and s0, s0, t0
    
    # Insert new value
    or a0, s0, s1
    
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret
```

## Breaking It Down - Bit Fields

### Extracting a Field

```asm
srli a0, a0, 8              # Shift to align field
andi a0, a0, 0xFF           # Mask to field width
```

Process:
1. Shift right to move field to LSB position
2. AND with mask to extract just the field

### Inserting a Field

```asm
andi a1, a1, 0xFF           # Mask value to field width
slli a1, a1, 8              # Shift to position
or a0, a0, a1               # Combine with original
```

Process:
1. Mask value to field width
2. Shift to target position
3. OR with original (after clearing old value)

## Common Bit Patterns

### Create Mask

```asm
# Mask with N lower bits set
li t0, 1
slli t0, t0, N              # t0 = 1 << N
addi t0, t0, -1             # t0 = (1 << N) - 1
# Result: 0x000000FF for N=8
```

### Rotate Left (No native instruction)

```asm
# Rotate t0 left by N bits
slli t1, t0, N              # Left part
li t2, 32
sub t2, t2, N
srli t2, t0, t2             # Right part
or t0, t1, t2               # Combine
```

### Rotate Right

```asm
# Rotate t0 right by N bits
srli t1, t0, N              # Right part
li t2, 32
sub t2, t2, N
slli t2, t0, t2             # Left part
or t0, t1, t2               # Combine
```

### Swap Nibbles

```asm
# Swap lower nibbles (4 bits) of byte
andi t1, t0, 0xF0           # Upper nibble
andi t2, t0, 0x0F           # Lower nibble
srli t1, t1, 4
slli t2, t2, 4
or t0, t1, t2
```

### Check Power of 2

```asm
# Check if value is power of 2
# Power of 2 has exactly one bit set
# Method: n & (n-1) == 0
addi t1, t0, -1
and t2, t0, t1
beqz t2, is_power_of_2
```

### Isolate Lowest Set Bit

```asm
# Get lowest set bit
# Method: n & (-n)
neg t1, t0
and t2, t0, t1
# t2 has only the lowest bit of t0
```

### Clear Lowest Set Bit

```asm
# Clear lowest set bit
# Method: n & (n-1)
addi t1, t0, -1
and t0, t0, t1
```

## Experiments to Try

1. **Shift Performance**
   - Compare shift vs multiply/divide
   - Verify shift is faster

2. **Bit Counting**
   - Implement different algorithms
   - Compare speeds

3. **Endian Conversion**
   - Swap byte order using shifts
   - Verify correctness

4. **Bit Packing**
   - Pack multiple small values into one word
   - Extract them correctly

## Exercises

**Exercise 1:** Write a function to check if a number is even using bit operations (no division).

**Exercise 2:** Implement a function to swap two values without using a temporary variable (XOR swap).

**Exercise 3:** Create a function to align a value up to the nearest power of 2.

**Exercise 4:** Write a function to find the position of the highest set bit.

<details>
<summary>Solution to Exercise 1</summary>

```asm
# Check if number is even
# Method: test if lowest bit is 0
# Input: a0 = value
# Output: a0 = 1 if even, 0 if odd
is_even:
    andi a0, a0, 1              # Get lowest bit
    xori a0, a0, 1              # Flip (1->0, 0->1)
    ret

_start:
    li a0, 42
    call is_even
    # a0 = 1 (42 is even)
    
    li a0, 37
    call is_even
    # a0 = 0 (37 is odd)
    
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 2</summary>

```asm
# XOR swap - swap two values without temporary
# Input: a0 = value1, a1 = value2
# Output: a0 = value2, a1 = value1
xor_swap:
    xor a0, a0, a1              # a0 = a0 ^ a1
    xor a1, a0, a1              # a1 = (a0 ^ a1) ^ a1 = a0
    xor a0, a0, a1              # a0 = (a0 ^ a1) ^ a0 = a1
    ret

_start:
    li a0, 10
    li a1, 20
    call xor_swap
    # a0 = 20, a1 = 10
    
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 3</summary>

```asm
# Align value up to power of 2
# Input: a0 = value, a1 = alignment (must be power of 2)
# Output: a0 = aligned value
align_up:
    addi t0, a1, -1             # alignment - 1
    add a0, a0, t0              # value + (alignment - 1)
    not t0, t0                  # ~(alignment - 1)
    and a0, a0, t0              # Round down
    ret

_start:
    li a0, 13
    li a1, 8                    # Align to 8 bytes
    call align_up
    # a0 = 16
    
    li a0, 100
    li a1, 16
    call align_up
    # a0 = 112
    
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 4</summary>

```asm
# Find position of highest set bit (MSB)
# Input: a0 = value
# Output: a0 = bit position (0-31), or -1 if value is 0
find_msb:
    beqz a0, msb_zero           # Handle 0
    
    li t0, 31                   # Start from bit 31
    li t1, 1
    slli t1, t1, 31             # t1 = 0x80000000
    
msb_loop:
    and t2, a0, t1              # Test bit
    bnez t2, msb_found          # Found it
    
    srli t1, t1, 1              # Next bit
    addi t0, t0, -1
    bnez t1, msb_loop           # Continue if bits remain
    
msb_zero:
    li a0, -1                   # Not found
    ret

msb_found:
    mv a0, t0
    ret

_start:
    li a0, 0x00001000
    call find_msb
    # a0 = 12
    
    li a0, 0x80000000
    call find_msb
    # a0 = 31
    
    li a7, 93
    ecall
```
</details>

## Deep Dive: Bit Tricks

### Fast Modulo Power of 2

```asm
# n % 8 using bit operations
andi a0, a0, 7              # Same as a0 % 8
```

### Absolute Value

```asm
# abs(n) without branching
srai t0, a0, 31             # t0 = (n < 0) ? -1 : 0
xor a0, a0, t0              # Flip bits if negative
sub a0, a0, t0              # Add 1 if negative
```

### Min/Max without Branching

```asm
# min(a, b)
sub t0, a0, a1              # t0 = a - b
srai t0, t0, 31             # t0 = (a < b) ? -1 : 0
and t0, t0, a0
not t1, t0
and t1, t1, a1
or a0, t0, t1               # a0 = (a < b) ? a : b
```

### Next Power of 2

```asm
# Find next power of 2 >= n
addi a0, a0, -1
srli t0, a0, 1
or a0, a0, t0
srli t0, a0, 2
or a0, a0, t0
srli t0, a0, 4
or a0, a0, t0
srli t0, a0, 8
or a0, a0, t0
srli t0, a0, 16
or a0, a0, t0
addi a0, a0, 1
```

## Common Mistakes

❌ **Using wrong shift for signed numbers**
```asm
li t0, -8
srli t1, t0, 1              # Wrong! Use srai
```

❌ **Forgetting to mask after shift**
```asm
srli t1, t0, 16             # Extract upper half
# Forgot: andi t1, t1, 0xFFFF
```

❌ **Shift amount >= 32**
```asm
slli t1, t0, 35             # Undefined! Use 0-31
```

❌ **Not clearing bits before inserting**
```asm
ori a0, a0, value           # Forgot to clear old bits first
```

❌ **Confusing AND/OR for setting/clearing**
```asm
andi t0, t0, 0b00001000     # Wrong! This clears all but bit 3
# Should use: ori t0, t0, 0b00001000
```

## Key Takeaways

✅ **SLL/SRL/SRA** for shifting left/right (logical/arithmetic)

✅ **AND** for masking and clearing bits

✅ **OR** for setting bits

✅ **XOR** for toggling bits

✅ **Shift left** multiplies by powers of 2

✅ **Shift right** divides by powers of 2

✅ **Use bit operations** for fast modulo and alignment

✅ **Bit fields** save space and enable efficient packing

## Next Lesson

Ready to work with arrays? Continue to:
**[Lesson 10: Arrays and Data Structures →](../10-arrays/)**

Learn about array operations, searching, and sorting!

---

## Quick Reference

**Shifts:**
```asm
slli rd, rs1, imm       # Logical left
srli rd, rs1, imm       # Logical right (unsigned)
srai rd, rs1, imm       # Arithmetic right (signed)
```

**Logical:**
```asm
andi rd, rs1, imm       # AND (mask/clear)
ori  rd, rs1, imm       # OR (set bits)
xori rd, rs1, imm       # XOR (toggle)
xori rd, rs1, -1        # NOT (invert)
```

**Common Patterns:**
```asm
# Test bit N
andi t0, value, (1<<N)

# Set bit N
ori value, value, (1<<N)

# Clear bit N
andi value, value, ~(1<<N)

# Toggle bit N
xori value, value, (1<<N)

# Extract field
srli value, value, start
andi value, value, mask
```

---

*Bit manipulation: the assembly programmer's superpower!* ⚡
