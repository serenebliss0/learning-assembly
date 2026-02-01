# RISC-V Function Call Examples
# Demonstrates calling conventions and stack usage

.data
msg1:    .string "Calling add_two_numbers(5, 7)..."
msg2:    .string "\nResult: "
msg3:    .string "\n\nCalling factorial(5)..."
msg4:    .string "\n\nCalling fibonacci(7)..."
newline: .string "\n"

.text
.globl main

main:
    # ========================================
    # Example 1: Simple function call
    # ========================================
    la a0, msg1
    li a7, 4
    ecall
    
    li a0, 5
    li a1, 7
    jal ra, add_two_numbers
    
    mv s0, a0             # Save result
    la a0, msg2
    li a7, 4
    ecall
    mv a0, s0
    li a7, 1
    ecall
    
    # ========================================
    # Example 2: Recursive function (factorial)
    # ========================================
    la a0, msg3
    li a7, 4
    ecall
    
    li a0, 5
    jal ra, factorial
    
    mv s0, a0
    la a0, msg2
    li a7, 4
    ecall
    mv a0, s0
    li a7, 1
    ecall
    
    # ========================================
    # Example 3: Recursive function (fibonacci)
    # ========================================
    la a0, msg4
    li a7, 4
    ecall
    
    li a0, 7
    jal ra, fibonacci
    
    mv s0, a0
    la a0, msg2
    li a7, 4
    ecall
    mv a0, s0
    li a7, 1
    ecall
    
    la a0, newline
    li a7, 4
    ecall
    
    # Exit
    li a7, 10
    ecall

# ========================================
# Function: add_two_numbers
# Simple non-leaf function
# Input: a0 = first number, a1 = second number
# Output: a0 = sum
# ========================================
add_two_numbers:
    # This is a leaf function (doesn't call others)
    # No need to save ra or other registers
    add a0, a0, a1
    ret

# ========================================
# Function: factorial
# Recursive function to calculate n!
# Input: a0 = n
# Output: a0 = n!
# ========================================
factorial:
    # Base case: if n <= 1, return 1
    li t0, 1
    ble a0, t0, factorial_base
    
    # Recursive case: n * factorial(n-1)
    # Save ra and argument on stack
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)
    
    # Call factorial(n-1)
    addi a0, a0, -1
    jal ra, factorial
    
    # Restore argument and multiply
    lw t0, 4(sp)
    mul a0, a0, t0
    
    # Restore ra and return
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

factorial_base:
    li a0, 1
    ret

# ========================================
# Function: fibonacci
# Recursive function to calculate Fib(n)
# Input: a0 = n
# Output: a0 = Fib(n)
# ========================================
fibonacci:
    # Base cases: Fib(0) = 0, Fib(1) = 1
    beqz a0, fib_zero
    li t0, 1
    beq a0, t0, fib_one
    
    # Recursive case: Fib(n-1) + Fib(n-2)
    # Save ra, argument, and s registers
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    # Calculate Fib(n-1)
    mv s0, a0
    addi a0, a0, -1
    jal ra, fibonacci
    mv s1, a0             # s1 = Fib(n-1)
    
    # Calculate Fib(n-2)
    addi a0, s0, -2
    jal ra, fibonacci
    
    # Add results
    add a0, a0, s1        # a0 = Fib(n-2) + Fib(n-1)
    
    # Restore and return
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12
    ret

fib_zero:
    li a0, 0
    ret

fib_one:
    li a0, 1
    ret

# ========================================
# Function: max_of_three
# Returns maximum of three numbers
# Input: a0, a1, a2 = three numbers
# Output: a0 = maximum
# ========================================
max_of_three:
    # Compare a0 and a1
    bge a0, a1, check_a0_a2
    mv a0, a1             # a0 = max(a0, a1)
    
check_a0_a2:
    # Compare current max with a2
    bge a0, a2, max_done
    mv a0, a2
    
max_done:
    ret

# ========================================
# Function: swap_values
# Swaps two values in memory
# Input: a0 = address of first value
#        a1 = address of second value
# Output: values swapped
# ========================================
swap_values:
    lw t0, 0(a0)          # Load first value
    lw t1, 0(a1)          # Load second value
    sw t1, 0(a0)          # Store second at first
    sw t0, 0(a1)          # Store first at second
    ret

# ========================================
# RISC-V Calling Convention Summary
# ========================================
# a0-a7: Arguments and return values
# t0-t6: Temporary (caller-saved)
# s0-s11: Saved (callee-saved)
# ra: Return address
# sp: Stack pointer
#
# Caller responsibilities:
# - Save t0-t6, a0-a7 if needed after call
# - Pass arguments in a0-a7
# - Call function with jal
#
# Callee responsibilities:
# - Save ra if calling other functions
# - Save s0-s11 if using them
# - Restore saved registers before ret
# - Place return value in a0 (and a1 if needed)
