# Lesson 02: Registers and Data Types - RISC-V's Building Blocks

Now that you've written your first program, let's dive deep into RISC-V's register architecture. Understanding registers is fundamental to writing efficient assembly code.

## Learning Objectives

By the end of this lesson, you'll:
- Understand the RISC-V register set (all 32 registers)
- Know the naming conventions and ABI names
- Master register-to-register operations
- Understand data types and sizes in RISC-V
- Learn about special-purpose registers
- Work with immediate values effectively

## The RISC-V Register Set

RISC-V has **32 general-purpose integer registers**, each 32 bits wide (in RV32I):

| Register | ABI Name | Description | Preserved? |
|----------|----------|-------------|------------|
| x0 | zero | Hardwired to 0 | N/A |
| x1 | ra | Return address | No |
| x2 | sp | Stack pointer | Yes |
| x3 | gp | Global pointer | N/A |
| x4 | tp | Thread pointer | N/A |
| x5-x7 | t0-t2 | Temporary registers | No |
| x8 | s0/fp | Saved register / Frame pointer | Yes |
| x9 | s1 | Saved register | Yes |
| x10-x11 | a0-a1 | Function arguments / Return values | No |
| x12-x17 | a2-a7 | Function arguments | No |
| x18-x27 | s2-s11 | Saved registers | Yes |
| x28-x31 | t3-t6 | Temporary registers | No |

**Key Points:**
- **x0 (zero)**: Always reads as 0, writes are ignored
- **Caller-saved (t0-t6, a0-a7)**: Caller must save if needed
- **Callee-saved (s0-s11, sp)**: Callee must preserve

## The Code

Create a file called `registers.s`:

```asm
# registers.s - Exploring RISC-V registers
# This program demonstrates register operations

.section .data
result_msg:
    .string "Register operations complete!\n"

.section .text
.globl _start

_start:
    # === Zero Register ===
    # x0 always reads as 0
    addi x5, x0, 100       # x5 = 0 + 100 = 100
    add x6, x0, x0         # x6 = 0 + 0 = 0
    
    # Writing to x0 does nothing
    addi x0, x5, 50        # x0 is still 0!
    
    # === Using Temporary Registers ===
    # t0-t6 are for temporary values
    li t0, 42              # t0 = 42
    li t1, 58              # t1 = 58
    add t2, t0, t1         # t2 = 42 + 58 = 100
    
    # === Register Arithmetic ===
    li a0, 10              # a0 = 10
    li a1, 20              # a1 = 20
    add a2, a0, a1         # a2 = 10 + 20 = 30
    sub a3, a1, a0         # a3 = 20 - 10 = 10
    
    # === Bitwise Operations ===
    li t0, 0b11110000      # t0 = 0xF0 (240)
    li t1, 0b00111100      # t1 = 0x3C (60)
    
    and t2, t0, t1         # t2 = 0xF0 & 0x3C = 0x30
    or  t3, t0, t1         # t3 = 0xF0 | 0x3C = 0xFC
    xor t4, t0, t1         # t4 = 0xF0 ^ 0x3C = 0xCC
    
    # === Shift Operations ===
    li t0, 8               # t0 = 8 (binary: 1000)
    slli t1, t0, 2         # t1 = 8 << 2 = 32 (shift left logical)
    srli t2, t0, 1         # t2 = 8 >> 1 = 4 (shift right logical)
    
    li t0, -8              # t0 = -8 (0xFFFFFFF8)
    srai t3, t0, 1         # t3 = -8 >> 1 = -4 (arithmetic shift)
    
    # === Comparison and Set Operations ===
    li t0, 10
    li t1, 20
    
    slt t2, t0, t1         # t2 = (10 < 20) = 1 (true)
    slt t3, t1, t0         # t3 = (20 < 10) = 0 (false)
    
    sltu t4, t0, t1        # Unsigned comparison
    
    # === Immediate Operations ===
    # Most instructions have immediate variants
    li t0, 100
    addi t1, t0, 50        # t1 = 100 + 50 = 150
    andi t2, t0, 0xFF      # t2 = 100 & 255 = 100
    ori t3, t0, 0x0F       # t3 = 100 | 15 = 111
    xori t4, t0, 0xFF      # t4 = 100 ^ 255 = 155
    slti t5, t0, 150       # t5 = (100 < 150) = 1
    
    # === Loading Upper Immediate ===
    # LUI loads 20-bit immediate into upper 20 bits
    lui t0, 0x12345        # t0 = 0x12345000
    
    # AUIPC adds upper immediate to PC
    auipc t1, 0            # t1 = current PC value
    
    # === Pseudo-Instructions ===
    # These expand to multiple instructions
    
    # li (load immediate) - expands to lui + addi
    li t0, 0x12345678      # Load large constant
    
    # mv (move) - expands to addi rd, rs, 0
    li t0, 42
    mv t1, t0              # t1 = t0 (really: addi t1, t0, 0)
    
    # not - expands to xori rd, rs, -1
    li t0, 0b10101010
    not t1, t0             # t1 = ~t0 (bitwise NOT)
    
    # neg - expands to sub rd, x0, rs
    li t0, 42
    neg t1, t0             # t1 = -t0 (really: sub t1, x0, t0)
    
    # === Register Usage Best Practices ===
    # Use saved registers (s0-s11) for values that must survive function calls
    li s0, 100             # Saved across function calls
    li s1, 200
    
    # Use temporary registers (t0-t6) for scratch calculations
    li t0, 10              # Not preserved across calls
    li t1, 20
    
    # Use argument registers (a0-a7) for function parameters
    li a0, 42              # First argument
    li a1, 58              # Second argument
    
    # Print success message
    li a0, 1               # stdout
    la a1, result_msg      # message address
    li a2, 31              # message length
    li a7, 64              # write syscall
    ecall
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
```

