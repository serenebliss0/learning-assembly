# Lesson 08: Stack Operations

The stack is one of the most important data structures in assembly programming. It's essential for function calls, local variables, and managing program state.

## Learning Objectives

By the end of this lesson, you'll:
- Master stack pointer (sp) management
- Implement push and pop operations
- Allocate and use local variables
- Create proper stack frames
- Understand recursion and stack usage
- Detect and prevent stack overflow
- Follow stack discipline

## The Stack

The **stack** is a region of memory that grows and shrinks dynamically. In RISC-V:

- **Stack Pointer (sp):** Register `x2` points to the top of the stack
- **Growth Direction:** Stack grows **downward** (toward lower addresses)
- **Operations:** Push (decrease sp), Pop (increase sp)

```
High Memory
    ↑
    |  [Unused stack space]
    |
    |  ← sp (stack pointer)
    |  [Stack data]
    |  [Stack data]
    |  [Stack data]
    ↓
Low Memory
```

## Stack Operations

### Push (Save to Stack)

To push a value onto the stack:
```asm
addi sp, sp, -4             # Allocate 4 bytes
sw t0, 0(sp)                # Store value
```

### Pop (Restore from Stack)

To pop a value from the stack:
```asm
lw t0, 0(sp)                # Load value
addi sp, sp, 4              # Deallocate 4 bytes
```

### Multiple Values

Push multiple registers:
```asm
addi sp, sp, -12            # Allocate 12 bytes (3 words)
sw t0, 8(sp)                # Save t0 at offset 8
sw t1, 4(sp)                # Save t1 at offset 4
sw t2, 0(sp)                # Save t2 at offset 0
```

Pop in reverse order:
```asm
lw t2, 0(sp)                # Restore t2
lw t1, 4(sp)                # Restore t1
lw t0, 8(sp)                # Restore t0
addi sp, sp, 12             # Deallocate 12 bytes
```

## Stack Alignment

RISC-V requires **16-byte stack alignment**. Always adjust sp in multiples of 16:

```asm
# Correct: 16-byte aligned
addi sp, sp, -16            # ✓ Multiple of 16

# Wrong: Not aligned
addi sp, sp, -4             # ✗ Not a multiple of 16
```

When saving an odd number of registers, add padding:
```asm
# Saving 3 registers (12 bytes)
# Need to allocate 16 bytes for alignment
addi sp, sp, -16            # Allocate 16 (not 12!)
sw ra, 12(sp)
sw s0, 8(sp)
sw s1, 4(sp)
# 4 bytes padding at 0(sp)
```

## The Code - Stack Operations

