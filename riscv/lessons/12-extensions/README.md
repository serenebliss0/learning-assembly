# Lesson 12: RISC-V Extensions - Expanding the ISA

RISC-V's modular design is one of its greatest strengths. The base ISA (RV32I) is minimal and complete, but **extensions** add powerful capabilities for specific use cases. This lesson explores the most important standard extensions.

## Learning Objectives

By the end of this lesson, you'll:
- Understand RISC-V's modular extension philosophy
- Master the M extension for multiplication and division
- Work with the A extension for atomic operations
- Understand F/D extensions for floating-point
- Learn about the C extension for code compression
- Know how to detect available extensions
- Choose appropriate instructions for your hardware

## RISC-V Extension Philosophy

RISC-V uses a **modular approach**:
- **Base ISA**: RV32I or RV64I (minimal, always present)
- **Extensions**: Optional features that can be added

**Common Extension Naming:**
- **RV32IM**: 32-bit base + multiplication
- **RV32IMAC**: 32-bit base + multiplication + atomics + compressed
- **RV32GC**: "General" = IMAFD + Zicsr + Zifencei + C (most common)
- **RV64GC**: 64-bit version of the above

## The M Extension: Multiplication and Division

The M extension adds hardware support for integer multiplication and division. Without it, you'd have to implement these in software (slow!).

### M Extension Instructions

| Instruction | Operation | Description |
|-------------|-----------|-------------|
| `mul rd, rs1, rs2` | rd = rs1 × rs2 | Multiply (lower 32 bits) |
| `mulh rd, rs1, rs2` | rd = (rs1 × rs2) >> 32 | Multiply high (signed × signed) |
| `mulhsu rd, rs1, rs2` | rd = (rs1 × rs2) >> 32 | Multiply high (signed × unsigned) |
| `mulhu rd, rs1, rs2` | rd = (rs1 × rs2) >> 32 | Multiply high (unsigned × unsigned) |
| `div rd, rs1, rs2` | rd = rs1 ÷ rs2 | Divide (signed) |
| `divu rd, rs1, rs2` | rd = rs1 ÷ rs2 | Divide (unsigned) |
| `rem rd, rs1, rs2` | rd = rs1 % rs2 | Remainder (signed) |
| `remu rd, rs1, rs2` | rd = rs1 % rs2 | Remainder (unsigned) |

### Why Two Multiply Instructions?

When you multiply two 32-bit numbers, the result can be up to 64 bits:
- `mul` gives you the **lower 32 bits**
- `mulh/mulhu/mulhsu` give you the **upper 32 bits**

For example: `0xFFFFFFFF × 0xFFFFFFFF = 0xFFFFFFFE00000001`
- `mul` returns `0x00000001`
- `mulhu` returns `0xFFFFFFFE`

## The Code: Multiplication and Division

Create a file called `multiply.s`:

