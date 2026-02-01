# RISC-V Calling Conventions

The RISC-V calling convention (Application Binary Interface - ABI) defines how functions interact.

## Quick Reference

### Register Usage
- **a0-a7**: Arguments and return values
- **t0-t6**: Temporary (caller-saved)
- **s0-s11**: Saved (callee-saved)
- **ra**: Return address
- **sp**: Stack pointer

### Caller Responsibilities
1. Save any needed `t` and `a` registers
2. Place arguments in `a0-a7` (extras on stack)
3. Call with `jal ra, function`
4. Result in `a0` (and `a1` for 64-bit values)

### Callee Responsibilities
1. Save `ra` if calling other functions
2. Save any `s` registers you'll use
3. Preserve `sp`
4. Place return value in `a0` (and `a1`)
5. Restore saved registers
6. Return with `ret`

## Detailed Calling Convention

### Integer Calling Convention

#### Argument Passing

**First 8 arguments** go in registers `a0-a7`:

```assembly
# Call: result = func(1, 2, 3, 4, 5, 6, 7, 8)
li a0, 1
li a1, 2
li a2, 3
li a3, 4
li a4, 5
li a5, 6
li a6, 7
li a7, 8
jal ra, func
```

**More than 8 arguments** go on the stack:

```assembly
# Call: func(a0, a1, a2, a3, a4, a5, a6, a7, arg9, arg10)

# Push extra arguments on stack (in reverse order)
addi sp, sp, -8
li t0, 10
sw t0, 4(sp)          # arg10
li t0, 9
sw t0, 0(sp)          # arg9

# Load register arguments
li a0, 1
li a1, 2
# ... a2-a7 ...
li a7, 8

jal ra, func

# Clean up stack
addi sp, sp, 8
```

#### Return Values

**Single return value**: Use `a0`

```assembly
function:
    li a0, 42         # Return 42
    ret
```

**Two return values**: Use `a0` and `a1`

```assembly
# Return quotient and remainder
divide:
    div a0, a0, a1    # Quotient in a0
    rem a1, a0, a1    # Remainder in a1
    ret
```

**Larger values**: Return pointer in `a0`

```assembly
# Return struct by pointer
get_point:
    la a0, point_data # Return pointer to struct
    ret
```

### Stack Frame Layout

Standard stack frame (grows downward):

```
High addresses
+------------------+
| Argument 9       | ← sp + offset (at call time)
| Argument 10      |
| ...              |
+------------------+
| Return address   | ← Saved by caller
+------------------+
| Saved s registers| ← Current function's frame
| Local variables  |
| Spill slots      |
+------------------+ ← sp (current)
Low addresses
```

### Function Prologue and Epilogue

#### Leaf Function (No Calls)

Simple function that doesn't call others:

```assembly
# int add(int a, int b)
add:
    # No prologue needed - no calls, no s registers
    add a0, a0, a1
    ret
```

#### Non-Leaf Function (Makes Calls)

Function that calls other functions:

```assembly
# int factorial(int n)
factorial:
    # Prologue
    addi sp, sp, -8       # Allocate stack space
    sw ra, 4(sp)          # Save return address
    sw s0, 0(sp)          # Save s0
    
    # Base case
    li t0, 1
    ble a0, t0, base_case
    
    # Recursive case
    mv s0, a0             # Save n
    addi a0, a0, -1       # n - 1
    jal ra, factorial     # Call recursively
    mul a0, a0, s0        # n * factorial(n-1)
    j done
    
base_case:
    li a0, 1
    
done:
    # Epilogue
    lw s0, 0(sp)          # Restore s0
    lw ra, 4(sp)          # Restore ra
    addi sp, sp, 8        # Deallocate stack
    ret
```

#### Function Using Local Variables

```assembly
# void process_data(int *array, int len)
process_data:
    # Prologue
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    # Local var at 0(sp)
    
    mv s0, a0             # array
    mv s1, a1             # len
    li s2, 0              # sum
    
    # Use local variable
    li t0, 100
    sw t0, 0(sp)          # Store to local var
    
    # ... function body ...
    
    # Epilogue
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    ret
```

## Register Preservation Rules

### Caller-Saved (Volatile)

These registers **may be modified** by a called function:
- `t0-t6` (temporaries)
- `a0-a7` (arguments/return)
- `ra` (return address - if you call another function)

**If you need their values after a call, save them before calling:**

```assembly
# Save caller-saved registers
addi sp, sp, -8
sw t0, 0(sp)
sw t1, 4(sp)

jal ra, some_function

# Restore
lw t1, 4(sp)
lw t0, 0(sp)
addi sp, sp, 8
```

### Callee-Saved (Non-Volatile)

These registers **must be preserved** by a called function:
- `s0-s11` (saved registers)
- `sp` (stack pointer)