```asm
# stack.s - Stack operations demonstration

.section .data
result_msg:
    .string "Result: "

.section .text
.globl _start

_start:
    # Initialize some values
    li t0, 10
    li t1, 20
    li t2, 30
    
    # Test 1: Push and pop single value
    addi sp, sp, -16            # Allocate (aligned)
    sw t0, 0(sp)                # Push t0
    
    li t0, 99                   # Modify t0
    
    lw t0, 0(sp)                # Pop t0
    addi sp, sp, 16             # Deallocate
    # t0 is back to 10
    
    # Test 2: Push and pop multiple values
    addi sp, sp, -16
    sw t0, 12(sp)               # Push t0
    sw t1, 8(sp)                # Push t1
    sw t2, 4(sp)                # Push t2
    
    # Modify all values
    li t0, 0
    li t1, 0
    li t2, 0
    
    # Restore
    lw t2, 4(sp)
    lw t1, 8(sp)
    lw t0, 12(sp)
    addi sp, sp, 16
    # t0=10, t1=20, t2=30
    
    # Test 3: Call function with stack usage
    li a0, 5
    call factorial
    # a0 = 120
    
    # Test 4: Nested function calls
    li a0, 10
    li a1, 5
    call compute_expression
    mv s0, a0                   # Save result
    
    # Test 5: Allocate local variables
    call use_local_vars
    
    # Exit
    mv a0, s0
    li a7, 93
    ecall

# Function: factorial (iterative with stack)
# Input: a0 = n
# Output: a0 = n!
factorial:
    # Save registers we'll use
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)                # Use s0 for result
    sw s1, 4(sp)                # Use s1 for counter
    
    # Initialize
    li s0, 1                    # result = 1
    li s1, 1                    # counter = 1
    
fact_loop:
    bgt s1, a0, fact_done
    mul s0, s0, s1              # result *= counter
    addi s1, s1, 1
    j fact_loop
    
fact_done:
    mv a0, s0                   # Return result
    
    # Restore and return
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Function: compute_expression
# Computes: (a + b) * (a - b)
# Input: a0 = a, a1 = b
# Output: a0 = result
compute_expression:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    # Compute a + b
    add s0, a0, a1              # s0 = a + b
    
    # Compute a - b
    sub s1, a0, a1              # s1 = a - b
    
    # Multiply
    mul a0, s0, s1              # result = (a+b) * (a-b)
    
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Function: use_local_vars
# Demonstrates local variable allocation
use_local_vars:
    # Allocate stack frame
    # 16 bytes for saved registers + 16 bytes for locals
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    
    # Local variables at sp+0 to sp+16
    # local1 at 12(sp), local2 at 8(sp), local3 at 4(sp)
    
    li t0, 100
    sw t0, 12(sp)               # local1 = 100
    
    li t0, 200
    sw t0, 8(sp)                # local2 = 200
    
    # Compute local3 = local1 + local2
    lw t0, 12(sp)               # Load local1
    lw t1, 8(sp)                # Load local2
    add t2, t0, t1              # Sum
    sw t2, 4(sp)                # local3 = 300
    
    # Use local3
    lw a0, 4(sp)                # a0 = 300
    
    # Clean up
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret
```

## Breaking It Down

### Push Operation

```asm
addi sp, sp, -16            # Move stack pointer down
sw t0, 0(sp)                # Store at top of stack
```

The stack grows **downward**, so we **subtract** to allocate space.

### Pop Operation

```asm
lw t0, 0(sp)                # Load from top of stack
addi sp, sp, 16             # Move stack pointer up
```

We **add** to sp to deallocate space.

### Stack Frame Layout

```asm
addi sp, sp, -32            # Allocate 32 bytes

# Layout:
# sp + 28: saved ra
# sp + 24: saved s0
# sp + 20: (padding/unused)
# sp + 16: (padding/unused)
# sp + 12: local variable 1
# sp +  8: local variable 2
# sp +  4: local variable 3
# sp +  0: (bottom of frame)
```

### Accessing Local Variables

```asm
li t0, 42
sw t0, 12(sp)               # Store local1
lw t1, 12(sp)               # Load local1
```

Use offsets from sp to access local variables.

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 -o stack.o stack.s

# Link
riscv64-unknown-elf-ld -m elf32lriscv -o stack stack.o

# Run
qemu-riscv32 stack
echo $?  # Check exit code

# Or with Spike
spike --isa=RV32IM /path/to/pk stack
```

## The Code - Stack Frames

```asm
# stack_frame.s - Detailed stack frame management

.section .text
.globl _start

_start:
    # Call main function
    call main
    
    # Exit with result
    li a7, 93
    ecall

# Main function - demonstrates nested calls
main:
    # Prologue: set up stack frame
    addi sp, sp, -32
    sw ra, 28(sp)               # Save return address
    sw s0, 24(sp)               # Save frame pointer
    sw s1, 20(sp)               # Save s1
    addi s0, sp, 32             # Set frame pointer (optional)
    
    # Body: call other functions
    li a0, 10
    li a1, 5
    call add_and_square
    mv s1, a0                   # Save result
    
    li a0, 8
    call fibonacci_recursive
    add a0, a0, s1              # Combine results
    
    # Epilogue: tear down stack frame
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

