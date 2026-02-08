# Lesson 03: Addressing and Memory Access - Working with Memory

RISC-V is a load-store architecture: arithmetic happens in registers, and separate instructions load/store from memory. This lesson teaches you how to access memory efficiently.

## Learning Objectives

By the end of this lesson, you'll:
- Understand RISC-V's load-store architecture
- Master load instructions (LB, LH, LW, LBU, LHU)
- Master store instructions (SB, SH, SW)
- Work with different data sizes (byte, half, word)
- Understand address calculation and offsets
- Learn about memory alignment
- Use labels and symbolic addresses

## Load-Store Architecture

**Key Principle:** Arithmetic operations work ONLY on registers.

```asm
# You CANNOT do this:
add $0200, $0201, $0202    # Invalid! (not real syntax)

# Instead, you MUST:
lw t0, 0x200(x0)          # Load from memory to register
lw t1, 0x201(x0)          # Load from memory to register
add t2, t0, t1             # Add in registers
sw t2, 0x202(x0)          # Store back to memory
```

**Why?**
- Simpler CPU design
- Faster execution
- Easier pipelining
- Explicit about memory accesses

## Memory Access Instructions

### Load Instructions

```asm
lb  rd, offset(rs1)        # Load byte (signed)
lh  rd, offset(rs1)        # Load halfword (signed)
lw  rd, offset(rs1)        # Load word
lbu rd, offset(rs1)        # Load byte (unsigned)
lhu rd, offset(rs1)        # Load halfword (unsigned)
```

**Syntax:** `load dest_register, offset(base_register)`

### Store Instructions

```asm
sb rs2, offset(rs1)        # Store byte
sh rs2, offset(rs1)        # Store halfword
sw rs2, offset(rs1)        # Store word
```

**Syntax:** `store source_register, offset(base_register)`

## The Code

Create a file called `memory.s`:

```asm
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
    # If byte is 0x42, t1 = 0x00000042
    # If byte is 0x80, t1 = 0xFFFFFF80 (sign-extended!)
    
    # Load byte (unsigned)
    lbu t2, 0(t0)              # t2 = unsigned byte
    # If byte is 0x80, t2 = 0x00000080 (zero-extended)
    
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
    
    # === String Access ===
    
    la t0, string_data         # t0 = address of string
    lb t1, 0(t0)               # t1 = 'H' (0x48)
    lb t2, 1(t0)               # t2 = 'e' (0x65)
    lb t3, 2(t0)               # t3 = 'l' (0x6C)
    
    # === Memory Copy ===
    # Copy 4 words from array to buffer
    
    la t0, array               # Source
    la t1, buffer + 20         # Destination
    
    lw t2, 0(t0)               # Load array[0]
    sw t2, 0(t1)               # Store to buffer[0]
    
    lw t2, 4(t0)               # Load array[1]
    sw t2, 4(t1)               # Store to buffer[1]
    
    lw t2, 8(t0)               # Load array[2]
    sw t2, 8(t1)               # Store to buffer[2]
    
    lw t2, 12(t0)              # Load array[3]
    sw t2, 12(t1)              # Store to buffer[3]
    
    # === Pointer Arithmetic ===
    
    la t0, array               # t0 = pointer to array
    lw t1, 0(t0)               # t1 = *t0 (dereference)
    
    addi t0, t0, 4             # t0++ (move to next word)
    lw t2, 0(t0)               # t2 = *t0
    
    addi t0, t0, 4             # t0++
    lw t3, 0(t0)               # t3 = *t0
    
    # === Byte Order (Endianness) ===
    # RISC-V is little-endian by default
    
    li t0, 0x12345678
    la t1, buffer + 50
    sw t0, 0(t1)               # Store word
    
    # Memory layout (little-endian):
    # buffer+50: 0x78
    # buffer+51: 0x56
    # buffer+52: 0x34
    # buffer+53: 0x12
    
    lb t2, 0(t1)               # t2 = 0x78 (LSB first)
    lb t3, 3(t1)               # t3 = 0x12 (MSB last)
    
    # === Address Calculation Examples ===
    
    # Example 1: Access 2D array element [i][j]
    # int matrix[4][5]; access matrix[2][3]
    # Address = base + (i * columns + j) * element_size
    
    li t0, 2                   # i = 2
    li t1, 5                   # columns = 5
    li t2, 3                   # j = 3
    
    mul t3, t0, t1             # t3 = i * columns (needs M extension)
    add t3, t3, t2             # t3 = i * columns + j
    slli t3, t3, 2             # t3 *= 4 (word size)
    # t3 now contains offset from base
    
    # Example 2: Struct field access
    # struct { int x; short y; char z; }
    # x at offset 0, y at offset 4, z at offset 6
    
    la t0, buffer              # t0 = pointer to struct
    lw t1, 0(t0)               # t1 = struct.x
    lh t2, 4(t0)               # t2 = struct.y
    lb t3, 6(t0)               # t3 = struct.z
    
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
```

## Breaking It Down

### Load Instructions in Detail