```asm
# multiply.s - M Extension: Multiplication and Division
# Requires -march=rv32im or higher

.section .data
msg_multiply:
    .string "=== Multiplication Examples ===\n"
msg_mul_len = . - msg_multiply

msg_divide:
    .string "\n=== Division Examples ===\n"
msg_div_len = . - msg_divide

result_msg:
    .string "Result: "
result_len = . - result_msg

newline:
    .string "\n"

# Buffer for number to string conversion
num_buffer:
    .space 12

.section .text
.globl _start

_start:
    # Print multiplication header
    li a7, 64
    li a0, 1
    la a1, msg_multiply
    li a2, msg_mul_len
    ecall
    
    # === Example 1: Simple multiplication ===
    # 12 × 5 = 60
    li t0, 12
    li t1, 5
    mul t2, t0, t1         # t2 = 12 × 5 = 60
    
    # Print result (simplified - just storing)
    mv s0, t2              # s0 = 60
    
    # === Example 2: Large multiplication (needs high word) ===
    # 0x80000000 × 2 = 0x100000000 (overflows 32 bits!)
    li t0, 0x80000000      # 2^31
    li t1, 2
    
    mul t2, t0, t1         # Lower 32 bits = 0x00000000
    mulhu t3, t0, t1       # Upper 32 bits = 0x00000001
    
    # Result is: t3:t2 = 0x0000000100000000
    mv s1, t2              # s1 = lower 32 bits
    mv s2, t3              # s2 = upper 32 bits
    
    # === Example 3: Signed vs Unsigned ===
    li t0, -1              # 0xFFFFFFFF
    li t1, -1              # 0xFFFFFFFF
    
    mul t2, t0, t1         # Lower bits: 0x00000001 (same for signed/unsigned)
    mulh t3, t0, t1        # Signed: (-1) × (-1) = +1, high = 0x00000000
    mulhu t4, t0, t1       # Unsigned: 0xFFFF... × 0xFFFF..., high = 0xFFFFFFFE
    
    mv s3, t2              # s3 = 1 (lower)
    mv s4, t3              # s4 = 0 (signed high)
    mv s5, t4              # s5 = 0xFFFFFFFE (unsigned high)
    
    # === Example 4: 64-bit multiplication result ===
    # Compute 1000000 × 1000000 = 1000000000000
    li t0, 1000000
    li t1, 1000000
    
    mul t2, t0, t1         # Lower 32 bits
    mulhu t3, t0, t1       # Upper 32 bits
    # Result: t3:t2 = 1000000000000 = 0xE8D4A51000
    
    mv s6, t2              # Lower word
    mv s7, t3              # Upper word
    
    # === Division Examples ===
    # Print division header
    li a7, 64
    li a0, 1
    la a1, msg_divide
    li a2, msg_div_len
    ecall
    
    # === Example 5: Simple division ===
    # 100 ÷ 7 = 14 remainder 2
    li t0, 100
    li t1, 7
    
    div t2, t0, t1         # t2 = 100 ÷ 7 = 14
    rem t3, t0, t1         # t3 = 100 % 7 = 2
    
    mv s8, t2              # s8 = quotient (14)
    mv s9, t3              # s9 = remainder (2)
    
    # === Example 6: Signed division ===
    # -100 ÷ 7 = -14 remainder -2
    li t0, -100
    li t1, 7
    
    div t2, t0, t1         # t2 = -100 ÷ 7 = -14
    rem t3, t0, t1         # t3 = -100 % 7 = -2
    
    mv s10, t2             # s10 = -14
    mv s11, t3             # s11 = -2
    
    # === Example 7: Unsigned division ===
    # 0xFFFFFFFF ÷ 2 (unsigned vs signed)
    li t0, -1              # 0xFFFFFFFF
    li t1, 2
    
    div t2, t0, t1         # Signed: -1 ÷ 2 = 0 (rounds toward zero)
    divu t3, t0, t1        # Unsigned: 0xFFFFFFFF ÷ 2 = 0x7FFFFFFF
    
    # === Example 8: Division by zero (undefined!) ===
    # Note: Division by zero returns specific values (not exception):
    # div:  returns -1
    # divu: returns 0xFFFFFFFF (all bits set)
    # rem:  returns dividend
    # remu: returns dividend
    
    li t0, 42
    li t1, 0               # Zero!
    
    div t2, t0, t1         # t2 = -1 (all bits set)
    rem t3, t0, t1         # t3 = 42 (dividend)
    
    # === Exit ===
    li a7, 93
    li a0, 0
    ecall

# Helper function: Print number (simplified version)
# Input: a0 = number to print
print_number:
    # This is a simplified placeholder
    # A full implementation would convert to decimal string
    ret
```

## The A Extension: Atomic Operations

The A extension provides **atomic memory operations** essential for:
- Multi-threaded programming
- Lock-free data structures
- Synchronization primitives
- Hardware coordination

### Why Atomics?

Consider this non-atomic increment:
```asm
lw t0, 0(a0)           # Read value
addi t0, t0, 1         # Increment
sw t0, 0(a0)           # Write back
```

**Problem:** Between read and write, another thread could modify the value!

**Solution:** Atomic operations that are indivisible.

### Atomic Instruction Types

**Load-Reserved/Store-Conditional (LR/SC):**
- `lr.w rd, (rs1)` - Load and "reserve" address
- `sc.w rd, rs2, (rs1)` - Store only if reservation still valid

**Atomic Memory Operations (AMO):**
| Instruction | Operation | Description |
|-------------|-----------|-------------|
| `amoswap.w` | Atomic swap | Exchange memory and register |
| `amoadd.w` | Atomic add | Add to memory |
| `amoxor.w` | Atomic XOR | XOR with memory |
| `amoand.w` | Atomic AND | AND with memory |
| `amoor.w` | Atomic OR | OR with memory |
| `amomin.w` | Atomic min | Store minimum |
| `amomax.w` | Atomic max | Store maximum |
| `amominu.w` | Atomic min (unsigned) | Store minimum (unsigned) |
| `amomaxu.w` | Atomic max (unsigned) | Store maximum (unsigned) |

