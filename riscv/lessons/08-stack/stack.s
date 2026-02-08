# stack.s - Stack operations and management demonstration

.section .text
.globl _start

_start:
    # Test 1: Basic push/pop operations
    li t0, 42
    li t1, 100
    li t2, 255
    
    # Push three values
    addi sp, sp, -16            # Allocate (16-byte aligned)
    sw t0, 12(sp)
    sw t1, 8(sp)
    sw t2, 4(sp)
    
    # Modify registers
    li t0, 0
    li t1, 0
    li t2, 0
    
    # Pop three values
    lw t2, 4(sp)
    lw t1, 8(sp)
    lw t0, 12(sp)
    addi sp, sp, 16
    # t0=42, t1=100, t2=255
    
    # Test 2: Function call with stack
    li a0, 5
    call factorial
    mv s0, a0                   # s0 = 120
    
    # Test 3: Nested function calls
    li a0, 10
    li a1, 3
    call power
    mv s1, a0                   # s1 = 1000
    
    # Test 4: Local variables on stack
    call test_locals
    
    # Test 5: Multiple saved registers
    li s2, 11
    li s3, 22
    li s4, 33
    call save_many_registers
    # s2, s3, s4 preserved
    
    # Exit with factorial result
    mv a0, s0
    li a7, 93
    ecall

# Function: factorial
# Compute n! iteratively using stack for saved registers
# Input: a0 = n
# Output: a0 = n!
factorial:
    # Prologue - save registers we'll use
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    # Initialize
    li s0, 1                    # result = 1
    li s1, 1                    # counter = 1
    
    # Handle n = 0 or n = 1
    li t0, 2
    blt a0, t0, fact_done
    
fact_loop:
    bgt s1, a0, fact_done
    mul s0, s0, s1              # result *= counter
    addi s1, s1, 1
    j fact_loop
    
fact_done:
    mv a0, s0                   # Return result
    
    # Epilogue - restore registers
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Function: power
# Compute base^exponent recursively
# Input: a0 = base, a1 = exponent
# Output: a0 = result
power:
    # Base case: x^0 = 1
    beqz a1, power_base
    
    # Base case: x^1 = x
    li t0, 1
    beq a1, t0, power_one
    
    # Recursive case: x^n = x * x^(n-1)
    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0                   # Save base
    mv s1, a1                   # Save exponent
    
    # Compute base^(exponent-1)
    addi a1, s1, -1
    call power
    
    # Multiply by base
    mul a0, a0, s0
    
    # Epilogue
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

power_base:
    li a0, 1
    ret

power_one:
    ret                         # Already in a0

# Function: test_locals
# Demonstrates local variable usage on stack
test_locals:
    # Allocate frame: 16 bytes for saves + 16 for locals
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    
    # Local variables:
    # var1 at 12(sp)
    # var2 at 8(sp)
    # var3 at 4(sp)
    
    # Initialize local variables
    li t0, 10
    sw t0, 12(sp)               # var1 = 10
    
    li t0, 20
    sw t0, 8(sp)                # var2 = 20
    
    # Compute var3 = var1 + var2
    lw t0, 12(sp)
    lw t1, 8(sp)
    add t2, t0, t1
    sw t2, 4(sp)                # var3 = 30
    
    # Use local variables
    lw t0, 4(sp)
    lw t1, 8(sp)
    mul s0, t0, t1              # s0 = var3 * var2 = 600
    
    # Could call other functions here, locals are preserved
    # call other_function
    
    # Clean up
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

# Function: save_many_registers
# Example of saving multiple registers
# Uses s2, s3, s4 but preserves them
save_many_registers:
    # Prologue - save multiple registers
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    
    # Use saved registers
    li s0, 100
    li s1, 200
    add s2, s0, s1              # s2 = 300
    mul s3, s2, s0              # s3 = 30000
    sub s4, s3, s1              # s4 = 29800
    
    # Epilogue - restore in reverse order
    lw s4, 8(sp)
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret
