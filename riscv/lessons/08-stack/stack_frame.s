# stack_frame.s - Advanced stack frame management
# Demonstrates complex stack frames and nested calls

.section .text
.globl _start

_start:
    # Initialize and call main
    call main
    
    # Exit with result from main
    li a7, 93
    ecall

# Main function - orchestrates testing
main:
    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)               # Will hold sum of results
    sw s1, 20(sp)
    sw s2, 16(sp)
    
    # Initialize accumulator
    li s0, 0
    
    # Test 1: Simple computation
    li a0, 15
    li a1, 25
    call add_and_double
    add s0, s0, a0              # Add result to accumulator
    
    # Test 2: Nested computation
    li a0, 5
    li a1, 3
    call compute_expression
    add s0, s0, a0
    
    # Test 3: Fibonacci (recursive)
    li a0, 10
    call fibonacci
    add s0, s0, a0
    
    # Test 4: Complex nested calls
    li a0, 4
    call factorial_times_fib
    add s0, s0, a0
    
    # Return total
    mv a0, s0
    
    # Epilogue
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

# Function: add_and_double
# Computes: (a + b) * 2
# Input: a0 = a, a1 = b
# Output: a0 = result
add_and_double:
    # No calls, no need to save ra
    add a0, a0, a1
    slli a0, a0, 1              # Multiply by 2 (shift left 1)
    ret

# Function: compute_expression
# Computes: (a + b) * (a - b)
# Input: a0 = a, a1 = b
# Output: a0 = result
compute_expression:
    # Prologue
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    
    # Save inputs
    mv s0, a0
    mv s1, a1
    
    # Compute a + b
    add t0, s0, s1
    
    # Compute a - b
    sub t1, s0, s1
    
    # Multiply
    mul a0, t0, t1
    
    # Epilogue
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

# Function: fibonacci
# Recursive fibonacci computation
# Input: a0 = n
# Output: a0 = fib(n)
fibonacci:
    # Base case: fib(0) = 0
    beqz a0, fib_zero
    
    # Base case: fib(1) = 1
    li t0, 1
    beq a0, t0, fib_one
    
    # Recursive case
    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0                   # Save n
    
    # Compute fib(n-1)
    addi a0, s0, -1
    call fibonacci
    mv s1, a0                   # Save fib(n-1)
    
    # Compute fib(n-2)
    addi a0, s0, -2
    call fibonacci
    
    # Return fib(n-1) + fib(n-2)
    add a0, s1, a0
    
    # Epilogue
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

fib_zero:
    li a0, 0
    ret

fib_one:
    li a0, 1
    ret

# Function: factorial_times_fib
# Computes: factorial(n) * fibonacci(n)
# Demonstrates nested function calls
# Input: a0 = n
# Output: a0 = result
factorial_times_fib:
    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0                   # Save n
    
    # Compute factorial(n)
    call factorial_iterative
    mv s1, a0                   # Save factorial result
    
    # Compute fibonacci(n)
    mv a0, s0                   # Restore n
    call fibonacci
    
    # Multiply results
    mul a0, s1, a0
    
    # Epilogue
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Function: factorial_iterative
# Iterative factorial (non-recursive)
# Input: a0 = n
# Output: a0 = n!
factorial_iterative:
    # Prologue
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    
    li s0, 1                    # result = 1
    li s1, 1                    # counter = 1
    
    # Handle n <= 1
    li t0, 2
    blt a0, t0, fact_iter_done
    
fact_iter_loop:
    bgt s1, a0, fact_iter_done
    mul s0, s0, s1
    addi s1, s1, 1
    j fact_iter_loop
    
fact_iter_done:
    mv a0, s0
    
    # Epilogue
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

# Function: sum_of_squares
# Computes: a^2 + b^2 + c^2
# Demonstrates multiple local variables
# Input: a0 = a, a1 = b, a2 = c
# Output: a0 = result
sum_of_squares:
    # Prologue with local variables
    # 16 bytes for saves + 16 for locals
    addi sp, sp, -32
    sw s0, 28(sp)
    sw s1, 24(sp)
    
    # Local variables:
    # a_squared at 12(sp)
    # b_squared at 8(sp)
    # c_squared at 4(sp)
    
    # Compute a^2
    mul t0, a0, a0
    sw t0, 12(sp)
    
    # Compute b^2
    mul t0, a1, a1
    sw t0, 8(sp)
    
    # Compute c^2
    mul t0, a2, a2
    sw t0, 4(sp)
    
    # Sum all squares
    lw t0, 12(sp)
    lw t1, 8(sp)
    lw t2, 4(sp)
    add t0, t0, t1
    add a0, t0, t2
    
    # Epilogue
    lw s1, 24(sp)
    lw s0, 28(sp)
    addi sp, sp, 32
    ret