**Load Byte (LB):**
```asm
lb rd, offset(rs1)
# Loads 8 bits from memory
# Sign-extends to 32 bits
# Address = rs1 + offset
```

Example:
```asm
la t0, byte_val            # t0 = 0x1000
lb t1, 0(t0)               # Load from 0x1000
```

If memory contains `0x80`:
- `lb t1, 0(t0)` → t1 = `0xFFFFFF80` (sign-extended)
- `lbu t1, 0(t0)` → t1 = `0x00000080` (zero-extended)

**Load Halfword (LH):**
```asm
lh rd, offset(rs1)
# Loads 16 bits
# Sign-extends to 32 bits
```

**Load Word (LW):**
```asm
lw rd, offset(rs1)
# Loads full 32 bits
```

### Store Instructions in Detail

**Store Byte (SB):**
```asm
sb rs2, offset(rs1)
# Stores lower 8 bits of rs2
# Address = rs1 + offset
```

**Store Halfword (SH):**
```asm
sh rs2, offset(rs1)
# Stores lower 16 bits of rs2
```

**Store Word (SW):**
```asm
sw rs2, offset(rs1)
# Stores full 32 bits of rs2
```

### Address Calculation

All loads/stores use: **address = base_register + offset**

```asm
lw t1, 12(t0)              # Load from address (t0 + 12)
```

**Offset range:** -2048 to +2047 (12-bit signed)

For larger offsets:
```asm
# Wrong: offset too large
lw t1, 5000(t0)            # Error!

# Correct: add to base first
li t2, 5000
add t2, t0, t2
lw t1, 0(t2)               # Load from t0 + 5000
```

### Array Access Patterns

**Fixed Index:**
```asm
la t0, array
lw t1, 0(t0)               # array[0]
lw t2, 4(t0)               # array[1]
lw t3, 8(t0)               # array[2]
```

**Variable Index:**
```asm
# array[i] where i is in t1
la t0, array               # Base address
slli t2, t1, 2             # i * 4 (word size)
add t2, t0, t2             # Base + offset
lw t3, 0(t2)               # Load array[i]
```

**Pointer Increment:**
```asm
la t0, array               # t0 = &array[0]
lw t1, 0(t0)               # *t0
addi t0, t0, 4             # t0++ (next word)
lw t2, 0(t0)               # *t0
```

## Memory Alignment

RISC-V requires aligned access:

| Type | Size | Must be aligned to |
|------|------|-------------------|
| Byte (LB/SB) | 1 byte | Any address |
| Halfword (LH/SH) | 2 bytes | 2-byte boundary |
| Word (LW/SW) | 4 bytes | 4-byte boundary |

**Examples:**
```asm
# Aligned (OK)
lw t0, 0(t1)               # Address is multiple of 4
lw t0, 4(t1)               # OK
lw t0, 8(t1)               # OK

# Misaligned (ERROR!)
lw t0, 1(t1)               # Not aligned to 4!
lw t0, 2(t1)               # Not aligned to 4!
lh t0, 1(t1)               # Not aligned to 2!

# Bytes can be unaligned (OK)
lb t0, 1(t1)               # OK for bytes
```

**Why alignment matters:**
- Hardware requirement
- Better performance
- Misaligned access may trap (exception)

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 memory.s -o memory.o

# Link
riscv64-unknown-elf-ld memory.o -o memory

# Run
qemu-riscv32 ./memory
```

## Experiments

### Experiment 1: Sign Extension

```asm
li t0, 0x80                # Negative byte (-128)
la t1, buffer
sb t0, 0(t1)               # Store byte
lb t2, 0(t1)               # Load signed
lbu t3, 0(t1)              # Load unsigned
```

**Question:** What are t2 and t3?

### Experiment 2: Partial Stores

```asm
li t0, 0x12345678
la t1, buffer
sw t0, 0(t1)               # Store full word
sh t0, 4(t1)               # Store only 0x5678
sb t0, 8(t1)               # Store only 0x78
```

**Question:** What's in memory at buffer+0, buffer+4, buffer+8?

### Experiment 3: Little-Endian

```asm
li t0, 0x12345678
la t1, buffer
sw t0, 0(t1)
lb t2, 0(t1)               # First byte
lb t3, 1(t1)               # Second byte
lb t4, 2(t1)               # Third byte
lb t5, 3(t1)               # Fourth byte
```

**Question:** What are t2, t3, t4, t5?

## Exercises

**Exercise 1:** Write code to reverse the bytes in a word. For example, 0x12345678 becomes 0x78563412.

**Exercise 2:** Write code to sum all elements in the `array` defined in the data section.

**Exercise 3:** Write code to copy a null-terminated string from one location to another.

**Exercise 4:** Write code to find the maximum value in an array of 10 signed integers.

<details>
<summary>Solution to Exercise 1: Reverse bytes</summary>

```asm
# Reverse bytes in t0, result in t1
li t0, 0x12345678

# Extract each byte
andi t2, t0, 0xFF          # Byte 0: 0x78
srli t3, t0, 8
andi t3, t3, 0xFF          # Byte 1: 0x56
srli t4, t0, 16
andi t4, t4, 0xFF          # Byte 2: 0x34
srli t5, t0, 24            # Byte 3: 0x12

