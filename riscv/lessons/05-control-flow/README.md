# Lesson 05: Control Flow - Branches and Jumps

Understanding control flow is crucial for writing meaningful programs. RISC-V provides elegant branch and jump instructions for conditional execution and loops.

## Learning Objectives

By the end of this lesson, you'll:
- Master conditional branch instructions (BEQ, BNE, BLT, BGE, etc.)
- Understand unconditional jumps (J, JAL, JALR)
- Write loops and conditional statements
- Compare signed vs unsigned comparisons
- Implement if-else and switch-case logic
- Understand PC-relative addressing for branches

## Branch Instructions

RISC-V has six main conditional branch instructions:

```asm
beq  rs1, rs2, label    # Branch if rs1 == rs2
bne  rs1, rs2, label    # Branch if rs1 != rs2
blt  rs1, rs2, label    # Branch if rs1 < rs2 (signed)
bge  rs1, rs2, label    # Branch if rs1 >= rs2 (signed)
bltu rs1, rs2, label    # Branch if rs1 < rs2 (unsigned)
bgeu rs1, rs2, label    # Branch if rs1 >= rs2 (unsigned)
```

Plus useful pseudo-instructions:

```asm
beqz rs, label          # Branch if rs == 0 (beq rs, zero, label)
bnez rs, label          # Branch if rs != 0 (bne rs, zero, label)
blez rs, label          # Branch if rs <= 0 (bge zero, rs, label)
bgez rs, label          # Branch if rs >= 0 (bge rs, zero, label)
bltz rs, label          # Branch if rs < 0 (blt rs, zero, label)
bgtz rs, label          # Branch if rs > 0 (blt zero, rs, label)
```

## Jump Instructions

```asm
j label                 # Unconditional jump (jal zero, label)
jal rd, label           # Jump and link (save return address)
jalr rd, rs1, offset    # Jump and link register
ret                     # Return from function (jalr zero, ra, 0)
```

## The Code

Here's a comprehensive control flow demonstration:

```asm
# control.s - Demonstrates branches and jumps

.section .data
msg_equal:    .string "Numbers are equal\n"
msg_less:     .string "First is less\n"
msg_greater:  .string "First is greater\n"
msg_positive: .string "Number is positive\n"
msg_negative: .string "Number is negative\n"
msg_zero:     .string "Number is zero\n"

.section .text
.globl _start

_start:
    # Example 1: Simple comparison
    li a0, 10
    li a1, 20
    
    beq a0, a1, equal       # Branch if equal
    blt a0, a1, less        # Branch if a0 < a1
    j greater               # Otherwise, a0 > a1

equal:
    la a1, msg_equal
    li a2, 18
    j print_and_continue

less:
    la a1, msg_less
    li a2, 14
    j print_and_continue

greater:
    la a1, msg_greater
    li a2, 18
    j print_and_continue

print_and_continue:
    li a0, 1
    li a7, 64
    ecall
    
    # Example 2: Check if number is positive, negative, or zero
    li t0, -5
    
    beqz t0, is_zero
    bltz t0, is_negative
    j is_positive

is_zero:
    la a1, msg_zero
    li a2, 15
    j print_sign

is_negative:
    la a1, msg_negative
    li a2, 19
    j print_sign

is_positive:
    la a1, msg_positive
    li a2, 19

print_sign:
    li a0, 1
    li a7, 64
    ecall
    
    # Example 3: Loop (count from 0 to 9)
    li t0, 0                # Counter
    li t1, 10               # Limit

count_loop:
    bge t0, t1, done        # Exit if t0 >= 10
    addi t0, t0, 1          # Increment counter
    j count_loop            # Repeat

done:
    # Exit
    li a0, 0
    li a7, 93
    ecall
```

## Breaking It Down

### Simple If-Else

```asm
li a0, 10
li a1, 20
beq a0, a1, equal       # if (a0 == a1) goto equal
blt a0, a1, less        # else if (a0 < a1) goto less
j greater               # else goto greater
```