Each can have ordering modifiers:
- `.aq` - Acquire ordering
- `.rl` - Release ordering
- `.aqrl` - Both acquire and release

## The Code: Atomic Operations

Create a file called `atomic.s`:

```asm
# atomic.s - A Extension: Atomic Operations
# Requires -march=rv32ima or higher

.section .data
counter:
    .word 0                # Shared counter

lock_var:
    .word 0                # Lock variable (0=unlocked, 1=locked)

array_data:
    .word 10, 20, 30, 40, 50

msg_start:
    .string "=== Atomic Operations Demo ===\n"
msg_start_len = . - msg_start

msg_counter:
    .string "Counter operations complete\n"
msg_counter_len = . - msg_counter

msg_lock:
    .string "Lock/unlock operations complete\n"
msg_lock_len = . - msg_lock

msg_swap:
    .string "Swap operations complete\n"
msg_swap_len = . - msg_swap

.section .text
.globl _start

_start:
    # Print start message
    li a7, 64
    li a0, 1
    la a1, msg_start
    li a2, msg_start_len
    ecall
    
    # === Example 1: Atomic increment with AMO ===
    la t0, counter
    
    # Atomic add: counter += 5
    li t1, 5
    amoadd.w t2, t1, (t0)  # t2 = old value, mem[t0] += t1
    
    # Do it again
    li t1, 3
    amoadd.w t2, t1, (t0)  # counter is now 8
    
    # Print counter message
    li a7, 64
    li a0, 1
    la a1, msg_counter
    li a2, msg_counter_len
    ecall
    
    # === Example 2: Spinlock with LR/SC ===
    la s0, lock_var
    
acquire_lock:
    # Try to acquire lock
    li t0, 1               # Value to write (locked)
    
    lr.w t1, (s0)          # Load-reserved from lock
    bnez t1, acquire_lock  # If already locked, spin
    
    sc.w t2, t0, (s0)      # Try to store 1 (acquire)
    bnez t2, acquire_lock  # If sc failed (t2 != 0), retry
    
    # === Lock acquired - critical section ===
    # Do some work...
    li t0, 42
    addi t0, t0, 8
    
    # === Release lock ===
release_lock:
    sw zero, (s0)          # Simple store to release
    
    # Print lock message
    li a7, 64
    li a0, 1
    la a1, msg_lock
    li a2, msg_lock_len
    ecall
    
    # === Example 3: Atomic swap ===
    la t0, array_data
    lw t1, 0(t0)           # t1 = 10
    
    li t2, 99
    amoswap.w t3, t2, (t0) # Swap: t3 = old value (10), mem = 99
    
    # Now array_data[0] = 99, t3 = 10
    
    # === Example 4: Atomic maximum ===
    la t0, counter
    li t1, 100
    amomax.w t2, t1, (t0)  # mem = max(mem, t1)
    
    # === Example 5: Compare-and-swap using LR/SC ===
    # Atomic: if (mem == expected) mem = new_value
    la t0, counter
    li t1, 100             # expected
    li t2, 200             # new_value
    
cas_loop:
    lr.w t3, (t0)          # Load current value
    bne t3, t1, cas_fail   # If not equal to expected, fail
    
    sc.w t4, t2, (t0)      # Try to store new value
    bnez t4, cas_loop      # If failed, retry
    
    # Success: counter was 100, now is 200
    j cas_done
    
cas_fail:
    # Value was not as expected
    
cas_done:
    # Print swap message
    li a7, 64
    li a0, 1
    la a1, msg_swap
    li a2, msg_swap_len
    ecall
    
    # === Exit ===
    li a7, 93
    li a0, 0
    ecall
```

## The F and D Extensions: Floating-Point

The F and D extensions add hardware floating-point support:

- **F Extension**: 32-bit single-precision (IEEE 754)
- **D Extension**: 64-bit double-precision (builds on F)

### Floating-Point Registers

These extensions add **32 floating-point registers** (f0-f31):
- Separate from integer registers (x0-x31)
- 32-bit wide (F) or 64-bit wide (D)
- Follow similar ABI naming (fa0-fa7 for args, ft0-ft11 for temps, etc.)

### Key FP Instructions (F Extension)

