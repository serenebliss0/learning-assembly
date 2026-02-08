# Lesson 07: Advanced Memory Management

Memory is where data lives. Understanding memory layout, alignment, and access patterns is crucial for writing efficient and correct RISC-V programs.

## Learning Objectives

By the end of this lesson, you'll:
- Understand memory alignment requirements
- Master little-endian byte ordering
- Use word, halfword, and byte access instructions
- Handle unaligned memory access
- Work with memory barriers and ordering
- Understand cache considerations
- Avoid common memory-related bugs

## Memory Access Instructions Review

RISC-V provides multiple instructions for different memory access sizes:

**Load Instructions:**
```asm
lb  rd, offset(rs1)     # Load byte (sign-extended)
lbu rd, offset(rs1)     # Load byte unsigned
lh  rd, offset(rs1)     # Load halfword (sign-extended)
lhu rd, offset(rs1)     # Load halfword unsigned
lw  rd, offset(rs1)     # Load word
```

**Store Instructions:**
```asm
sb rs2, offset(rs1)     # Store byte
sh rs2, offset(rs1)     # Store halfword
sw rs2, offset(rs1)     # Store word
```

## Memory Alignment

**Alignment** means data must start at addresses that are multiples of their size:

- **Byte (8-bit):** Can be at any address
- **Halfword (16-bit):** Must be at even addresses (multiple of 2)
- **Word (32-bit):** Must be at addresses divisible by 4

### Why Alignment Matters

1. **Performance:** Aligned access is faster
2. **Atomicity:** Some operations require alignment for atomic access
3. **Hardware:** Some RISC-V implementations raise exceptions on misaligned access

### Checking Alignment

```asm
# Check if address in a0 is word-aligned
andi t0, a0, 0x3        # Mask lower 2 bits
beqz t0, aligned        # If zero, it's aligned
# Not aligned...
aligned:
# Address is word-aligned
```

## Endianness: Little-Endian

RISC-V is **little-endian**: the least significant byte is stored at the lowest address.

Consider the 32-bit value `0x12345678`:

```
Address:  0x1000  0x1001  0x1002  0x1003
Value:      0x78    0x56    0x34    0x12
            LSB                     MSB
```

### Example: Endianness

```asm
.section .data
value:
    .word 0x12345678

.section .text
.globl _start

_start:
    la t0, value
    
    # Load full word
    lw t1, 0(t0)        # t1 = 0x12345678
    
    # Load individual bytes
    lbu t2, 0(t0)       # t2 = 0x78 (LSB)
    lbu t3, 1(t0)       # t3 = 0x56
    lbu t4, 2(t0)       # t4 = 0x34
    lbu t5, 3(t0)       # t5 = 0x12 (MSB)
    
    li a7, 93
    ecall
```

## Word, Halfword, and Byte Access

### Different Access Sizes

```asm
.section .data
data:
    .word 0xAABBCCDD

.section .text
.globl _start

_start:
    la t0, data
    
    # Word access (32-bit)
    lw t1, 0(t0)        # t1 = 0xAABBCCDD
    
    # Halfword access (16-bit)
    lhu t2, 0(t0)       # t2 = 0x0000CCDD (lower halfword)
    lhu t3, 2(t0)       # t3 = 0x0000AABB (upper halfword)
    
    # Byte access (8-bit)
    lbu t4, 0(t0)       # t4 = 0x000000DD
    lbu t5, 1(t0)       # t5 = 0x000000CC
    lbu t6, 2(t0)       # t6 = 0x000000BB
    
    li a7, 93
    ecall
```

### Sign Extension

When loading smaller values, they can be sign-extended:

```asm
.section .data
byte_val:
    .byte 0xFF          # -1 in signed byte
    .byte 0x7F          # 127 in signed byte

.section .text
.globl _start

_start:
    la t0, byte_val
    
    # Sign-extended load
    lb t1, 0(t0)        # t1 = 0xFFFFFFFF (-1)
    lb t2, 1(t0)        # t2 = 0x0000007F (127)
    
    # Unsigned load
    lbu t3, 0(t0)       # t3 = 0x000000FF (255)
    lbu t4, 1(t0)       # t4 = 0x0000007F (127)
    
    li a7, 93
    ecall
```