# Function: add_and_square
# Computes: (a + b)^2
# Input: a0 = a, a1 = b
# Output: a0 = result
add_and_square:
    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    # Compute a + b
    add s0, a0, a1
    
    # Square it
    mul a0, s0, s0
    
    # Epilogue
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Function: fibonacci_recursive
# Input: a0 = n
# Output: a0 = fib(n)
fibonacci_recursive:
    # Base cases: fib(0) = 0, fib(1) = 1
    beqz a0, fib_base_0
    li t0, 1
    beq a0, t0, fib_base_1
    
    # Recursive case: fib(n) = fib(n-1) + fib(n-2)
    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0                   # Save n
    
    # Compute fib(n-1)
    addi a0, s0, -1
    call fibonacci_recursive
    mv s1, a0                   # Save fib(n-1)
    
    # Compute fib(n-2)
    addi a0, s0, -2
    call fibonacci_recursive
    
    # Return fib(n-1) + fib(n-2)
    add a0, s1, a0
    
    # Epilogue
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

fib_base_0:
    li a0, 0
    ret

fib_base_1:
    li a0, 1
    ret
```

## Breaking It Down - Stack Frames

### Function Prologue

```asm
addi sp, sp, -32            # Allocate stack frame
sw ra, 28(sp)               # Save return address
sw s0, 24(sp)               # Save callee-saved registers
```

The prologue:
1. Allocates stack space
2. Saves return address (ra)
3. Saves any s-registers we'll use

### Function Body

```asm
li a0, 10
call other_function         # ra is saved, safe to call
mv s0, a0                   # Use saved registers freely
```

In the body:
- Use s-registers for values across calls
- Call other functions safely
- Use local variables via stack offsets

### Function Epilogue

```asm
lw s0, 24(sp)               # Restore saved registers
lw ra, 28(sp)               # Restore return address
addi sp, sp, 32             # Deallocate stack frame
ret                         # Return to caller
```

The epilogue:
1. Restores saved registers (reverse order)
2. Restores return address
3. Deallocates stack space
4. Returns

## Recursion and Stack Usage

Each recursive call creates a new stack frame:

```
Stack during fib(3):

sp → [fib(1) frame]         ← Current call
     [fib(2) frame]
     [fib(3) frame]
     [main frame]
     [...]
```

Each frame contains:
- Return address
- Saved registers
- Local variables
- Parameters (if needed)

### Stack Depth

Deep recursion can exhaust stack space. For fib(10):
- Max depth: ~10 frames
- Frame size: ~16 bytes
- Total: ~160 bytes

For fib(30):
- Max depth: ~30 frames
- Total: ~480 bytes

For fib(1000):
- **Stack overflow!**

## Stack Overflow Prevention

### Check Stack Bounds

```asm
# Check if stack pointer is too low
la t0, stack_limit          # Load minimum stack address
bltu sp, t0, stack_overflow # Check if sp < limit

# Continue normally...

stack_overflow:
    # Handle error
    li a0, -1
    li a7, 93
    ecall
```

### Limit Recursion Depth

```asm
# Fibonacci with depth limit
# a0 = n, a1 = max_depth
fibonacci_safe:
    beqz a1, depth_exceeded     # Check depth limit
    
    # Base cases
    beqz a0, fib_base_0
    li t0, 1
    beq a0, t0, fib_base_1
    
    # Recursive case
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0
    addi a1, a1, -1             # Decrement depth
    
    addi a0, s0, -1
    call fibonacci_safe
    mv s1, a0
    
    addi a0, s0, -2
    # a1 already decremented
    call fibonacci_safe
    
    add a0, s1, a0
    
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

depth_exceeded:
    li a0, -1                   # Error value
    ret
```

## Push/Pop Macros

While RISC-V doesn't have push/pop instructions, we can create patterns:

```asm
# "Push" pattern
addi sp, sp, -4
sw reg, 0(sp)

# "Pop" pattern
lw reg, 0(sp)
addi sp, sp, 4

