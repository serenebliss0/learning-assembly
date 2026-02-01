# RISC-V String Library
# Implementation of common string manipulation functions

.data
test_str1:    .string "Hello"
test_str2:    .string "World"
test_str3:    .string "Hello"
test_str4:    .string "HELLO"
test_buffer:  .space 100
newline:      .string "\n"
test_msg1:    .string "Testing strlen: "
test_msg2:    .string "Testing strcpy: "
test_msg3:    .string "Testing strcmp: "
test_msg4:    .string "Testing strcat: "

.text
.globl main

main:
    # Test strlen
    la a0, test_msg1
    jal ra, print_string
    la a0, test_str1
    jal ra, strlen
    jal ra, print_int
    jal ra, print_newline
    
    # Test strcpy
    la a0, test_msg2
    jal ra, print_string
    la a0, test_buffer
    la a1, test_str1
    jal ra, strcpy
    jal ra, print_string
    jal ra, print_newline
    
    # Test strcmp
    la a0, test_msg3
    jal ra, print_string
    la a0, test_str1
    la a1, test_str3
    jal ra, strcmp
    jal ra, print_int
    jal ra, print_newline
    
    # Test strcat
    la a0, test_msg4
    jal ra, print_string
    la a0, test_buffer
    la a1, test_str1
    jal ra, strcpy         # First copy "Hello"
    la a1, test_str2
    jal ra, strcat         # Then concat "World"
    jal ra, print_string
    jal ra, print_newline
    
    # Exit
    li a7, 10
    ecall

# ========================================
# String Library Functions
# ========================================

# Function: strlen
# Calculate length of null-terminated string
# Input: a0 = pointer to string
# Output: a0 = length (excluding null terminator)
strlen:
    mv t0, a0             # Save original pointer
    li a0, 0              # Counter = 0
strlen_loop:
    lbu t1, 0(t0)         # Load byte
    beqz t1, strlen_done  # If null, done
    addi a0, a0, 1        # Increment counter
    addi t0, t0, 1        # Next character
    j strlen_loop
strlen_done:
    ret

# Function: strcpy
# Copy string from source to destination
# Input: a0 = destination, a1 = source
# Output: a0 = pointer to destination
strcpy:
    mv t0, a0             # Save dest pointer
strcpy_loop:
    lbu t1, 0(a1)         # Load from source
    sb t1, 0(a0)          # Store to dest
    beqz t1, strcpy_done  # If null, done
    addi a0, a0, 1
    addi a1, a1, 1
    j strcpy_loop
strcpy_done:
    mv a0, t0             # Return original dest
    ret

# Function: strcmp
# Compare two strings lexicographically
# Input: a0 = string1, a1 = string2
# Output: a0 = 0 if equal, <0 if s1<s2, >0 if s1>s2
strcmp:
strcmp_loop:
    lbu t0, 0(a0)         # Load from s1
    lbu t1, 0(a1)         # Load from s2
    bne t0, t1, strcmp_diff # Different characters
    beqz t0, strcmp_equal  # Both null = equal
    addi a0, a0, 1
    addi a1, a1, 1
    j strcmp_loop
strcmp_diff:
    sub a0, t0, t1        # Return difference
    ret
strcmp_equal:
    li a0, 0              # Return 0 (equal)
    ret

# Function: strcat
# Concatenate source string to destination
# Input: a0 = destination, a1 = source
# Output: a0 = pointer to destination
# Note: Destination must have enough space!
strcat:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    
    mv s0, a0             # Save original dest
    mv s1, a1             # Save source
    
    # Find end of destination
strcat_find_end:
    lbu t0, 0(a0)
    beqz t0, strcat_copy
    addi a0, a0, 1
    j strcat_find_end
    
    # Copy source to end
strcat_copy:
    lbu t1, 0(s1)
    sb t1, 0(a0)
    beqz t1, strcat_done
    addi a0, a0, 1
    addi s1, s1, 1
    j strcat_copy
    
strcat_done:
    mv a0, s0             # Return original dest
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8
    ret

# Function: strchr
# Find first occurrence of character in string
# Input: a0 = string, a1 = character to find
# Output: a0 = pointer to character or NULL (0)
strchr:
strchr_loop:
    lbu t0, 0(a0)
    beq t0, a1, strchr_found
    beqz t0, strchr_notfound
    addi a0, a0, 1
    j strchr_loop
strchr_found:
    ret                   # a0 already points to char
strchr_notfound:
    li a0, 0              # Return NULL
    ret

# Function: strrev
# Reverse a string in place
# Input: a0 = pointer to string
# Output: a0 = pointer to string (same)
strrev:
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
    
    mv s0, a0             # Save pointer
    
    # Get length
    jal ra, strlen
    mv s1, a0             # s1 = length
    
    # Setup pointers
    mv a0, s0             # Start
    add a1, s0, s1
    addi a1, a1, -1       # End
    
    # Reverse loop
strrev_loop:
    bge a0, a1, strrev_done
    lbu t0, 0(a0)         # Load from start
    lbu t1, 0(a1)         # Load from end
    sb t1, 0(a0)          # Store to start
    sb t0, 0(a1)          # Store to end
    addi a0, a0, 1
    addi a1, a1, -1
    j strrev_loop
    
strrev_done:
    mv a0, s0             # Return original pointer
    lw ra, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 12
    ret

# ========================================
# Helper Functions
# ========================================

print_string:
    li a7, 4
    ecall
    ret

print_int:
    li a7, 1
    ecall
    ret

print_newline:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, newline
    jal ra, print_string
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