## The Code - Memory Access Examples

```asm
# memory.s - Demonstrates memory alignment and access patterns

.section .data

# Aligned data
.align 2                        # Align to 4-byte boundary
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

.section .text
.globl _start

_start:
    # Test 1: Aligned word access
    la t0, aligned_word
    lw t1, 0(t0)                # t1 = 0x12345678
    
    # Test 2: Byte-by-byte access of word
    la t0, aligned_word
    lbu t1, 0(t0)               # t1 = 0x78 (LSB)
    lbu t2, 1(t0)               # t2 = 0x56
    lbu t3, 2(t0)               # t3 = 0x34
    lbu t4, 3(t0)               # t4 = 0x12 (MSB)
    
    # Test 3: Reconstruct word from bytes
    slli t2, t2, 8              # t2 = 0x5600
    slli t3, t3, 16             # t3 = 0x340000
    slli t4, t4, 24             # t4 = 0x12000000
    or t1, t1, t2               # t1 = 0x5678
    or t1, t1, t3               # t1 = 0x345678
    or t1, t1, t4               # t1 = 0x12345678
    
    # Test 4: Array access
    la t0, aligned_array
    lw t1, 0(t0)                # t1 = 1
    lw t2, 4(t0)                # t2 = 2
    lw t3, 8(t0)                # t3 = 3
    
    # Test 5: Byte array access
    la t0, byte_array
    lbu t1, 0(t0)               # t1 = 0x11
    lbu t2, 1(t0)               # t2 = 0x22
    lbu t3, 7(t0)               # t3 = 0x88
    
    # Test 6: Mixed data access
    la t0, mixed_data
    lbu t1, 0(t0)               # t1 = 0xAA
    lbu t2, 1(t0)               # t2 = 0xBB
    lhu t3, 2(t0)               # t3 = 0xCCDD
    lw t4, 4(t0)                # t4 = 0x11223344
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
```

## Breaking It Down

### Alignment Directive

```asm
.align 2                    # Align to 2^2 = 4 bytes
```

The `.align N` directive aligns the next data to a 2^N byte boundary:
- `.align 0` - byte alignment (2^0 = 1)
- `.align 1` - halfword alignment (2^1 = 2)
- `.align 2` - word alignment (2^2 = 4)
- `.align 3` - doubleword alignment (2^3 = 8)

### Byte Access Pattern

```asm
lbu t1, 0(t0)               # Load byte at offset 0
lbu t2, 1(t0)               # Load byte at offset 1
lbu t3, 2(t0)               # Load byte at offset 2
lbu t4, 3(t0)               # Load byte at offset 3
```

This loads all four bytes of a word individually. Useful for:
- Processing packed data
- Handling unaligned access
- Byte-oriented protocols

### Reconstructing Values

```asm
slli t2, t2, 8              # Shift byte 1 to position
slli t3, t3, 16             # Shift byte 2 to position
slli t4, t4, 24             # Shift byte 3 to position
or t1, t1, t2               # Combine bytes
or t1, t1, t3
or t1, t1, t4
```

This reconstructs a word from individual bytes. Essential for:
- Handling unaligned data
- Big-endian to little-endian conversion
- Network protocols

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 -o memory.o memory.s

# Link
riscv64-unknown-elf-ld -m elf32lriscv -o memory memory.o

# Run in QEMU
qemu-riscv32 memory

# Or run in Spike
spike --isa=RV32IM /path/to/pk memory
```

## The Code - Alignment Issues

```asm
# alignment.s - Demonstrates alignment issues

.section .data

# Properly aligned data
.align 2
aligned_data:
    .word 0x11111111
    .word 0x22222222
    .word 0x33333333

# Intentionally misaligned (for demonstration)
.align 0                        # Byte alignment
misaligned_start:
    .byte 0xFF                  # Offset by 1 byte
