# Lesson 04: Arithmetic Operations

Now that you understand registers and addressing, let's dive into arithmetic! RISC-V provides a rich set of arithmetic instructions for both simple and complex calculations.

## Learning Objectives

By the end of this lesson, you'll:
- Understand basic arithmetic instructions (ADD, SUB, ADDI)
- Learn about unsigned and signed arithmetic
- Master multiplication and division techniques
- Implement multi-word (64-bit) arithmetic on 32-bit hardware
- Handle overflow and carry operations
- Use pseudo-instructions for arithmetic

## Basic Arithmetic Instructions

### Addition and Subtraction

RISC-V has several arithmetic instructions:

**ADD** - Add two registers
```asm
add rd, rs1, rs2    # rd = rs1 + rs2
```

**SUB** - Subtract registers
```asm
sub rd, rs1, rs2    # rd = rs1 - rs2
```

**ADDI** - Add immediate (constant)
```asm
addi rd, rs1, imm   # rd = rs1 + imm
```

Note: There's no `SUBI` instruction. Use `addi` with a negative immediate!

```asm
addi a0, a0, -5     # a0 = a0 - 5
```

### Understanding Immediates

Immediate values in RISC-V are **12-bit signed** values:
- Range: -2048 to +2047
- For larger values, use `li` pseudo-instruction

```asm
addi a0, zero, 100      # Works: 100 fits in 12 bits
li a0, 100000           # For large values (becomes lui + addi)
```

## The Code

Here's a comprehensive arithmetic demonstration:

```asm
# arithmetic.s - Demonstrates RISC-V arithmetic operations

.section .data
result_msg: .string "Result: "
newline:    .string "\n"

.section .text
.globl _start

_start:
    # Basic addition
    li a0, 10
    li a1, 25
    add a2, a0, a1          # a2 = 10 + 25 = 35
    
    # Subtraction
    li a3, 100
    sub a4, a3, a2          # a4 = 100 - 35 = 65
    
    # Add immediate
    addi a5, a4, 50         # a5 = 65 + 50 = 115
    
    # Subtract using negative immediate
    addi a6, a5, -15        # a6 = 115 - 15 = 100
    
    # Negation (0 - x)
    sub a7, zero, a6        # a7 = 0 - 100 = -100
    
    # Demonstrate overflow
    li t0, 0x7FFFFFFF       # Maximum positive 32-bit signed int
    addi t1, t0, 1          # t1 = 0x80000000 (becomes negative!)
    
    # Multi-word addition (64-bit on 32-bit hardware)
    # Let's add 0x1_00000005 + 0x0_FFFFFFFF
    li t0, 0x00000005       # Lower 32 bits of first number
    li t1, 0x00000001       # Upper 32 bits of first number
    li t2, 0xFFFFFFFF       # Lower 32 bits of second number
    li t3, 0x00000000       # Upper 32 bits of second number
    
    add t4, t0, t2          # Add lower 32 bits
    sltu t5, t4, t0         # Check if carry (t4 < t0 means overflow)
    add t6, t1, t3          # Add upper 32 bits
    add t6, t6, t5          # Add carry to upper result
    # Result: t6:t4 = 0x1_00000004
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
```

## Breaking It Down

### Simple Addition

```asm
li a0, 10
li a1, 25
add a2, a0, a1          # a2 = 10 + 25 = 35
```

1. Load 10 into `a0`
2. Load 25 into `a1`
3. Add them, store in `a2`

### Subtraction

```asm
li a3, 100
sub a4, a3, a2          # a4 = 100 - 35 = 65
```

Important: Order matters! `sub a4, a3, a2` means `a4 = a3 - a2`, not `a2 - a3`.

### Immediate Operations

```asm
addi a5, a4, 50         # a5 = 65 + 50 = 115
addi a6, a5, -15        # a6 = 115 - 15 = 100
```

Immediate values are sign-extended, so negative numbers work naturally!

### Negation Trick

```asm
sub a7, zero, a6        # a7 = 0 - 100 = -100
```