## Breaking It Down

### The Zero Register (x0)

The most unique feature of RISC-V:

```asm
li t0, 100
add t1, x0, t0         # t1 = 0 + t0 = t0 (copy)
add x0, t0, t1         # Does nothing! x0 is always 0
```

Uses:
- Discard results: `add x0, t0, t1` (just sets flags)
- Source of zero: `addi t0, x0, 10` (load 10)
- Clear register: Not needed! Just read from x0

### Register Arithmetic

All arithmetic happens in registers:

```asm
add  rd, rs1, rs2      # rd = rs1 + rs2
sub  rd, rs1, rs2      # rd = rs1 - rs2
and  rd, rs1, rs2      # rd = rs1 & rs2
or   rd, rs1, rs2      # rd = rs1 | rs2
xor  rd, rs1, rs2      # rd = rs1 ^ rs2
sll  rd, rs1, rs2      # rd = rs1 << rs2
srl  rd, rs1, rs2      # rd = rs1 >> rs2 (logical)
sra  rd, rs1, rs2      # rd = rs1 >> rs2 (arithmetic)
slt  rd, rs1, rs2      # rd = (rs1 < rs2) ? 1 : 0
sltu rd, rs1, rs2      # Unsigned comparison
```

### Immediate Operations

Add "i" suffix for immediate operands:

```asm
addi  rd, rs1, imm     # rd = rs1 + imm
andi  rd, rs1, imm     # rd = rs1 & imm
ori   rd, rs1, imm     # rd = rs1 | imm
xori  rd, rs1, imm     # rd = rs1 ^ imm
slli  rd, rs1, imm     # rd = rs1 << imm
srli  rd, rs1, imm     # rd = rs1 >> imm (logical)
srai  rd, rs1, imm     # rd = rs1 >> imm (arithmetic)
slti  rd, rs1, imm     # rd = (rs1 < imm) ? 1 : 0
sltiu rd, rs1, imm     # Unsigned comparison
```

**Immediate range:** -2048 to 2047 (12-bit signed)

### Data Types and Sizes

| Type | Size | Range (signed) | Range (unsigned) |
|------|------|----------------|------------------|
| Byte | 8 bits | -128 to 127 | 0 to 255 |
| Half | 16 bits | -32768 to 32767 | 0 to 65535 |
| Word | 32 bits | -2³¹ to 2³¹-1 | 0 to 2³²-1 |