misaligned_word:
    .word 0x44444444            # Now misaligned!

# Buffer for testing
.align 2
buffer:
    .space 16

.section .text
.globl _start

_start:
    # Test 1: Load aligned data (fast, safe)
    la t0, aligned_data
    lw t1, 0(t0)                # Works perfectly
    lw t2, 4(t0)                # Works perfectly
    lw t3, 8(t0)                # Works perfectly
    
    # Test 2: Handle potentially misaligned data
    # Safe method: load byte-by-byte
    la t0, misaligned_word
    lbu t1, 0(t0)
    lbu t2, 1(t0)
    lbu t3, 2(t0)
    lbu t4, 3(t0)
    
    # Reconstruct word
    slli t2, t2, 8
    slli t3, t3, 16
    slli t4, t4, 24
    or t1, t1, t2
    or t1, t1, t3
    or t1, t1, t4               # t1 now has full word value
    
    # Test 3: Align before storing
    la t0, buffer
    # Ensure t0 is word-aligned
    addi t0, t0, 3              # Add 3
    andi t0, t0, ~3             # Clear lower 2 bits (round down to multiple of 4)
    
    # Now safe to store words
    li t1, 0xAAAAAAAA
    sw t1, 0(t0)
    li t2, 0xBBBBBBBB
    sw t2, 4(t0)
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
```

## Breaking It Down - Alignment

### Checking Alignment

```asm
andi t0, t0, ~3             # Clear lower 2 bits
```

This rounds down to the nearest word-aligned address:
- `~3` in binary is `...11111100`
- ANDing with this clears the lower 2 bits
- Result is always a multiple of 4

### Handling Misaligned Access

**Method 1: Byte-by-byte (always safe)**
```asm
lbu t1, 0(t0)               # Load 4 bytes individually
lbu t2, 1(t0)
lbu t3, 2(t0)
lbu t4, 3(t0)
# Then reconstruct
```

**Method 2: Check and align**
```asm
andi t1, t0, 0x3            # Check if aligned
bnez t1, handle_misaligned  # Branch if not aligned
lw t2, 0(t0)                # Safe aligned load
j continue
handle_misaligned:
# Use byte-by-byte method
continue:
```

## Experiments to Try

1. **Endianness Exploration**
   - Store different values and load them byte-by-byte
   - Verify little-endian byte ordering
   - Try: `0x12345678`, `0xDEADBEEF`, `0x01020304`

2. **Alignment Performance**
   - Compare aligned vs unaligned access times
   - Use performance counters if available

3. **Sign Extension**
   - Load signed bytes with negative values
   - Compare `lb` vs `lbu` results
   - Try values: `0xFF`, `0x7F`, `0x80`

4. **Mixed Access**
   - Store a word, load as two halfwords
   - Store four bytes, load as one word
   - Verify correct reconstruction

## Common Memory Patterns

### 1. Copy Memory Block

```asm
# Copy block of memory (word-aligned)
# a0 = source, a1 = dest, a2 = word count
memcpy_words:
    beqz a2, memcpy_done
memcpy_loop:
    lw t0, 0(a0)            # Load word from source
    sw t0, 0(a1)            # Store to destination
    addi a0, a0, 4          # Advance source
    addi a1, a1, 4          # Advance dest
    addi a2, a2, -1         # Decrement count
    bnez a2, memcpy_loop
memcpy_done:
    ret
```

### 2. Zero Memory

```asm
# Zero memory block (word-aligned)
# a0 = address, a1 = word count
memzero:
    beqz a1, memzero_done
    mv t0, zero             # t0 = 0
memzero_loop:
    sw t0, 0(a0)            # Store zero
    addi a0, a0, 4          # Advance pointer
    addi a1, a1, -1         # Decrement count
    bnez a1, memzero_loop
memzero_done:
    ret
```

### 3. Compare Memory

```asm
# Compare two memory blocks (byte-by-byte)
# a0 = ptr1, a1 = ptr2, a2 = count
# Returns: a0 = 0 if equal, non-zero if different
memcmp:
    beqz a2, memcmp_equal
