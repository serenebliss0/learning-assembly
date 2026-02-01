# RISC-V Data Structure Examples
# Arrays, linked lists, and more

.data
# Array example
int_array:    .word 10, 20, 30, 40, 50
array_size:   .word 5

# String array
str_array:
    .word str1, str2, str3
str1:         .string "First"
str2:         .string "Second"
str3:         .string "Third"

# Structure example (Person: name, age, height)
person1:
    .word name1           # char* name
    .word 25              # int age
    .word 175             # int height (cm)
name1:        .string "Alice"

person2:
    .word name2
    .word 30
    .word 180
name2:        .string "Bob"

# Linked list node structure (value, next)
# Node 1
node1:
    .word 10              # value
    .word node2           # next pointer
# Node 2
node2:
    .word 20
    .word node3
# Node 3
node3:
    .word 30
    .word 0               # NULL (end of list)

msg1:         .string "Array element "
msg2:         .string ": "
msg3:         .string "\nString "
msg4:         .string "\nLinked list: "
space:        .string " -> "
endl:         .string "NULL\n"
newline:      .string "\n"

.text
.globl main

main:
    # ========================================
    # Example 1: Array Access
    # ========================================
    
    la s0, int_array      # Array base address
    la t0, array_size
    lw s1, 0(t0)          # Array size
    li s2, 0              # Index
    
array_loop:
    bge s2, s1, array_done
    
    # Print "Array element i: "
    la a0, msg1
    jal ra, print_string
    mv a0, s2
    jal ra, print_int
    la a0, msg2
    jal ra, print_string
    
    # Access array[i]
    slli t0, s2, 2        # i * 4 (word size)
    add t1, s0, t0        # &array[i]
    lw a0, 0(t1)          # Load array[i]
    jal ra, print_int
    
    la a0, newline
    jal ra, print_string
    
    addi s2, s2, 1
    j array_loop
    
array_done:

    # ========================================
    # Example 2: String Array
    # ========================================
    
    la s0, str_array      # Array of string pointers
    li s1, 3              # Number of strings
    li s2, 0              # Index
    
str_array_loop:
    bge s2, s1, str_array_done
    
    # Print "String i: "
    la a0, msg3
    jal ra, print_string
    mv a0, s2
    jal ra, print_int
    la a0, msg2
    jal ra, print_string
    
    # Get string pointer
    slli t0, s2, 2        # i * 4
    add t1, s0, t0        # &str_array[i]
    lw a0, 0(t1)          # Load string pointer
    jal ra, print_string
    
    la a0, newline
    jal ra, print_string
    
    addi s2, s2, 1
    j str_array_loop
    
str_array_done:

    # ========================================
    # Example 3: Structure Access
    # ========================================
    
    # Access person1 fields
    la t0, person1
    lw a0, 0(t0)          # name pointer
    jal ra, print_string
    
    la a0, msg2
    jal ra, print_string
    
    lw a0, 4(t0)          # age
    jal ra, print_int
    
    la a0, newline
    jal ra, print_string
    
    # ========================================
    # Example 4: Linked List Traversal
    # ========================================
    
    la a0, msg4
    jal ra, print_string
    
    la s0, node1          # Start at head
    
list_loop:
    beqz s0, list_done
    
    # Print node value
    lw a0, 0(s0)          # Load value
    jal ra, print_int
    
    # Load next pointer
    lw s0, 4(s0)          # next pointer
    
    # Print arrow if not end
    beqz s0, list_loop
    la a0, space
    jal ra, print_string
    j list_loop
    
list_done:
    la a0, space
    jal ra, print_string
    la a0, endl
    jal ra, print_string
    
    # Exit
    li a7, 10
    ecall

# ========================================
# Data Structure Manipulation Functions
# ========================================

# Function: array_sum
# Calculate sum of integer array
# Input: a0 = array address, a1 = size
# Output: a0 = sum
array_sum:
    li t0, 0              # sum = 0
    li t1, 0              # i = 0
    
sum_loop:
    bge t1, a1, sum_done
    
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    add t0, t0, t4
    
    addi t1, t1, 1
    j sum_loop
    
sum_done:
    mv a0, t0
    ret

# Function: array_max
# Find maximum value in array
# Input: a0 = array address, a1 = size
# Output: a0 = maximum value
array_max:
    lw t0, 0(a0)          # max = array[0]
    li t1, 1              # i = 1
    
max_loop:
    bge t1, a1, max_done
    
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    
    ble t4, t0, max_no_update
    mv t0, t4
    
max_no_update:
    addi t1, t1, 1
    j max_loop
    
max_done:
    mv a0, t0
    ret

# Function: list_length
# Count nodes in linked list
# Input: a0 = head pointer
# Output: a0 = length
list_length:
    li t0, 0              # count = 0
    
len_loop:
    beqz a0, len_done
    addi t0, t0, 1
    lw a0, 4(a0)          # next pointer
    j len_loop
    
len_done:
    mv a0, t0
    ret

# Function: list_find
# Find value in linked list
# Input: a0 = head pointer, a1 = value to find
# Output: a0 = pointer to node or NULL
list_find:
find_loop:
    beqz a0, find_done    # NULL - not found
    
    lw t0, 0(a0)          # node value
    beq t0, a1, find_done # Found!
    
    lw a0, 4(a0)          # next pointer
    j find_loop
    
find_done:
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

# ========================================
# Data Structure Memory Layouts
# ========================================
#
# Array (contiguous memory):
# [elem0][elem1][elem2][elem3]...
#
# Structure (fields in order):
# struct Person {
#     char* name;  // offset 0
#     int age;     // offset 4
#     int height;  // offset 8
# };
#
# Linked List Node:
# struct Node {
#     int value;   // offset 0
#     Node* next;  // offset 4
# };
#
# 2D Array (row-major):
# array[i][j] = base + (i * cols + j) * element_size