This is like:
```c
if (a0 == a1) {
    // equal
} else if (a0 < a1) {
    // less
} else {
    // greater
}
```

### Zero Comparisons

```asm
beqz t0, is_zero        # if (t0 == 0)
bltz t0, is_negative    # else if (t0 < 0)
j is_positive           # else (t0 > 0)
```

These pseudo-instructions expand to:
- `beqz t0, label` → `beq t0, zero, label`
- `bltz t0, label` → `blt t0, zero, label`

### Simple Loop

```asm
li t0, 0                # i = 0
li t1, 10               # limit = 10

loop:
    bge t0, t1, done    # if (i >= limit) break
    # ... loop body ...
    addi t0, t0, 1      # i++
    j loop              # continue

done:
    # after loop
```

This is like:
```c
for (int i = 0; i < 10; i++) {
    // loop body
}
```

## More Examples

### Example: Maximum of Two Numbers

```asm
# max.s - Find maximum of two numbers

.section .text
.globl _start

_start:
    li a0, 42
    li a1, 37
    
    # Find max(a0, a1)
    bge a0, a1, a0_is_max
    mv a2, a1               # a2 = a1
    j print_max

a0_is_max:
    mv a2, a0               # a2 = a0

print_max:
    # a2 now contains the maximum
    # Exit with max as exit code
    mv a0, a2
    li a7, 93
    ecall
```

### Example: Factorial (Iterative)

```asm
# factorial.s - Compute factorial iteratively

.section .text
.globl _start

_start:
    li t0, 5                # Compute 5!
    li t1, 1                # Result = 1
    li t2, 1                # Counter = 1

factorial_loop:
    bgt t2, t0, done        # if counter > n, done
    mul t1, t1, t2          # result *= counter (needs M extension)
    addi t2, t2, 1          # counter++
    j factorial_loop

done:
    # t1 = 120 (5! = 5*4*3*2*1)
    mv a0, t1
    li a7, 93
    ecall
```

### Example: Sum Array

```asm
# sum_array.s - Sum elements of an array

.section .data
array: .word 10, 20, 30, 40, 50
count: .word 5

.section .text
.globl _start

_start:
    la t0, array            # Address of array
    la t1, count
    lw t1, 0(t1)            # Number of elements
    li t2, 0                # Sum = 0
    li t3, 0                # Index = 0

sum_loop:
    bge t3, t1, sum_done    # if index >= count, done
    
    lw t4, 0(t0)            # Load array[index]
    add t2, t2, t4          # sum += array[index]
    addi t0, t0, 4          # Move to next element
    addi t3, t3, 1          # index++
    j sum_loop

sum_done:
    # t2 = 150 (10+20+30+40+50)
    mv a0, t2
    li a7, 93
    ecall
```

### Example: Find in Array

```asm
# find.s - Find element in array

.section .data
array: .word 5, 12, 8, 23, 17, 9, 14
count: .word 7
target: .word 17

.section .text
.globl _start

_start:
    la t0, array            # Address of array
    la t1, count
    lw t1, 0(t1)            # count
    la t2, target
    lw t2, 0(t2)            # target value
    li t3, 0                # index
    li t4, -1               # result (found index, -1 if not found)

find_loop:
    bge t3, t1, find_done   # if index >= count, not found
    
    lw t5, 0(t0)            # Load array[index]
    beq t5, t2, found       # if array[index] == target, found!
    
    addi t0, t0, 4          # Next element
    addi t3, t3, 1          # index++
    j find_loop

found:
    mv t4, t3               # result = index

find_done:
    # t4 = 4 (found at index 4)
    mv a0, t4
    li a7, 93
    ecall
```

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 control.s -o control.o

# Link
riscv64-unknown-elf-ld control.o -o control