memcmp_loop:
    lbu t0, 0(a0)           # Load byte from ptr1
    lbu t1, 0(a1)           # Load byte from ptr2
    bne t0, t1, memcmp_diff # Different?
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    bnez a2, memcmp_loop
memcmp_equal:
    li a0, 0                # Return 0 (equal)
    ret
memcmp_diff:
    sub a0, t0, t1          # Return difference
    ret
```

## Memory Barriers and Ordering

In multi-core or I/O scenarios, memory ordering matters:

```asm
fence                       # Full memory barrier
fence.i                     # Instruction fence (sync I-cache)
fence r, w                  # Read-before-write barrier
fence w, r                  # Write-before-read barrier
fence rw, rw                # Full sequential consistency
```

### When to Use Fences

**fence**: Use when:
- Synchronizing with other cores
- Ensuring stores are visible before loads
- Working with memory-mapped I/O

**fence.i**: Use when:
- Modifying code (self-modifying programs)
- Loading new code into memory
- Invalidating instruction cache

Example with memory-mapped I/O:
```asm
# Write to device register
la t0, device_addr
li t1, CMD_START
sw t1, 0(t0)
fence w, r                  # Ensure write completes before reading
lw t2, 4(t0)                # Read status
```

## Cache Considerations

Modern processors have cache hierarchies (L1, L2, L3). Understanding cache behavior helps optimize performance:

### Cache Lines

Data is loaded in cache lines (typically 64 bytes). Accessing data in the same cache line is faster.

```asm
# Good: Sequential access (cache-friendly)
la t0, array
li t1, 0
li t2, 100
loop:
    lw t3, 0(t0)            # Access sequential elements
    # Process t3...
    addi t0, t0, 4          # Next element
    addi t1, t1, 1
    blt t1, t2, loop

# Bad: Random access (cache-unfriendly)
# Jumping around memory causes cache misses
```

### False Sharing

In multi-core systems, different cores modifying nearby data can cause cache conflicts:

```asm
# Bad: Variables on same cache line
.align 2
counter1:
    .word 0                 # Core 1 modifies this
counter2:
    .word 0                 # Core 2 modifies this (same cache line!)

# Good: Pad to separate cache lines
.align 6                    # Align to 64-byte cache line
counter1:
    .word 0
    .space 60               # Padding
counter2:
    .word 0
    .space 60               # Padding
```

## Exercises

**Exercise 1:** Write a function to reverse the byte order of a word (convert endianness).

**Exercise 2:** Implement a function to load a potentially misaligned word safely.

**Exercise 3:** Write a function to copy bytes from source to destination (like C's memcpy).

**Exercise 4:** Create a function to find the first misaligned word in an array.

<details>
<summary>Solution to Exercise 1</summary>

```asm
# Reverse byte order of word
# Input: a0 = word
# Output: a0 = reversed word

reverse_bytes:
    # Extract bytes
    andi t0, a0, 0xFF       # Byte 0
    srli t1, a0, 8
    andi t1, t1, 0xFF       # Byte 1
    srli t2, a0, 16
    andi t2, t2, 0xFF       # Byte 2
    srli t3, a0, 24         # Byte 3
    
    # Reassemble in reverse order
    slli t3, t3, 0          # Byte 3 -> position 0
    slli t2, t2, 8          # Byte 2 -> position 1
    slli t1, t1, 16         # Byte 1 -> position 2
    slli t0, t0, 24         # Byte 0 -> position 3
    
    or a0, t3, t2
    or a0, a0, t1
    or a0, a0, t0
    ret

_start:
    li a0, 0x12345678
    call reverse_bytes
    # a0 = 0x78563412
    
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 2</summary>