| Instruction | Operation |
|-------------|-----------|
| `flw fd, offset(rs1)` | Load float from memory |
| `fsw fs2, offset(rs1)` | Store float to memory |
| `fadd.s fd, fs1, fs2` | Floating add |
| `fsub.s fd, fs1, fs2` | Floating subtract |
| `fmul.s fd, fs1, fs2` | Floating multiply |
| `fdiv.s fd, fs1, fs2` | Floating divide |
| `fsqrt.s fd, fs1` | Floating square root |
| `fmin.s fd, fs1, fs2` | Minimum |
| `fmax.s fd, fs1, fs2` | Maximum |
| `feq.s rd, fs1, fs2` | Compare equal (result in integer reg) |
| `flt.s rd, fs1, fs2` | Compare less than |
| `fle.s rd, fs1, fs2` | Compare less than or equal |

**Note:** This lesson focuses on integer operations. Floating-point deserves its own dedicated lesson!

## The C Extension: Compressed Instructions

The C extension adds **16-bit compressed instructions** to reduce code size:

- Normal RISC-V instructions: 32 bits
- Compressed instructions: 16 bits
- **Hardware automatically decodes** both formats

### Examples of Compressed Instructions

| 32-bit | 16-bit (C extension) | Savings |
|--------|----------------------|---------|
| `addi x8, x8, 4` | `c.addi x8, 4` | 50% |
| `lw x9, 0(x8)` | `c.lw x9, 0(x8)` | 50% |
| `jr x1` | `c.jr x1` | 50% |
| `li x10, 0` | `c.li x10, 0` | 50% |

**Benefits:**
- Smaller code size (typically 25-30% reduction)
- Better instruction cache utilization
- Lower memory bandwidth
- Important for embedded systems

**Limitations:**
- Only common operations compressed
- Limited immediate value ranges
- Some register restrictions

You typically don't write compressed instructions directly - the assembler automatically uses them when you specify `-march=rv32imac` or `-march=rv32gc`.

## Detecting Available Extensions

Your code may run on different RISC-V implementations. How do you know what's available?

### Method 1: Build-Time Configuration

Use different build targets:
```bash
# Minimal
as -march=rv32i ...

# With multiplication
as -march=rv32im ...

# With multiplication and atomics
as -march=rv32ima ...

# Full "general" configuration
as -march=rv32gc ...
```

### Method 2: Runtime Detection (Linux)

Read `/proc/cpuinfo` or use the `misa` CSR (requires privilege).

### Method 3: Trap and Emulate

Try the instruction; if unsupported, trap handler can emulate it (slow!).

## Building and Running

### With M Extension

```bash
# Requires M extension
riscv64-linux-gnu-as -march=rv32im -mabi=ilp32 -o multiply.o multiply.s
riscv64-linux-gnu-ld -m elf32lriscv -o multiply multiply.o

qemu-riscv32 ./multiply
```

### With A Extension

```bash
# Requires A extension
riscv64-linux-gnu-as -march=rv32ima -mabi=ilp32 -o atomic.o atomic.s
riscv64-linux-gnu-ld -m elf32lriscv -o atomic atomic.o

qemu-riscv32 ./atomic
```

### What if Your Target Doesn't Support an Extension?

1. **Use base ISA instructions** - implement multiply with shifts/adds
2. **Software emulation** - trap handler emulates missing instructions
3. **Conditional compilation** - different code paths for different targets
4. **Choose appropriate target** - if you need M, use RV32IM

## Experiments to Try

### 1. **Implement 64-bit Multiplication**
Use `mul` and `mulh` to multiply two 32-bit numbers and get a 64-bit result.

### 2. **Software Multiply**
Implement multiplication using only shifts and adds (for RV32I-only targets).

### 3. **Atomic Counter**
Create a thread-safe counter using different atomic approaches (AMO vs LR/SC).

### 4. **Spinlock Benchmark**
Compare spinlock performance with and without proper acquire/release semantics.

### 5. **Division by Constant**
Optimize division by constant power-of-2 using shifts instead of `div`.

## Deep Dive: Why LR/SC Instead of CAS?

Many architectures provide a simple **Compare-And-Swap (CAS)** instruction:
```
if (mem == expected) {
    mem = new_value;
    return success;
}
```

RISC-V uses **LR/SC** (Load-Reserved/Store-Conditional) instead because:

1. **More flexible** - can do complex operations between LR and SC
2. **Simpler hardware** - easier to implement in multi-core systems
3. **Composable** - can build CAS, LL/SC, and more on top of LR/SC

**LR/SC Guarantees:**
- SC succeeds only if no other core has written to the reserved address
- SC succeeds only if no exception occurred between LR and SC
- **Not guaranteed to succeed** even if no interference (can spuriously fail)

