# Lesson 06: Functions and Calling Conventions

Functions are the building blocks of structured programs. RISC-V has elegant instructions for function calls and a well-defined calling convention.

## Learning Objectives

By the end of this lesson, you'll:
- Understand the RISC-V calling convention
- Master JAL and JALR instructions
- Know how to preserve and restore registers
- Work with stack frames
- Handle function arguments and return values
- Implement nested function calls
- Write recursive functions

## Function Call Instructions

**JAL (Jump and Link)**
```asm
jal rd, label           # rd = PC + 4, PC = label
```
Saves return address in `rd` and jumps to `label`.

**JALR (Jump and Link Register)**
```asm
jalr rd, rs1, offset    # rd = PC + 4, PC = rs1 + offset
```
Saves return address in `rd` and jumps to address in register.

**Common patterns:**
```asm
call label              # Pseudo: jal ra, label
ret                     # Pseudo: jalr zero, ra, 0
```

## RISC-V Calling Convention

RISC-V follows a standard calling convention (defined in the ABI):

### Register Usage

**Argument registers (a0-a7):**
- `a0-a1` (x10-x11): Arguments 1-2, also return values
- `a2-a7` (x12-x17): Arguments 3-8

**Temporaries (t0-t6):**
- `t0-t6` (x5-x7, x28-x31): Temporary registers
- **Caller-saved**: Not preserved across calls

**Saved registers (s0-s11):**
- `s0-s11` (x8-x9, x18-x27): Saved registers
- **Callee-saved**: Must be preserved if used

**Special registers:**
- `ra` (x1): Return address
- `sp` (x2): Stack pointer
- `gp` (x3): Global pointer
- `tp` (x4): Thread pointer
- `zero` (x0): Always zero

### What to Save?

**Caller-saved** (save before call if needed):
- `t0-t6`, `a0-a7`

**Callee-saved** (save on entry if used):
- `s0-s11`, `ra`, `sp`

## Basic Function Call

Here's a simple function:

```asm
# add_numbers.s - Simple function example

.section .text
.globl _start

_start:
    li a0, 10
    li a1, 25
    call add_two            # Call function
    # a0 now contains 35
    
    # Exit with result
    li a7, 93
    ecall

# Function: add_two
# Arguments: a0, a1 (two numbers)
# Returns: a0 (sum)
add_two:
    add a0, a0, a1          # a0 = a0 + a1
    ret                     # Return to caller
```

## The Code - Comprehensive Example

```asm
# functions.s - Demonstrates function calls and calling convention

.section .data
msg_result: .string "Factorial result stored\n"

.section .text
.globl _start

_start:
    # Call factorial(5)
    li a0, 5
    call factorial
    # Result in a0 (should be 120)
    
    # Save result
    mv s0, a0
    
    # Call fibonacci(10)
    li a0, 10
    call fibonacci
    # Result in a0
    
    # Print message
    li a0, 1
    la a1, msg_result
    li a2, 25
    li a7, 64
    ecall
    
    # Exit with factorial result
    mv a0, s0
    li a7, 93
    ecall

# Function: factorial
# Input: a0 = n
# Output: a0 = n!
# Uses: t0 (counter), t1 (result) - temporaries don't need saving
factorial:
    li t1, 1                # result = 1
    li t0, 1                # counter = 1

fact_loop:
    bgt t0, a0, fact_done   # if counter > n, done
    mul t1, t1, t0          # result *= counter
    addi t0, t0, 1          # counter++
    j fact_loop

fact_done:
    mv a0, t1               # Return result
    ret

# Function: fibonacci (iterative)
# Input: a0 = n
# Output: a0 = fibonacci(n)
# Uses: t0, t1, t2, t3
fibonacci:
    beqz a0, fib_zero       # if n == 0, return 0
    li t1, 1
    beq a0, t1, fib_one     # if n == 1, return 1
    
    # fib(n) for n >= 2
    li t0, 0                # fib(i-2)
    li t1, 1                # fib(i-1)
    li t3, 2                # counter = 2

fib_loop:
    bgt t3, a0, fib_done    # if counter > n, done
    add t2, t0, t1          # fib(i) = fib(i-1) + fib(i-2)
    mv t0, t1               # fib(i-2) = old fib(i-1)
    mv t1, t2               # fib(i-1) = fib(i)
    addi t3, t3, 1          # counter++
    j fib_loop

fib_done:
    mv a0, t1               # Return fib(n)
    ret

fib_zero:
    li a0, 0
    ret

fib_one:
    li a0, 1
    ret
```

## Breaking It Down

### Simple Call

```asm
li a0, 10               # Set up argument
call add_two            # Call function (expands to jal ra, add_two)
# Return address saved in ra
# a0 contains return value
```

### Function Definition

```asm
add_two:
    add a0, a0, a1      # Compute result
    ret                 # Return (expands to jalr zero, ra, 0)
```