# Multiple push
addi sp, sp, -16
sw reg1, 12(sp)
sw reg2, 8(sp)
sw reg3, 4(sp)
sw reg4, 0(sp)

# Multiple pop
lw reg4, 0(sp)
lw reg3, 4(sp)
lw reg2, 8(sp)
lw reg1, 12(sp)
addi sp, sp, 16
```

## Experiments to Try

1. **Stack Growth**
   - Print sp at different points
   - Verify stack grows downward
   - Measure frame sizes

2. **Recursive Depth**
   - Call fibonacci with increasing n
   - Observe stack usage
   - Find maximum safe depth

3. **Local Variables**
   - Allocate different amounts
   - Verify variable isolation
   - Test nested scopes

4. **Stack Corruption**
   - Intentionally unbalance stack
   - See what breaks
   - Learn to debug

## Common Stack Patterns

### 1. Leaf Function (No Calls)

```asm
# Leaf function doesn't call others
# No need to save ra
leaf_function:
    # Use t-registers freely (no calls to save them)
    add t0, a0, a1
    mul a0, t0, t0
    ret
```

### 2. Non-Leaf Function

```asm
# Non-leaf makes calls, must save ra
non_leaf:
    addi sp, sp, -16
    sw ra, 12(sp)
    
    call other_function
    
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
```

### 3. Function with Local Variables

```asm
with_locals:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    
    # Local variable space: sp+0 to sp+16
    li t0, 42
    sw t0, 12(sp)               # local1 = 42
    
    lw t0, 12(sp)
    # Use local1...
    
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret
```

### 4. Function with Many Parameters

```asm
# More than 8 parameters use stack
# Parameters 1-8: a0-a7
# Parameters 9+: on stack (passed by caller)
many_params:
    # Access parameter 9
    lw t0, 0(sp)                # First stack parameter
    lw t1, 4(sp)                # Second stack parameter
    
    # Rest of function...
    ret
```

## Exercises

**Exercise 1:** Write a function that computes the sum of an array using the stack to save registers.

**Exercise 2:** Implement a recursive function to compute x^n (power).

**Exercise 3:** Create a function that allocates an array on the stack and initializes it.

**Exercise 4:** Write a stack-checking function that detects overflow.

<details>
<summary>Solution to Exercise 1</summary>

```asm
# sum_array
# Input: a0 = array address, a1 = count
# Output: a0 = sum
sum_array:
    # Prologue
    addi sp, sp, -16
    sw s0, 12(sp)               # Save s0 for sum
    sw s1, 8(sp)                # Save s1 for index
    
    # Initialize
    li s0, 0                    # sum = 0
    li s1, 0                    # index = 0
    
sum_loop:
    bge s1, a1, sum_done        # if index >= count, done
    
    # Load array[index]
    slli t0, s1, 2              # t0 = index * 4
    add t0, a0, t0              # t0 = &array[index]
    lw t1, 0(t0)                # t1 = array[index]
    
    add s0, s0, t1              # sum += array[index]
    addi s1, s1, 1              # index++
    j sum_loop
    
sum_done:
    mv a0, s0                   # Return sum
    
    # Epilogue
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

_start:
    la a0, test_array
    li a1, 5
    call sum_array
    # a0 = sum
    
    li a7, 93
    ecall

.section .data
test_array:
    .word 10, 20, 30, 40, 50    # Sum = 150
```
</details>

<details>
<summary>Solution to Exercise 2</summary>

```asm
# power - Compute x^n recursively
# Input: a0 = x, a1 = n
# Output: a0 = x^n
power:
    # Base case: x^0 = 1
    beqz a1, power_base
    
    # Recursive case: x^n = x * x^(n-1)
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0                   # Save x
    mv s1, a1                   # Save n
    
    # Compute x^(n-1)
    addi a1, s1, -1
    call power
    
    # Multiply by x
    mul a0, a0, s0
    
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

power_base:
    li a0, 1
    ret

_start:
    li a0, 2
    li a1, 10
    call power
    # a0 = 1024 (2^10)
    
    li a7, 93
    ecall
