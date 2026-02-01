# RISC-V Calculator
# A simple command-line calculator supporting +, -, *, /, %

.data
prompt1:    .string "Enter first number: "
prompt2:    .string "Enter operator (+, -, *, /, %): "
prompt3:    .string "Enter second number: "
result_msg: .string "Result: "
newline:    .string "\n"
div_zero:   .string "Error: Division by zero!\n"
invalid_op: .string "Error: Invalid operator!\n"
buffer:     .space 16        # Buffer for input

.text
.globl main

main:
    # Prompt for first number
    la a0, prompt1
    li a7, 4              # print_string syscall
    ecall
    
    # Read first number
    jal ra, read_int
    mv s0, a0             # Save first number in s0
    
    # Prompt for operator
    la a0, prompt2
    li a7, 4
    ecall
    
    # Read operator (single character)
    li a7, 12             # read_char syscall
    ecall
    mv s1, a0             # Save operator in s1
    
    # Prompt for second number
    la a0, prompt3
    li a7, 4
    ecall
    
    # Read second number
    jal ra, read_int
    mv s2, a0             # Save second number in s2
    
    # Perform operation based on operator
    mv a0, s0             # First operand
    mv a1, s2             # Second operand
    mv a2, s1             # Operator
    jal ra, calculate
    
    # Check for error (a0 = -1 indicates error)
    li t0, -1
    beq a0, t0, error_occurred
    
    # Print result
    mv s3, a0             # Save result
    la a0, result_msg
    li a7, 4
    ecall
    
    mv a0, s3
    li a7, 1              # print_int syscall
    ecall
    
    # Print newline
    la a0, newline
    li a7, 4
    ecall
    
    # Exit
    li a7, 10
    ecall

error_occurred:
    # Error message already printed by calculate function
    li a7, 10
    ecall

# Function: calculate
# Performs arithmetic operation based on operator
# Input: a0 = num1, a1 = num2, a2 = operator
# Output: a0 = result or -1 on error
calculate:
    # Check operator
    li t0, '+'
    beq a2, t0, do_add
    
    li t0, '-'
    beq a2, t0, do_sub
    
    li t0, '*'
    beq a2, t0, do_mul
    
    li t0, '/'
    beq a2, t0, do_div
    
    li t0, '%'
    beq a2, t0, do_mod
    
    # Invalid operator
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, invalid_op
    li a7, 4
    ecall
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

do_add:
    add a0, a0, a1
    ret

do_sub:
    sub a0, a0, a1
    ret

do_mul:
    mul a0, a0, a1
    ret

do_div:
    # Check for division by zero
    bnez a1, div_ok
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, div_zero
    li a7, 4
    ecall
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret
div_ok:
    div a0, a0, a1
    ret

do_mod:
    # Check for division by zero
    bnez a1, mod_ok
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, div_zero
    li a7, 4
    ecall
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret
mod_ok:
    rem a0, a0, a1
    ret

# Function: read_int
# Reads an integer from stdin
# Output: a0 = integer value
read_int:
    li a7, 5              # read_int syscall
    ecall
    ret