The `ret` instruction:
- Expands to `jalr zero, ra, 0`
- Jumps to address in `ra`
- Doesn't save return address (writes to `zero`)

### Preserving Registers

If a function uses saved registers (`s0-s11`), it must preserve them:

```asm
my_function:
    # Save registers we'll use
    addi sp, sp, -8         # Allocate stack space
    sw s0, 0(sp)            # Save s0
    sw s1, 4(sp)            # Save s1
    
    # Function body
    li s0, 100
    li s1, 200
    add a0, s0, s1
    
    # Restore registers
    lw s0, 0(sp)            # Restore s0
    lw s1, 4(sp)            # Restore s1
    addi sp, sp, 8          # Deallocate stack space
    ret
```

## Stack Frames

For complex functions, create a stack frame:

```asm
complex_function:
    # Prologue: Set up stack frame
    addi sp, sp, -16        # Allocate 16 bytes
    sw ra, 12(sp)           # Save return address
    sw s0, 8(sp)            # Save s0
    sw s1, 4(sp)            # Save s1
    sw s2, 0(sp)            # Save s2
    
    # Function body
    # ... use s0, s1, s2 ...
    # ... make nested calls (ra will be overwritten) ...
    
    # Epilogue: Tear down stack frame
    lw ra, 12(sp)           # Restore return address
    lw s0, 8(sp)            # Restore s0
    lw s1, 4(sp)            # Restore s1
    lw s2, 0(sp)            # Restore s2
    addi sp, sp, 16         # Deallocate
    ret
```

## Recursive Functions

```asm
# recursive_factorial.s - Factorial using recursion

.section .text
.globl _start

_start:
    li a0, 5
    call factorial_recursive
    # a0 = 120
    
    li a7, 93
    ecall

# Recursive factorial: factorial(n)
# Base case: n <= 1, return 1
# Recursive: n * factorial(n-1)
factorial_recursive:
    # Base case: if n <= 1, return 1
    li t0, 1
    ble a0, t0, base_case
    
    # Recursive case
    addi sp, sp, -8         # Allocate stack
    sw ra, 4(sp)            # Save return address
    sw a0, 0(sp)            # Save n
    
    addi a0, a0, -1         # n - 1
    call factorial_recursive # factorial(n-1)
    
    lw t0, 0(sp)            # Restore n
    mul a0, a0, t0          # n * factorial(n-1)
    
    lw ra, 4(sp)            # Restore return address
    addi sp, sp, 8          # Deallocate stack
    ret

base_case:
    li a0, 1
    ret
```

## Multi-Argument Functions

```asm
# Function with multiple arguments
# sum_of_products(a, b, c, d) = a*b + c*d

sum_of_products:
    # Arguments: a0=a, a1=b, a2=c, a3=d
    
    mul t0, a0, a1          # t0 = a * b
    mul t1, a2, a3          # t1 = c * d
    add a0, t0, t1          # return a*b + c*d
    ret

_start:
    li a0, 3
    li a1, 4
    li a2, 5
    li a3, 6
    call sum_of_products
    # a0 = 3*4 + 5*6 = 12 + 30 = 42
    
    li a7, 93
    ecall
```

## Leaf vs Non-Leaf Functions