```asm
# Load potentially misaligned word
# Input: a0 = address
# Output: a0 = word value

load_unaligned:
    # Check alignment
    andi t0, a0, 0x3
    beqz t0, load_aligned   # If aligned, use fast path
    
    # Unaligned: load byte-by-byte
    lbu t0, 0(a0)
    lbu t1, 1(a0)
    lbu t2, 2(a0)
    lbu t3, 3(a0)
    
    # Reconstruct word
    slli t1, t1, 8
    slli t2, t2, 16
    slli t3, t3, 24
    or a0, t0, t1
    or a0, a0, t2
    or a0, a0, t3
    ret

load_aligned:
    lw a0, 0(a0)            # Fast aligned load
    ret
```
</details>

<details>
<summary>Solution to Exercise 3</summary>

```asm
# Copy bytes from source to destination
# Input: a0 = src, a1 = dst, a2 = count
# Output: none (modifies memory)

bytecopy:
    beqz a2, bytecopy_done
bytecopy_loop:
    lbu t0, 0(a0)           # Load byte from source
    sb t0, 0(a1)            # Store to destination
    addi a0, a0, 1          # Advance source
    addi a1, a1, 1          # Advance dest
    addi a2, a2, -1         # Decrement count
    bnez a2, bytecopy_loop
bytecopy_done:
    ret

_start:
    # Test: copy 10 bytes
    la a0, source_data
    la a1, dest_buffer
    li a2, 10
    call bytecopy
    
    li a7, 93
    ecall

.section .data
source_data:
    .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
dest_buffer:
    .space 10
```
</details>

## Deep Dive: Memory Hierarchy

Modern computers have a memory hierarchy:

```
Registers (fastest, smallest)
    ↓
L1 Cache (~32 KB, ~1-4 cycles)
    ↓
L2 Cache (~256 KB, ~10-20 cycles)
    ↓
L3 Cache (~8 MB, ~40-50 cycles)
    ↓
RAM (~GB, ~100-300 cycles)
    ↓
Disk (slowest, largest)
```

### Optimizing for Cache

1. **Spatial Locality:** Access nearby memory
2. **Temporal Locality:** Reuse recently accessed data
3. **Sequential Access:** Better than random
4. **Alignment:** Reduces cache line splits

## Common Mistakes

❌ **Assuming alignment without checking**
```asm
lw t0, 0(a0)                # May fault if a0 is misaligned
```

❌ **Forgetting sign extension**
```asm
lb t0, 0(a0)                # Sign-extends (0xFF -> 0xFFFFFFFF)
# Should use lbu for unsigned
```

❌ **Mixing access sizes without care**
```asm
sw t0, 0(a0)
lh t1, 0(a0)                # Only gets lower half!
```

❌ **Ignoring endianness**
```asm
# Assuming byte order matches multi-byte integers
```

❌ **Not aligning data properly**
```asm
.section .data
label:
    .byte 0xFF
    .word 0x12345678        # Misaligned!
```

## Key Takeaways

✅ **RISC-V is little-endian** (LSB at lowest address)

✅ **Alignment matters** for performance and correctness

✅ **Use byte access** for unaligned data

✅ **Sign extension** happens with `lb` and `lh`

✅ **Cache-friendly access** improves performance

✅ **Memory barriers** ensure ordering in concurrent code

✅ **Always align** data structures properly

## Next Lesson

Ready to master the stack? Continue to:
**[Lesson 08: Stack Operations →](../08-stack/)**

Learn about stack management, local variables, and stack frames!

---

## Quick Reference

**Load Instructions:**
```asm
lb/lbu  rd, off(rs1)    # Load byte (signed/unsigned)
lh/lhu  rd, off(rs1)    # Load halfword
lw      rd, off(rs1)    # Load word
```

**Store Instructions:**
```asm
sb  rs2, off(rs1)       # Store byte
sh  rs2, off(rs1)       # Store halfword
sw  rs2, off(rs1)       # Store word
```

**Alignment:**
```asm
.align N                # Align to 2^N bytes
andi t0, addr, ~3       # Round down to word boundary
```

**Check Alignment:**
```asm
andi t0, addr, 0x3      # Check word alignment
beqz t0, is_aligned     # Zero = aligned
```

**Memory Barriers:**
```asm
fence                   # Full barrier
fence.i                 # Instruction fence
```

---

*Memory mastery leads to efficient programs!* 💾