**Best Practice:** Always use LR/SC in a loop!

## Deep Dive: Multiply Cost

Why does the M extension exist?

**Software multiply** (shift-and-add) requires ~32 iterations:
```asm
# Multiply t0 by t1, result in t2 (software)
li t2, 0
li t3, 32              # Bit counter
mult_loop:
    andi t4, t1, 1     # Check LSB
    beqz t4, skip
    add t2, t2, t0     # Add if bit is 1
skip:
    slli t0, t0, 1     # Shift multiplicand
    srli t1, t1, 1     # Shift multiplier
    addi t3, t3, -1
    bnez t3, mult_loop
```

**Hardware multiply** (M extension):
```asm
mul t2, t0, t1         # Single cycle (or pipelined)
```

**Speed difference:** 30-50x faster with hardware!

## Common Mistakes

### 1. **Forgetting High Word in Multiplication**
```asm
# WRONG - Overflow not detected!
li t0, 0x80000000
li t1, 4
mul t2, t0, t1         # t2 = 0 (overflow!)
```

Always check if result might exceed 32 bits.

### 2. **Division by Zero**
```asm
# WRONG - Assuming exception on divide-by-zero
div t0, t1, zero       # No exception! Returns -1
```

RISC-V division by zero doesn't trap - check first!

### 3. **Broken LR/SC Pairs**
```asm
# WRONG - Too much between LR and SC
lr.w t0, (a0)
# 100 instructions...
sc.w t1, t2, (a0)      # Will likely fail
```

Keep LR/SC pairs small and tight.

### 4. **Non-Atomic Sequence**
```asm
# WRONG - Not atomic!
lw t0, 0(a0)           # Read
addi t0, t0, 1         # Modify
sw t0, 0(a0)           # Write - race condition!
```

Use AMO or LR/SC for atomicity.

### 5. **Wrong March Flag**
```asm
mul t0, t1, t2         # Requires M extension!
```
```bash
# WRONG
as -march=rv32i ...    # Error: unrecognized opcode
```

Must use `-march=rv32im` or higher.

## Extension Quick Reference

### Standard Extensions

| Letter | Name | Description |
|--------|------|-------------|
| I | Integer | Base integer ISA (always present) |
| M | Multiply | Integer multiply/divide |
| A | Atomic | Atomic operations |
| F | Float | Single-precision floating-point |
| D | Double | Double-precision floating-point |
| C | Compressed | 16-bit compressed instructions |
| G | General | Shorthand for IMAFD_Zicsr_Zifencei |

### Common Combinations

- **RV32I**: Minimal (embedded microcontrollers)
- **RV32IM**: With multiply (most embedded)
- **RV32IMA**: With multiply and atomics (multi-core)
- **RV32GC**: "General" with compressed (Linux systems)

### Checking Your CPU

```bash
# On Linux RISC-V system
cat /proc/cpuinfo | grep isa

# Example output:
# isa: rv64imafdcsu
```

## Key Takeaways

1. **RISC-V is modular** - base ISA + optional extensions
2. **M extension is nearly universal** - hardware multiply/divide
3. **Multiply can overflow 32 bits** - use `mulh` for high word
4. **Division by zero doesn't trap** - returns defined values
5. **A extension enables threading** - atomic operations for synchronization
6. **LR/SC is more flexible than CAS** - but requires loops
7. **AMO instructions are atomic** - single-instruction read-modify-write
8. **F/D add floating-point** - separate register file
9. **C reduces code size** - 16-bit compressed instructions
10. **Match -march to hardware** - use appropriate extensions

## Additional Resources

- [RISC-V M Extension Specification](https://riscv.org/technical/specifications/)
- [RISC-V A Extension Specification](https://riscv.org/technical/specifications/)
- [Atomic Operations Tutorial](https://preshing.com/20120612/an-introduction-to-lock-free-programming/)
- [IEEE 754 Floating-Point Standard](https://en.wikipedia.org/wiki/IEEE_754)
- [RISC-V Extension List](https://wiki.riscv.org/display/HOME/RISC-V+Extensions)

## What's Next?

In **Lesson 13: Exception Handling**, we'll dive into how RISC-V handles exceptional conditions:
- Different types of exceptions (traps)
- Control and Status Registers (CSRs)
- Writing exception handlers
- The `ecall` and `ebreak` instructions
- Understanding privilege levels

Get ready to understand how syscalls actually work under the hood! 🚀