**Leaf function** (doesn't call other functions):
- May not need to save `ra`
- Only save `s` registers if used

```asm
leaf_function:
    # No stack frame needed if only using temporaries
    add a0, a0, a1
    ret
```

**Non-leaf function** (calls other functions):
- Must save `ra` (will be overwritten)
- Save any `s` registers used

```asm
non_leaf:
    addi sp, sp, -4
    sw ra, 0(sp)            # Must save ra!
    
    call some_other_function
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
```

## Building and Running

```bash
# Assemble (with M extension for multiply)
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 functions.s -o functions.o

# Link
riscv64-unknown-elf-ld functions.o -o functions

# Run
qemu-riscv32 ./functions

# Check exit code
echo $?
```

## Experiments

### Experiment 1: Trace Function Calls

Add prints to see the call sequence:

```asm
function_a:
    # Print "Entering A"
    call function_b
    # Print "Leaving A"
    ret
```

### Experiment 2: Break the Convention

Try NOT saving `ra` in a non-leaf function. What happens?

### Experiment 3: Deep Recursion

Compute `factorial(10)` recursively. Count how much stack space is used.

## Exercises

**Exercise 1:** Write a function `max3(a, b, c)` that returns the maximum of three numbers.

**Exercise 2:** Implement `power(base, exponent)` iteratively.

**Exercise 3:** Write a recursive function to compute the sum of integers from 1 to n.

**Exercise 4:** Implement `gcd(a, b)` using Euclid's algorithm recursively.

<details>
<summary>Solution to Exercise 1</summary>

```asm
# max3 - Find maximum of three numbers
# Arguments: a0, a1, a2
# Returns: a0

max3:
    # Find max(a0, a1)
    bge a0, a1, check_third
    mv a0, a1               # a0 = a1
    
check_third:
    # Now a0 = max(a0, a1), compare with a2
    bge a0, a2, done
    mv a0, a2               # a0 = a2
    
done:
    ret

_start:
    li a0, 15
    li a1, 42
    li a2, 28
    call max3
    # a0 = 42
    
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 4</summary>

```asm
# gcd - Greatest Common Divisor (Euclidean algorithm)
# gcd(a, b) = gcd(b, a mod b), base case: gcd(a, 0) = a

gcd:
    # Arguments: a0 = a, a1 = b
    beqz a1, gcd_base       # if b == 0, return a
    
    # Recursive case: gcd(b, a mod b)
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Compute a mod b
    rem t0, a0, a1          # t0 = a mod b
    mv a0, a1               # a = b
    mv a1, t0               # b = a mod b
    call gcd
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

gcd_base:
    ret                     # Return a0

_start:
    li a0, 48
    li a1, 18
    call gcd
    # a0 = 6 (gcd(48, 18))
    
    li a7, 93
    ecall
```
</details>

## Deep Dive: The Stack

The stack grows **downward** (toward lower addresses):

```
High Memory
    |
    |  [Caller's frame]
    |  ← sp (before call)
    |  ----------------
    |  [Return address]
    |  [Saved registers]
    |  [Local variables]
    |  ← sp (in function)
    |
    v
Low Memory
```

### Stack Alignment

RISC-V requires 16-byte stack alignment:
- `sp` must be aligned to 16 bytes
- When allocating, round up to multiple of 16

```asm
# Allocate 12 bytes? Round to 16
addi sp, sp, -16        # Not -12!
```

## Deep Dive: Frame Pointer

Some functions use `s0` as a **frame pointer** (`fp`):

```asm
function:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    addi s0, sp, 16         # fp points to old sp
    
    # Now can use s0 to access frame consistently
    # Even if sp changes
    
    # Restore
    lw ra, -4(s0)
    lw s0, -8(s0)
    addi sp, sp, 16
    ret
```

Benefits:
- Easier debugging
- Consistent access to parameters and locals
- Useful for variable-sized allocations

## Deep Dive: Tail Call Optimization

A **tail call** is when the last thing a function does is call another:

```asm
function_a:
    # ... some work ...
    j function_b            # Tail call (not 'call')
```

Instead of:
```asm
    call function_b
    ret
```

Benefits:
- No stack growth
- Enables recursion in constant space
- Compiler optimization

## Deep Dive: Position Independent Code

For shared libraries, use PC-relative addressing:

```asm
.option pic             # Enable PIC mode

function:
    lla a0, data_label  # Load address PC-relatively
    # Instead of: la a0, data_label
```

## Common Mistakes

### Mistake 1: Not Saving ra
```asm
non_leaf:
    call other_function     # Overwrites ra!
    ret                     # Returns to wrong place!
```

**Fix:** Save and restore `ra`.

### Mistake 2: Stack Imbalance
```asm
function:
    addi sp, sp, -8
    # Oops, forgot to restore!
    ret
```

**Fix:** Always match allocate/deallocate.

### Mistake 3: Wrong Register Class
```asm
function:
    li t0, 100
    call other_function
    # t0 might be clobbered! (caller-saved)
```

**Fix:** Use `s` registers or save `t` registers.

### Mistake 4: Incorrect Argument Passing
```asm
# Want to call func(10, 20, 30)
li a0, 10
li a1, 20
li a3, 30               # WRONG! Should be a2
call func
```

## Key Takeaways

✅ **call/ret** are pseudo-instructions for JAL/JALR

✅ **a0-a7** for arguments and return values

✅ **ra** must be saved in non-leaf functions

✅ **s0-s11** are callee-saved

✅ **t0-t6** are caller-saved

✅ **Stack grows downward** (subtract to allocate)

✅ **Always balance** stack operations

## Next Lesson

Ready for advanced memory concepts? Continue to:
**[Lesson 07: Memory Management →](../07-memory/)**

Learn about alignment, endianness, and memory optimization!

---

## Quick Reference

**Calling Convention:**
```
Arguments:  a0-a7
Returns:    a0-a1
Caller-saved: t0-t6, a0-a7
Callee-saved: s0-s11, ra, sp
```

**Function Template:**
```asm
function:
    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    # Body
    # ...
    
    # Epilogue
    lw ra, 12(sp)
    lw s0, 8(sp)
    addi sp, sp, 16
    ret
```

**Call and Return:**
```asm
call label              # jal ra, label
ret                     # jalr zero, ra, 0
```

---

*Functions make code reusable and maintainable!* 📦