Since `zero` always contains 0, subtracting from it negates a value.

### Multi-Word Addition

For 64-bit arithmetic on 32-bit hardware:

```asm
add t4, t0, t2          # Add lower 32 bits
sltu t5, t4, t0         # Detect carry: if (t4 < t0) then carry
add t6, t1, t3          # Add upper 32 bits
add t6, t6, t5          # Add the carry
```

**Why `sltu`?** Set Less Than Unsigned checks if `t4 < t0`. This only happens if there was a carry (overflow) from the lower 32-bit addition.

## Multiplication and Division

RISC-V base ISA (RV32I) doesn't include MUL/DIV. These are in the M extension (RV32IM).

### Software Multiplication

Without hardware multiply, we can multiply by:

1. **Repeated addition** (slow, simple)
2. **Shift and add** (faster)

Here's shift-and-add multiplication:

```asm
multiply:
    # Multiply a0 by a1, result in a2
    li a2, 0                # Initialize result
    li t0, 0                # Counter
    li t1, 32               # Loop 32 times (32 bits)
    
mult_loop:
    beq t0, t1, mult_done   # Done if counter == 32
    
    andi t2, a1, 1          # Check if LSB of a1 is 1
    beqz t2, mult_skip      # Skip add if LSB is 0
    add a2, a2, a0          # Add a0 to result
    
mult_skip:
    slli a0, a0, 1          # Shift a0 left (multiply by 2)
    srli a1, a1, 1          # Shift a1 right (divide by 2)
    addi t0, t0, 1          # Increment counter
    j mult_loop
    
mult_done:
    ret
```

### With M Extension

If you have RV32M (assemble with `-march=rv32im`):

```asm
mul  rd, rs1, rs2       # rd = (rs1 * rs2)[31:0] (lower 32 bits)
mulh rd, rs1, rs2       # rd = (rs1 * rs2)[63:32] (upper, signed)
mulhu rd, rs1, rs2      # rd = (rs1 * rs2)[63:32] (upper, unsigned)
mulhsu rd, rs1, rs2     # rd = (signed rs1 * unsigned rs2)[63:32]

div  rd, rs1, rs2       # rd = rs1 / rs2 (signed)
divu rd, rs1, rs2       # rd = rs1 / rs2 (unsigned)
rem  rd, rs1, rs2       # rd = rs1 % rs2 (signed remainder)
remu rd, rs1, rs2       # rd = rs1 % rs2 (unsigned remainder)
```

## Complete Example: Calculator

Here's a complete program with all arithmetic operations:

```asm
# calculator.s - Simple arithmetic calculator

.section .data
num1:   .word 42
num2:   .word 17
sum:    .word 0
diff:   .word 0
prod:   .word 0
quot:   .word 0

.section .text
.globl _start

_start:
    # Load numbers
    la t0, num1
    lw a0, 0(t0)            # a0 = 42
    la t0, num2
    lw a1, 0(t0)            # a1 = 17
    
    # Addition
    add t1, a0, a1          # t1 = 42 + 17 = 59
    la t0, sum
    sw t1, 0(t0)
    
    # Subtraction
    sub t1, a0, a1          # t1 = 42 - 17 = 25
    la t0, diff
    sw t1, 0(t0)
    
    # Multiplication (using M extension)
    mul t1, a0, a1          # t1 = 42 * 17 = 714
    la t0, prod
    sw t1, 0(t0)
    
    # Division (using M extension)
    div t1, a0, a1          # t1 = 42 / 17 = 2
    la t0, quot
    sw t1, 0(t0)
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
```

## Building and Running

### For RV32I (base ISA only)

```bash
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 arithmetic.s -o arithmetic.o
riscv64-unknown-elf-ld arithmetic.o -o arithmetic
qemu-riscv32 ./arithmetic
```

### For RV32IM (with multiply/divide)

```bash
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 calculator.s -o calculator.o
riscv64-unknown-elf-ld calculator.o -o calculator
qemu-riscv32 ./calculator
```