# Reassemble in reverse order
slli t1, t2, 24            # 0x78 << 24
slli t6, t3, 16            # 0x56 << 16
or t1, t1, t6
slli t6, t4, 8             # 0x34 << 8
or t1, t1, t6
or t1, t1, t5              # 0x12

# t1 = 0x78563412
```
</details>

<details>
<summary>Solution to Exercise 2: Sum array</summary>

```asm
# Sum all elements in array
la t0, array               # Base address
li t1, 0                   # Sum = 0
li t2, 5                   # Count = 5

loop:
    lw t3, 0(t0)           # Load element
    add t1, t1, t3         # Add to sum
    addi t0, t0, 4         # Next element
    addi t2, t2, -1        # Decrement count
    bnez t2, loop          # Loop if count != 0

# t1 contains sum (10+20+30+40+50 = 150)
```
</details>

## Deep Dive: Load-Store Architecture vs CISC

**RISC-V (Load-Store):**
```asm
lw t0, 0(t1)               # Load
lw t2, 0(t3)               # Load
add t0, t0, t2             # Add
sw t0, 0(t1)               # Store
```

**x86 (CISC):**
```asm
mov eax, [ebx]             # Load
add eax, [ecx]             # Load AND add
mov [ebx], eax             # Store
```

**Trade-offs:**

RISC-V:
✅ Simpler hardware
✅ Easier pipelining
✅ Regular instruction timing
❌ More instructions
❌ More registers needed

CISC:
✅ Fewer instructions
✅ More compact code
❌ Complex hardware
❌ Variable timing

## Deep Dive: Memory Hierarchy

```
Registers:  ~1 cycle    (fastest, smallest)
L1 Cache:   ~4 cycles
L2 Cache:   ~10 cycles
L3 Cache:   ~40 cycles
RAM:        ~100 cycles (slowest, largest)
```

**Lesson:** Keep frequently used data in registers!

## Deep Dive: Pseudo-Instructions for Memory

```asm
la rd, symbol              # Load address
# Expands to: auipc + addi

li rd, immediate           # Load immediate
# Expands to: lui + addi (for large constants)

l{b|h|w} rd, symbol        # Load from symbol
# Expands to: la + load

s{b|h|w} rs, symbol, rt    # Store to symbol
# Expands to: la + store (using rt as temp)
```

## Common Mistakes

### Mistake 1: Wrong Load Size

```asm
la t0, byte_val            # Address of byte
lw t1, 0(t0)               # Loading word from byte address!
```

**Problem:** May load garbage or cause misalignment trap.

**Fix:** Use correct size:
```asm
lb t1, 0(t0)               # Load byte
```

### Mistake 2: Forgetting Alignment

```asm
la t0, buffer
lw t1, 1(t0)               # Misaligned! (not multiple of 4)
```

**Fix:** Use aligned offsets:
```asm
lw t1, 0(t0)               # Or 4, 8, 12, etc.
```

### Mistake 3: Offset Out of Range

```asm
lw t1, 5000(t0)            # Offset too large!
```

**Fix:** Calculate address first:
```asm
li t2, 5000
add t2, t0, t2
lw t1, 0(t2)
```

### Mistake 4: Sign Extension Surprise

```asm
lb t0, address             # Load 0xFF
# t0 = 0xFFFFFFFF (not 0xFF!)
```

**Fix:** Use unsigned load if needed:
```asm
lbu t0, address            # t0 = 0x000000FF
```

## Key Takeaways

✅ RISC-V is **load-store architecture** - memory access is explicit

✅ Different **sizes**: byte (8-bit), halfword (16-bit), word (32-bit)

✅ **Sign extension** vs zero extension matters

✅ Memory must be **aligned** (word at 4-byte boundary)

✅ Address = **base + offset** (offset is -2048 to +2047)

✅ Array access: **multiply index by element size**

✅ RISC-V is **little-endian** by default

## Next Lesson

Ready for more? Continue to:
**[Lesson 04: Arithmetic Operations →](../04-arithmetic/)**

You'll learn how to perform math operations in RISC-V!

---

## Quick Reference

**Load Instructions:**
```asm
lb  rd, offset(rs1)        # Load byte (signed)
lh  rd, offset(rs1)        # Load halfword (signed)
lw  rd, offset(rs1)        # Load word
lbu rd, offset(rs1)        # Load byte (unsigned)
lhu rd, offset(rs1)        # Load halfword (unsigned)
```

**Store Instructions:**
```asm
sb rs2, offset(rs1)        # Store byte
sh rs2, offset(rs1)        # Store halfword
sw rs2, offset(rs1)        # Store word
```

**Address Calculation:**
```
address = base_register + offset
offset range: -2048 to +2047
```

**Alignment:**
```
Byte: any address
Halfword: 2-byte boundary (address % 2 == 0)
Word: 4-byte boundary (address % 4 == 0)
```

---

*You've mastered memory access! Next: arithmetic!* 🎉