```
</details>

<details>
<summary>Solution to Exercise 3</summary>

```asm
# Function that creates and initializes array on stack
create_array:
    # Allocate space for 10 integers + saved registers
    addi sp, sp, -64            # 40 bytes for array + 24 for saves
    sw ra, 60(sp)
    sw s0, 56(sp)
    
    # Array starts at sp+0
    # Initialize array with values 0-9
    li s0, 0                    # counter
    
init_loop:
    li t0, 10
    bge s0, t0, init_done
    
    # array[i] = i
    slli t1, s0, 2              # t1 = i * 4
    add t1, sp, t1              # t1 = &array[i]
    sw s0, 0(t1)                # array[i] = i
    
    addi s0, s0, 1
    j init_loop
    
init_done:
    # Use the array...
    # Sum the array
    li s0, 0                    # sum = 0
    li t0, 0                    # i = 0
    
sum_loop:
    li t1, 10
    bge t0, t1, sum_done
    
    slli t2, t0, 2
    add t2, sp, t2
    lw t3, 0(t2)
    add s0, s0, t3
    
    addi t0, t0, 1
    j sum_loop
    
sum_done:
    mv a0, s0                   # Return sum
    
    lw s0, 56(sp)
    lw ra, 60(sp)
    addi sp, sp, 64
    ret
```
</details>

## Deep Dive: Frame Pointer

Some conventions use a **frame pointer** (s0/fp):

```asm
function:
    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    addi s0, sp, 32             # fp points to frame base
    
    # Access locals via fp instead of sp
    sw t0, -8(s0)               # Store local variable
    
    # sp can now change, but fp stays constant
    # This is useful for variable-sized allocations
    
    # Epilogue
    lw ra, 28(sp)
    lw s0, 24(sp)
    addi sp, sp, 32
    ret
```

Benefits:
- Locals accessible via constant offsets from fp
- Easier debugging (stable frame reference)
- Allows variable-sized stack allocations

Cost:
- Uses one more register (s0)
- Slightly more instructions

## Common Mistakes

❌ **Forgetting to save ra in non-leaf functions**
```asm
function:
    call other                  # Overwrites ra!
    ret                         # Returns to wrong place!
```

❌ **Unbalanced stack operations**
```asm
function:
    addi sp, sp, -16
    # ... 
    ret                         # Forgot to add sp back!
```

❌ **Not aligning stack**
```asm
addi sp, sp, -4                 # Should be -16!
```

❌ **Pop in wrong order**
```asm
# Push
sw t0, 12(sp)
sw t1, 8(sp)
# Pop (WRONG ORDER!)
lw t0, 8(sp)                    # Gets t1's value!
lw t1, 12(sp)                   # Gets t0's value!
```

❌ **Accessing freed stack space**
```asm
sw t0, 0(sp)
addi sp, sp, 16                 # Deallocate
lw t1, 0(sp)                    # Accessing freed memory!
```

## Key Takeaways

✅ **Stack grows downward** (subtract to allocate)

✅ **Always maintain 16-byte alignment**

✅ **Save ra** in non-leaf functions

✅ **Balance push and pop** operations

✅ **Use s-registers** for values across calls

✅ **Recursion uses stack** (one frame per call)

✅ **Deep recursion** can cause stack overflow

✅ **Prologue/epilogue** are essential patterns

## Next Lesson

Ready to manipulate bits? Continue to:
**[Lesson 09: Bit Manipulation →](../09-bits/)**

Learn shifts, logical operations, and bit tricks!

---

## Quick Reference

**Stack Operations:**
```asm
# Push
addi sp, sp, -16
sw reg, offset(sp)

# Pop
lw reg, offset(sp)
addi sp, sp, 16
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
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
```

**Stack Alignment:**
```asm
# Always multiple of 16
addi sp, sp, -16    # ✓
addi sp, sp, -32    # ✓
addi sp, sp, -4     # ✗
```

---

*Master the stack, master assembly!* 📚