### Verify Results with GDB

```bash
qemu-riscv32 -g 1234 ./calculator &
riscv64-unknown-elf-gdb calculator
(gdb) target remote :1234
(gdb) break _start
(gdb) continue
(gdb) info registers a0 a1
(gdb) step
```

## Experiments

### Experiment 1: Test Overflow

```asm
li t0, 0x7FFFFFFF       # Max positive signed int
addi t1, t0, 1          # What happens?
```

What's in `t1`? It wraps to `0x80000000` (most negative number).

### Experiment 2: Unsigned vs Signed

```asm
li a0, -1               # All 1s: 0xFFFFFFFF
li a1, 1
add a2, a0, a1          # What's the result?
```

Result is 0! Arithmetic is the same for signed/unsigned, but comparisons differ.

### Experiment 3: Multi-Word Subtraction

Implement 64-bit subtraction:
```asm
# Subtract (t1:t0) - (t3:t2)
sub t4, t0, t2          # Lower 32 bits
sltu t5, t0, t2         # Borrow bit
sub t6, t1, t3          # Upper 32 bits
sub t6, t6, t5          # Subtract borrow
```

## Exercises

**Exercise 1:** Write a program that computes `(a + b) * (c - d)` where a=10, b=20, c=50, d=15.

**Exercise 2:** Implement a function that computes the absolute value of a signed integer.

**Exercise 3:** Write code to compute `a^2 + b^2` (sum of squares) for a=3, b=4.

**Exercise 4:** Implement 64-bit addition, taking two 64-bit numbers and producing a 64-bit result.

<details>
<summary>Solution to Exercise 2</summary>

```asm
# Absolute value function
abs_value:
    # Input: a0 = signed integer
    # Output: a0 = |a0|
    
    srai t0, a0, 31         # t0 = sign bit replicated (all 1s if negative)
    xor a0, a0, t0          # Flip bits if negative
    sub a0, a0, t0          # Add 1 if negative (sub -1)
    ret

_start:
    li a0, -42
    call abs_value          # a0 = 42
    
    li a0, 17
    call abs_value          # a0 = 17
    
    li a0, 0
    li a7, 93
    ecall
```