RISC-V instructions work on **words** (32 bits) by default.

### Shift Operations

Three types:

```asm
slli t0, t1, 2         # Logical left: multiply by 4
srli t0, t1, 2         # Logical right: divide by 4 (unsigned)
srai t0, t1, 2         # Arithmetic right: divide by 4 (signed)
```

**Logical vs Arithmetic:**
- Logical: Fills with 0s
- Arithmetic: Preserves sign bit

Example:
```asm
li t0, -8              # 0xFFFFFFF8
srli t1, t0, 1         # 0x7FFFFFFC (logical)
srai t2, t0, 1         # 0xFFFFFFFC (arithmetic)
```

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 registers.s -o registers.o

# Link
riscv64-unknown-elf-ld registers.o -o registers

# Run
qemu-riscv32 ./registers
```

## Experiments

### Experiment 1: Test Zero Register

Try to modify x0:
```asm
li t0, 100
add x0, t0, t0         # Try to set x0 to 200
add t1, x0, x0         # What's in t1?
```

**Question:** What value is in t1?

### Experiment 2: Overflow

What happens with overflow?
```asm
li t0, 2147483647      # Maximum signed 32-bit int
addi t1, t0, 1         # Add 1
```

**Question:** What's the value in t1? (Hint: it wraps around!)

### Experiment 3: Shift Math

Use shifts for multiplication:
```asm
li t0, 5
slli t1, t0, 3         # Multiply by 8
```

**Question:** What's faster, shift or multiply? (In RV32I, there's no multiply!)

### Experiment 4: Set If Less Than

Compare numbers:
```asm
li t0, -1              # -1 (signed)
li t1, 1               # 1
slt t2, t0, t1         # Signed compare
sltu t3, t0, t1        # Unsigned compare
```

**Question:** What are t2 and t3? Why are they different?

## Exercises

**Exercise 1:** Write code that swaps the values in two registers without using a third register. (Hint: use XOR)

**Exercise 2:** Write code that computes the absolute value of a signed number in t0 and stores it in t1.

**Exercise 3:** Write code that counts the number of set bits (1s) in a register. (Hint: use shifts and AND)

**Exercise 4:** Implement a function that checks if a number is a power of 2.

<details>
<summary>Solution to Exercise 1: Swap without temp</summary>

```asm
# Swap t0 and t1 using XOR
li t0, 42
li t1, 17

xor t0, t0, t1         # t0 = t0 ^ t1
xor t1, t0, t1         # t1 = (t0 ^ t1) ^ t1 = t0
xor t0, t0, t1         # t0 = (t0 ^ t1) ^ t0 = t1

# Now t0 and t1 are swapped!
```
</details>

<details>
<summary>Solution to Exercise 2: Absolute value</summary>

```asm
# Absolute value of t0 -> t1
li t0, -42             # Test with negative

# Method 1: Using branches (we'll learn this in lesson 5)
# For now, here's a branch-free version:

srai t1, t0, 31        # t1 = sign bit extended (all 1s if negative)
xor t1, t0, t1         # Flip bits if negative
sub t1, t1, t1         # Subtract the sign mask
# Actually, simpler version:
srai t2, t0, 31        # t2 = -1 if negative, 0 if positive
xor t1, t0, t2         # Conditionally flip bits
sub t1, t1, t2         # Conditionally add 1
```
</details>

## Deep Dive: Register Calling Convention

When calling functions, RISC-V has a **calling convention**:

**Caller-saved (temporary):**
- t0-t6, a0-a7
- Caller must save before calling if needed

**Callee-saved:**
- s0-s11, sp
- Callee must preserve and restore

**Why does this matter?**
- Saves stack space (fewer saves/restores)
- Enables better compiler optimizations
- Makes debugging easier (consistent state)

Example:
```asm
my_function:
    # Must save s0 if we use it
    addi sp, sp, -4
    sw s0, 0(sp)
    
    # Use s0 safely
    li s0, 42
    
    # Restore s0 before returning
    lw s0, 0(sp)
    addi sp, sp, 4
    ret
