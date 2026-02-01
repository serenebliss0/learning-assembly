# RISC-V Register Reference

Complete guide to RISC-V register conventions and usage.

## Register Overview

RISC-V has 32 general-purpose integer registers (x0-x31). Each is 32 bits in RV32 or 64 bits in RV64.

## Register Table

| Register | ABI Name | Description | Saver | Preserved Across Calls? |
|----------|----------|-------------|-------|------------------------|
| x0 | zero | Hard-wired zero | - | N/A |
| x1 | ra | Return address | Caller | No |
| x2 | sp | Stack pointer | Callee | Yes |
| x3 | gp | Global pointer | - | N/A |
| x4 | tp | Thread pointer | - | N/A |
| x5 | t0 | Temporary 0 | Caller | No |
| x6 | t1 | Temporary 1 | Caller | No |
| x7 | t2 | Temporary 2 | Caller | No |
| x8 | s0/fp | Saved register 0 / Frame pointer | Callee | Yes |
| x9 | s1 | Saved register 1 | Callee | Yes |
| x10 | a0 | Argument 0 / Return value 0 | Caller | No |
| x11 | a1 | Argument 1 / Return value 1 | Caller | No |
| x12 | a2 | Argument 2 | Caller | No |
| x13 | a3 | Argument 3 | Caller | No |
| x14 | a4 | Argument 4 | Caller | No |
| x15 | a5 | Argument 5 | Caller | No |
| x16 | a6 | Argument 6 | Caller | No |
| x17 | a7 | Argument 7 / Syscall number | Caller | No |
| x18 | s2 | Saved register 2 | Callee | Yes |
| x19 | s3 | Saved register 3 | Callee | Yes |
| x20 | s4 | Saved register 4 | Callee | Yes |
| x21 | s5 | Saved register 5 | Callee | Yes |
| x22 | s6 | Saved register 6 | Callee | Yes |
| x23 | s7 | Saved register 7 | Callee | Yes |
| x24 | s8 | Saved register 8 | Callee | Yes |
| x25 | s9 | Saved register 9 | Callee | Yes |
| x26 | s10 | Saved register 10 | Callee | Yes |
| x27 | s11 | Saved register 11 | Callee | Yes |
| x28 | t3 | Temporary 3 | Caller | No |
| x29 | t4 | Temporary 4 | Caller | No |
| x30 | t5 | Temporary 5 | Caller | No |
| x31 | t6 | Temporary 6 | Caller | No |

## Register Categories

### Special Registers

#### zero (x0)
- **Always reads as 0**
- **Writes are ignored/discarded**
- **Usage**: Discarding results, providing zero constant
- **Examples**:
  ```assembly
  add t0, t1, zero    # Copy t1 to t0 (same as mv t0, t1)
  beq a0, zero, skip  # Branch if a0 == 0
  addi zero, t0, 5    # No-op (writes to zero are ignored)
  ```

#### ra (x1) - Return Address
- **Holds return address for function calls**
- **Set by `jal` and `jalr` instructions**
- **Usage**: Function returns
- **Examples**:
  ```assembly
  jal ra, function    # Call function, ra = PC + 4
  jalr zero, 0(ra)    # Return to caller (same as ret)
  ```

#### sp (x2) - Stack Pointer
- **Points to top of stack**
- **Grows downward** (toward lower addresses)
- **Must be preserved** across function calls
- **Examples**:
  ```assembly
  addi sp, sp, -16    # Allocate 16 bytes
  sw ra, 0(sp)        # Save return address
  lw ra, 0(sp)        # Restore return address
  addi sp, sp, 16     # Deallocate
  ```

#### gp (x3) - Global Pointer
- **Points to global data**
- **Set by linker/startup code**
- **Don't modify** in user code
- **Usage**: Accessing global variables efficiently

#### tp (x4) - Thread Pointer
- **Points to thread-local storage**
- **Set by OS/runtime**
- **Don't modify** in user code
- **Usage**: Thread-local variables

### Temporary Registers (Caller-Saved)

#### t0-t6 (x5-x7, x28-x31)
- **Temporary/scratch registers**
- **Not preserved** across function calls
- **Caller must save** if needed after call
- **Usage**: Temporary calculations, loop counters
- **Examples**:
  ```assembly
  li t0, 10           # Use freely
  jal ra, func        # t0 may be destroyed
  # Don't expect t0 to have same value here!
  ```

### Saved Registers (Callee-Saved)

#### s0-s11 (x8-x9, x18-x27)
- **Saved/preserved registers**
- **Must be preserved** across function calls
- **Callee must save/restore** if used
- **Usage**: Long-lived values, loop invariants
- **Examples**:
  ```assembly
  function:
      addi sp, sp, -8
      sw s0, 0(sp)      # Save s0
      sw s1, 4(sp)      # Save s1
      
      # Use s0, s1 freely
      
      lw s1, 4(sp)      # Restore s1
      lw s0, 0(sp)      # Restore s0
      addi sp, sp, 8
      ret
  ```

#### s0/fp (x8) - Frame Pointer
- **Can be used as frame pointer**
- **Points to base of current stack frame**
- **Optional**: Not required in all functions
- **Usage**: Debugging, accessing local variables

### Argument/Return Registers