**How it works:**
- If positive: t0=0, `xor` does nothing, `sub` subtracts 0
- If negative: t0=-1 (all 1s), `xor` flips bits, `sub -1` adds 1 (two's complement negation)
</details>

<details>
<summary>Solution to Exercise 4</summary>

```asm
# 64-bit addition
# (t1:t0) = (a1:a0) + (a3:a2)

add64:
    add t0, a0, a2          # Add lower 32 bits
    sltu t2, t0, a0         # Get carry bit
    add t1, a1, a3          # Add upper 32 bits
    add t1, t1, t2          # Add carry
    ret

_start:
    # Add 0x1_00000000 + 0x0_FFFFFFFF = 0x1_FFFFFFFF
    li a0, 0x00000000       # Lower of first number
    li a1, 0x00000001       # Upper of first number
    li a2, 0xFFFFFFFF       # Lower of second number
    li a3, 0x00000000       # Upper of second number
    
    call add64
    # Result: t1:t0 = 0x1_FFFFFFFF
    
    li a0, 0
    li a7, 93
    ecall
```
</details>

## Deep Dive: Two's Complement

RISC-V uses **two's complement** for signed integers:

- Positive: 0x00000000 to 0x7FFFFFFF (0 to 2,147,483,647)
- Negative: 0x80000000 to 0xFFFFFFFF (-2,147,483,648 to -1)

To negate a number:
1. Flip all bits (bitwise NOT)
2. Add 1

Example: Negate 5
```
 5 = 0x00000005 = 0000 0000 0000 0000 0000 0000 0000 0101
~5 = 0xFFFFFFFA = 1111 1111 1111 1111 1111 1111 1111 1010
+1 = 0xFFFFFFFB = 1111 1111 1111 1111 1111 1111 1111 1011 = -5
```

This is why `sub a0, zero, a1` negates `a1`!

## Deep Dive: Overflow Detection

### Signed Overflow

Signed overflow occurs when:
- Adding two positives gives negative
- Adding two negatives gives positive

Detection:
```asm
add t0, a0, a1
xor t1, a0, t0          # Compare signs of operand and result
xor t2, a1, t0
and t3, t1, t2
srli t3, t3, 31         # t3 = 1 if overflow
```

### Unsigned Overflow (Carry)

Use `sltu` after addition:
```asm
add t0, a0, a1
sltu t1, t0, a0         # t1 = 1 if carry
```

## Deep Dive: Why No SUBI?

RISC-V philosophy: Keep instruction count minimal.

`addi rd, rs1, -imm` does the same job as a hypothetical `subi`.

Since immediates are **signed**, negative values work naturally:
```asm
addi a0, a0, -100       # Same as subi a0, a0, 100
```

This saves one instruction opcode!

## Deep Dive: Shift-and-Add Multiplication

The algorithm is based on binary multiplication:

```
      1011  (11 in binary)
    x 1101  (13 in binary)
    ------
      1011  (1011 x 1)
     0000   (1011 x 0, shifted)
    1011    (1011 x 1, shifted)
   1011     (1011 x 1, shifted)
   -------
   10001111 (143 in binary)
```

Each bit in the multiplier tells us whether to add the multiplicand (shifted appropriately).

## Common Mistakes

### Mistake 1: Immediate Out of Range
```asm
addi a0, zero, 5000     # ERROR: 5000 doesn't fit in 12 bits!
```
**Fix:** Use `li` for large values:
```asm
li a0, 5000             # OK: expands to lui + addi
```

### Mistake 2: Forgetting Overflow
```asm
add a0, a1, a2          # What if this overflows?
```
**Fix:** Check for overflow or use wider arithmetic.

### Mistake 3: SUB Operand Order
```asm
sub a0, a1, a2          # a0 = a1 - a2, NOT a2 - a1!
```

### Mistake 4: Signed vs Unsigned Confusion
```asm
li a0, -1               # 0xFFFFFFFF
li a1, 1
slt a2, a0, a1          # a2 = 1 (-1 < 1 in signed)
sltu a3, a0, a1         # a3 = 0 (0xFFFFFFFF > 1 in unsigned)
```

## Key Takeaways

✅ **ADD/SUB/ADDI** are the fundamental arithmetic instructions

✅ **Immediates** are 12-bit signed values (-2048 to 2047)

✅ **No SUBI** - use `addi` with negative immediate

✅ **Multi-word arithmetic** uses carry detection with `sltu`

✅ **Overflow** is silent - you must check explicitly

✅ **M extension** adds MUL, DIV, REM instructions

✅ **Two's complement** makes signed arithmetic work elegantly

## Next Lesson

Ready for control flow? Continue to:
**[Lesson 05: Control Flow →](../05-control-flow/)**

Learn about branches, jumps, and making decisions in assembly!

---

## Quick Reference

**Basic Arithmetic:**
```asm
add  rd, rs1, rs2       # rd = rs1 + rs2
sub  rd, rs1, rs2       # rd = rs1 - rs2
addi rd, rs1, imm       # rd = rs1 + imm (imm is signed)
```

**M Extension (RV32IM):**
```asm
mul   rd, rs1, rs2      # rd = (rs1 * rs2)[31:0]
mulh  rd, rs1, rs2      # rd = (rs1 * rs2)[63:32] signed
div   rd, rs1, rs2      # rd = rs1 / rs2 signed
rem   rd, rs1, rs2      # rd = rs1 % rs2
```

**Multi-word Addition:**
```asm
add  rd1, rs1, rs2      # Low word
sltu t0, rd1, rs1       # Carry detection
add  rd2, rs3, rs4      # High word
add  rd2, rd2, t0       # Add carry
```

**Negation:**
```asm
sub rd, zero, rs        # rd = -rs
```

---

*You're building a strong foundation in RISC-V assembly!* 🚀