```

## Deep Dive: Why 32 Registers?

RISC-V chose 32 registers as a sweet spot:

**More registers:**
✅ Fewer memory accesses
✅ Better performance
❌ Longer instruction encoding
❌ More context to save on interrupts

**Fewer registers:**
✅ Shorter instructions
✅ Faster context switches
❌ More memory accesses
❌ Lower performance

32 registers fits in 5 bits (2⁵ = 32), allowing efficient 32-bit instruction encoding!

## Deep Dive: Pseudo-Instructions

The assembler provides convenient pseudo-instructions:

| Pseudo | Real | Notes |
|--------|------|-------|
| `li rd, imm` | `lui` + `addi` | Load any 32-bit constant |
| `la rd, symbol` | `auipc` + `addi` | Load address |
| `mv rd, rs` | `addi rd, rs, 0` | Copy register |
| `not rd, rs` | `xori rd, rs, -1` | Bitwise NOT |
| `neg rd, rs` | `sub rd, x0, rs` | Negate |
| `nop` | `addi x0, x0, 0` | No operation |
| `ret` | `jalr x0, ra, 0` | Return from function |
| `j offset` | `jal x0, offset` | Jump |

These make code more readable while expanding to efficient instructions!

## Common Mistakes

### Mistake 1: Forgetting Zero Register

```asm
addi x0, t0, 10        # Does nothing! x0 can't be changed
```

**Fix:** Use a different register:
```asm
addi t1, t0, 10        # Correct
```

### Mistake 2: Immediate Out of Range

```asm
addi t0, x0, 5000      # Error! 5000 > 2047
```

**Fix:** Use `li` pseudo-instruction:
```asm
li t0, 5000            # Expands to lui + addi
```

### Mistake 3: Wrong Shift Type

```asm
li t0, -8
srli t1, t0, 1         # Logical shift (wrong for signed!)
```

**Fix:** Use arithmetic shift for signed:
```asm
srai t1, t0, 1         # Preserves sign
```

### Mistake 4: Confusing Signed vs Unsigned

```asm
li t0, -1              # 0xFFFFFFFF
li t1, 1
sltu t2, t0, t1        # Unsigned: t2 = 0 (4294967295 > 1)
slt t3, t0, t1         # Signed: t3 = 1 (-1 < 1)
```

## Key Takeaways

✅ RISC-V has **32 general-purpose registers** (x0-x31)

✅ **x0 is always zero** - most unique feature

✅ Use **ABI names** (a0, t0, s0) for readability

✅ **Immediate operations** are common and efficient

✅ **Calling convention** defines register usage

✅ **Pseudo-instructions** make code clearer

✅ All operations are **32-bit** (in RV32I)

## Next Lesson

Ready for more? Continue to:
**[Lesson 03: Addressing and Memory Access →](../03-addressing/)**

You'll learn how to load and store data from memory!

---

## Quick Reference

**Arithmetic:**
```asm
add  rd, rs1, rs2      # Addition
sub  rd, rs1, rs2      # Subtraction
addi rd, rs1, imm      # Add immediate
```

**Logical:**
```asm
and  rd, rs1, rs2      # Bitwise AND
or   rd, rs1, rs2      # Bitwise OR
xor  rd, rs1, rs2      # Bitwise XOR
andi/ori/xori          # Immediate versions
```

**Shifts:**
```asm
sll  rd, rs1, rs2      # Shift left logical
srl  rd, rs1, rs2      # Shift right logical
sra  rd, rs1, rs2      # Shift right arithmetic
slli/srli/srai         # Immediate versions
```

**Comparison:**
```asm
slt  rd, rs1, rs2      # Set if less than (signed)
sltu rd, rs1, rs2      # Set if less than (unsigned)
slti/sltiu             # Immediate versions
```

**Pseudo-instructions:**
```asm
li  rd, imm            # Load immediate
mv  rd, rs             # Move register
not rd, rs             # Bitwise NOT
neg rd, rs             # Negate
nop                    # No operation
```

---

*You've mastered RISC-V registers! Next: memory access!* 🎉