**If you use them, save them in your prologue:**

```assembly
function:
    # Must save s registers we'll use
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    
    # Now we can use s0-s2
    
    # Must restore before returning
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 12
    ret
```

## Common Patterns

### Passing Structures

**Small structs** (≤ 16 bytes): Pass in registers

```c
struct Point { int x, y; };
int distance(struct Point p);
```

```assembly
# Call: distance(point)
lw a0, 0(s0)          # p.x
lw a1, 4(s0)          # p.y
jal ra, distance
```

**Large structs**: Pass pointer

```c
struct LargeData { int data[100]; };
void process(struct LargeData *p);
```

```assembly
la a0, large_data     # Pass address
jal ra, process
```

### Returning Structures

**Small structs** (≤ 16 bytes): Return in registers

```assembly
# Return struct Point { int x, y; }
make_point:
    li a0, 10         # x = 10
    li a1, 20         # y = 20
    ret
```

**Large structs**: Caller provides space, pass pointer

```assembly
# Caller allocates space
addi sp, sp, -100
mv a0, sp             # Pass pointer to space
jal ra, get_large_struct
# Result is at sp
```

### Variable Arguments

For variadic functions (like printf), named arguments go in registers, rest on stack:

```assembly
# printf(format, arg1, arg2, ...)
la a0, format         # format string
li a1, 42             # arg1
li a2, 100            # arg2
# More args would go on stack
jal ra, printf
```

## Stack Alignment

**Stack must be 16-byte aligned** at function call boundaries (for compatibility and performance).

```assembly
# Wrong: misaligned stack
addi sp, sp, -12      # Not 16-byte aligned!

# Correct: aligned stack
addi sp, sp, -16      # Aligned to 16 bytes
```

## Tail Call Optimization

A **tail call** is a call at the end of a function. Can be optimized:

### Without Optimization (Regular Call)

```assembly
function_a:
    # ... do work ...
    jal ra, function_b    # Call
    ret                   # Return
```

### With Tail Call Optimization

```assembly
function_a:
    # ... do work ...
    j function_b          # Jump instead of call
    # function_b will return directly to our caller
```

**Requirements for tail call:**
- Must be last operation
- No stack cleanup needed
- Arguments already in place

## Position-Independent Code (PIC)

For shared libraries, use PC-relative addressing:

```assembly
# Load global variable address (PIC)
.option pic
auipc a0, %pcrel_hi(global_var)
addi a0, a0, %pcrel_lo(global_var)
lw t0, 0(a0)

# Load function address (PIC)
auipc a0, %pcrel_hi(function)
addi a0, a0, %pcrel_lo(function)
jalr ra, 0(a0)
```

## Floating-Point Convention

With F/D extensions:

### FP Argument Passing
- `fa0-fa7`: FP arguments/return values
- `ft0-ft11`: FP temporaries (caller-saved)
- `fs0-fs11`: FP saved (callee-saved)

### Mixed Integer/FP Arguments

```assembly
# double func(int a, double b, int c, double d)
# a → a0, b → fa0, c → a1, d → fa1
```

## Complete Example

```assembly
# int sum_array(int *array, int length)
sum_array:
    # Prologue
    addi sp, sp, -12
    sw ra, 8(sp)          # Save ra (will call other functions)
    sw s0, 4(sp)          # Save s0 (array pointer)
    sw s1, 0(sp)          # Save s1 (sum)
    
    # Initialize
    mv s0, a0             # s0 = array
    li s1, 0              # sum = 0
    li t0, 0              # i = 0
    
loop:
    bge t0, a1, done      # if i >= length, done
    
    # Load array[i]
    slli t1, t0, 2        # t1 = i * 4
    add t2, s0, t1        # t2 = &array[i]
    lw t3, 0(t2)          # t3 = array[i]
    
    # Add to sum
    add s1, s1, t3
    
    # i++
    addi t0, t0, 1
    j loop
    
done:
    # Return sum
    mv a0, s1
    
    # Epilogue
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret

# Example call:
main:
    la a0, my_array
    li a1, 10
    jal ra, sum_array     # Result in a0
    ret
```

## Key Takeaways

1. **First 8 args in a0-a7**, rest on stack
2. **Return in a0** (and a1 for pairs)
3. **Save ra** if calling functions
4. **Save s0-s11** if using them
5. **Preserve sp** (stack pointer)
6. **16-byte stack alignment** at calls
7. **Temporaries (t0-t6)** not preserved across calls

## Resources

- [RISC-V Calling Convention Spec](https://github.com/riscv/riscv-elf-psabi-doc)
- [Register Reference](./registers.md)
- [Example: Function Calls](../examples/functions.s)

---

*Following calling conventions ensures your code works with compilers and libraries!*