# Run
qemu-riscv32 ./control
```

For programs using multiplication (M extension):
```bash
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 factorial.s -o factorial.o
riscv64-unknown-elf-ld factorial.o -o factorial
qemu-riscv32 ./factorial
```

## Experiments

### Experiment 1: Reverse a Comparison

Change:
```asm
blt a0, a1, less        # if (a0 < a1)
```

To:
```asm
bge a0, a1, greater_equal  # if (a0 >= a1)
```

How does the logic change?

### Experiment 2: Do-While vs While Loop

While loop (condition at start):
```asm
loop:
    bge t0, t1, done    # Check condition first
    # ... body ...
    addi t0, t0, 1
    j loop
done:
```

Do-while loop (condition at end):
```asm
loop:
    # ... body ...
    addi t0, t0, 1
    blt t0, t1, loop    # Check condition at end
```

### Experiment 3: Signed vs Unsigned

```asm
li a0, -1               # 0xFFFFFFFF
li a1, 1

blt a0, a1, signed_less     # -1 < 1 (signed): TRUE
bltu a0, a1, unsigned_less  # 0xFFFFFFFF < 1 (unsigned): FALSE
```

What happens in each case?

## Exercises

**Exercise 1:** Write a program that finds the minimum of three numbers.

**Exercise 2:** Implement a countdown loop from 10 to 1.

**Exercise 3:** Write a program to check if a number is even or odd. (Hint: use `andi` to check the least significant bit.)

**Exercise 4:** Implement a simple switch-case statement for values 0, 1, 2, 3 (use a jump table).

<details>
<summary>Solution to Exercise 3</summary>

```asm
# even_odd.s - Check if number is even or odd

.section .data
msg_even: .string "Even\n"
msg_odd:  .string "Odd\n"

.section .text
.globl _start

_start:
    li t0, 42               # Number to check
    
    andi t1, t0, 1          # t1 = t0 & 1 (check LSB)
    bnez t1, is_odd         # if LSB is 1, it's odd
    
is_even:
    li a0, 1
    la a1, msg_even
    li a2, 5
    li a7, 64
    ecall
    j done

is_odd:
    li a0, 1
    la a1, msg_odd
    li a2, 4
    li a7, 64
    ecall

done:
    li a0, 0
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 4</summary>

```asm
# switch.s - Implement switch-case using jump table

.section .data
case0_msg: .string "Case 0\n"
case1_msg: .string "Case 1\n"
case2_msg: .string "Case 2\n"
case3_msg: .string "Case 3\n"
default_msg: .string "Default\n"

# Jump table (array of addresses)
jump_table:
    .word case0
    .word case1
    .word case2
    .word case3

.section .text
.globl _start

_start:
    li t0, 2                # Value to switch on
    
    # Bounds check
    li t1, 4
    bgeu t0, t1, default_case   # if value >= 4, default
    
    # Load address from jump table
    la t1, jump_table
    slli t2, t0, 2          # t2 = t0 * 4 (word offset)
    add t1, t1, t2          # Address of jump_table[t0]
    lw t1, 0(t1)            # Load target address
    jalr zero, t1, 0        # Jump to case

case0:
    la a1, case0_msg
    li a2, 7
    j print_case

case1:
    la a1, case1_msg
    li a2, 7
    j print_case

case2:
    la a1, case2_msg
    li a2, 7
    j print_case

case3:
    la a1, case3_msg
    li a2, 7
    j print_case

default_case:
    la a1, default_msg
    li a2, 8

print_case:
    li a0, 1
    li a7, 64
    ecall
    
    li a0, 0
    li a7, 93
    ecall
```
</details>

## Deep Dive: Branch Offsets

RISC-V branches use **PC-relative** addressing:

```asm
beq a0, a1, target
```

The instruction encoding contains:
- A 13-bit signed offset (in multiples of 2 bytes)
- Range: -4096 to +4094 bytes

If the target is too far, the assembler will error. Solution: use intermediate jumps.

### How PC-Relative Works

When `beq` executes:
```
target_address = PC + sign_extend(imm)
```

Example:
```
Address  Instruction
0x1000:  beq a0, a1, 0x100C
```

If branch is taken, PC becomes `0x1000 + 0xC = 0x100C`.

## Deep Dive: Branch Prediction

Modern CPUs predict branch outcomes:

**Static prediction:**
- Backward branches (loops) predicted taken
- Forward branches predicted not taken

**Dynamic prediction:**
- CPU learns branch patterns
- Branch history tables
- Two-bit saturating counters

Write code to be branch-prediction friendly:
- Keep loops simple
- Avoid unpredictable branches in hot paths
- Use predicated instructions when available

## Deep Dive: Conditional Moves

RISC-V doesn't have conditional move instructions (like x86 CMOV). Instead, use:

```asm
# Conditional move: if (a0 != 0) a1 = a2
beqz a0, skip
mv a1, a2
skip:
```

Or compute both paths and select:
```asm
# a0 = (condition) ? a1 : a2
beqz condition, else_case
mv a0, a1
j done
else_case:
mv a0, a2
done:
```

## Deep Dive: Loop Unrolling

Optimize loops by processing multiple iterations per loop:

**Original:**
```asm
li t0, 0
li t1, 100
loop:
    bge t0, t1, done
    # Process element[t0]
    addi t0, t0, 1
    j loop
```

**Unrolled (4x):**
```asm
li t0, 0
li t1, 100
loop:
    bge t0, t1, done
    # Process element[t0]
    # Process element[t0+1]
    # Process element[t0+2]
    # Process element[t0+3]
    addi t0, t0, 4
    j loop
```

Benefits:
- Fewer branch instructions
- Better instruction-level parallelism
- More optimization opportunities

## Common Mistakes

### Mistake 1: Wrong Branch Condition
```asm
# Want: while (i < 10)
loop:
    bge t0, t1, loop    # WRONG! Should be 'done'
```
**Fix:**
```asm
loop:
    bge t0, t1, done    # if i >= 10, exit
    # ... body ...
    j loop
done:
```

### Mistake 2: Signed vs Unsigned
```asm
li a0, -1
li a1, 1
blt a0, a1, less        # -1 < 1: TRUE (signed)
bltu a0, a1, less       # 0xFFFFFFFF < 1: FALSE (unsigned)
```

### Mistake 3: Forgetting to Jump
```asm
if_case:
    # Do something
    # Fall through to else! WRONG!
else_case:
    # Do something else
```
**Fix:**
```asm
if_case:
    # Do something
    j done              # Skip else
else_case:
    # Do something else
done:
```

### Mistake 4: Infinite Loop
```asm
loop:
    # Missing exit condition!
    j loop
```

## Key Takeaways

✅ **Six branch types:** BEQ, BNE, BLT, BGE, BLTU, BGEU

✅ **Pseudo-instructions** simplify common comparisons (BEQZ, BNEZ, etc.)

✅ **Branches are PC-relative** with limited range

✅ **Signed vs unsigned** matters for BLT/BGE vs BLTU/BGEU

✅ **J instruction** for unconditional jumps

✅ **Loops** use branch + jump combination

✅ **Always include exit condition** to avoid infinite loops

## Next Lesson

Ready to learn about functions? Continue to:
**[Lesson 06: Functions →](../06-functions/)**

Learn about function calls, calling conventions, and the stack!

---

## Quick Reference

**Branches:**
```asm
beq  rs1, rs2, label    # ==
bne  rs1, rs2, label    # !=
blt  rs1, rs2, label    # < (signed)
bge  rs1, rs2, label    # >= (signed)
bltu rs1, rs2, label    # < (unsigned)
bgeu rs1, rs2, label    # >= (unsigned)
```

**Pseudo-branches:**
```asm
beqz rs, label          # == 0
bnez rs, label          # != 0
bltz rs, label          # < 0
bgez rs, label          # >= 0
```

**Jumps:**
```asm
j label                 # Unconditional jump
jal rd, label           # Jump and link
jalr rd, rs, offset     # Jump register
ret                     # Return (jalr zero, ra, 0)
```

**Loop Pattern:**
```asm
    li t0, 0            # counter
    li t1, limit
loop:
    bge t0, t1, done
    # ... body ...
    addi t0, t0, 1
    j loop
done:
```

---

*Control flow is the backbone of programming!* 🎯