#### a0-a7 (x10-x17)
- **Function arguments** (first 8)
- **a0, a1**: Also used for **return values**
- **Not preserved** across calls
- **Examples**:
  ```assembly
  # Calling: result = add(5, 3)
  li a0, 5            # First argument
  li a1, 3            # Second argument
  jal ra, add
  mv t0, a0           # Save return value
  
  # Function definition:
  add:
      add a0, a0, a1  # Return in a0
      ret
  ```

#### a7 (x17) - Syscall Number
- **Also used for syscall number** in system calls
- **Examples**:
  ```assembly
  li a7, 64           # write syscall
  ecall
  ```

## Register Usage Guidelines

### General Rules

1. **Always preserve callee-saved registers (s0-s11, sp)**
2. **Assume caller-saved registers (t0-t6, a0-a7) are destroyed after calls**
3. **Never write to x0 (zero), gp, or tp**
4. **Save ra if calling other functions**

### Function Prologue/Epilogue

**Leaf function** (doesn't call others):
```assembly
# No prologue needed if not using s registers
function:
    add a0, a0, a1
    ret
```

**Non-leaf function** (calls others):
```assembly
function:
    # Prologue
    addi sp, sp, -16      # Allocate stack
    sw ra, 0(sp)          # Save return address
    sw s0, 4(sp)          # Save s0 if using it
    
    # Function body
    # ... use registers ...
    jal ra, other_func
    
    # Epilogue
    lw s0, 4(sp)          # Restore s0
    lw ra, 0(sp)          # Restore ra
    addi sp, sp, 16       # Deallocate stack
    ret
```

### Choosing Registers

**For temporary values:**
- Use t0-t6 (don't need to save)
- Good for: loop counters, temporary calculations

**For values that survive function calls:**
- Use s0-s11 (must save/restore)
- Good for: variables used across multiple function calls

**For passing arguments:**
- Use a0-a7 in order
- More than 8 arguments? Pass on stack

**For return values:**
- Use a0 (single value)
- Use a0, a1 (two values, e.g., 64-bit result on RV32)

## Register Allocation Strategy

### Example: Complex Function

```assembly
# Function: calculate_stats(array, length)
# Returns: sum in a0, max in a1
calculate_stats:
    # Prologue: save callee-saved registers
    addi sp, sp, -16
    sw s0, 0(sp)          # s0 = array pointer
    sw s1, 4(sp)          # s1 = length
    sw s2, 8(sp)          # s2 = sum
    sw s3, 12(sp)         # s3 = max
    
    mv s0, a0             # Save array pointer
    mv s1, a1             # Save length
    li s2, 0              # sum = 0
    lw s3, 0(s0)          # max = array[0]
    
    li t0, 0              # i = 0 (temporary counter)
loop:
    bge t0, s1, done
    
    slli t1, t0, 2        # t1 = i * 4 (temporary)
    add t2, s0, t1        # t2 = &array[i] (temporary)
    lw t3, 0(t2)          # t3 = array[i] (temporary)
    
    add s2, s2, t3        # sum += array[i]
    
    ble t3, s3, skip_max
    mv s3, t3             # Update max
skip_max:
    
    addi t0, t0, 1
    j loop
    
done:
    # Prepare return values
    mv a0, s2             # Return sum in a0
    mv a1, s3             # Return max in a1
    
    # Epilogue: restore registers
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 16
    ret
```

## Common Mistakes

### ❌ Wrong: Not saving callee-saved registers
```assembly
function:
    mv s0, a0         # WRONG: s0 not saved!
    jal ra, other
    mv a0, s0
    ret               # Corrupted s0!
```

### ✅ Correct: Saving callee-saved registers
```assembly
function:
    addi sp, sp, -4
    sw s0, 0(sp)      # Save s0
    mv s0, a0
    jal ra, other
    mv a0, s0
    lw s0, 0(sp)      # Restore s0
    addi sp, sp, 4
    ret
```

### ❌ Wrong: Assuming t registers survive calls
```assembly
li t0, 10
jal ra, function      # t0 is destroyed!
add a0, t0, a1        # WRONG: t0 may be corrupted
```

### ✅ Correct: Save in s register or stack
```assembly
li s0, 10             # Use s register (must save/restore)
jal ra, function
add a0, s0, a1        # OK: s0 preserved
```

## Floating-Point Registers

With F/D extensions, there are 32 floating-point registers (f0-f31):

| Register | ABI Name | Description | Saver |
|----------|----------|-------------|-------|
| f0-f7 | ft0-ft7 | FP temporaries | Caller |
| f8-f9 | fs0-fs1 | FP saved | Callee |
| f10-f11 | fa0-fa1 | FP arguments/returns | Caller |
| f12-f17 | fa2-fa7 | FP arguments | Caller |
| f18-f27 | fs2-fs11 | FP saved | Callee |
| f28-f31 | ft8-ft11 | FP temporaries | Caller |

See [Lesson 13: Floating Point](../lessons/13-float/) for details.

## Quick Reference Card

```
Caller-saved (use freely, destroyed by calls):
  t0-t6, a0-a7, ra

Callee-saved (must preserve):
  s0-s11, sp

Special (don't modify):
  zero (always 0), gp, tp

Function arguments: a0-a7
Function returns: a0, a1
Syscall number: a7
```

## Resources

- [RISC-V Calling Convention Spec](https://github.com/riscv/riscv-elf-psabi-doc)
- [Calling Conventions Reference](./calling-conventions.md)
- [RISC-V Register Cheat Sheet](https://github.com/jameslzhu/riscv-card)

---

*Understanding register conventions is crucial for writing correct and efficient RISC-V assembly!*
