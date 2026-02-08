# Lesson 10: Arrays and Data Structures

Arrays are fundamental data structures. Understanding array operations, indexing, and traversal is essential for practical assembly programming.

## Learning Objectives

By the end of this lesson, you'll:
- Declare and initialize arrays
- Perform array indexing and access
- Traverse arrays efficiently
- Work with multidimensional arrays
- Implement structures in assembly
- Search arrays (linear, binary)
- Sort arrays (bubble sort, selection sort)
- Calculate array statistics

## Array Basics

An **array** is a contiguous sequence of elements of the same type.

### Declaration

```asm
.section .data

# Integer array (words)
numbers:
    .word 10, 20, 30, 40, 50

# Byte array
bytes:
    .byte 1, 2, 3, 4, 5, 6, 7, 8

# Uninitialized array
buffer:
    .space 40                   # 40 bytes (10 words)

# Array with label and size
.align 2
array:
    .word 5, 15, 25, 35, 45
array_size:
    .word 5
```

### Accessing Elements

Array access formula: `address = base + (index * element_size)`

```asm
la t0, numbers              # t0 = base address
li t1, 2                    # index = 2

# Access numbers[2]
slli t2, t1, 2              # t2 = index * 4 (word size)
add t2, t0, t2              # t2 = address of numbers[2]
lw t3, 0(t2)                # t3 = numbers[2] = 30
```

Or more concisely:
```asm
la t0, numbers
li t1, 2
slli t1, t1, 2              # index * 4
lw t3, 0(t1 + t0)           # WRONG! Can't do in one instruction

# Correct way:
add t1, t0, t1              # t1 = base + offset
lw t3, 0(t1)                # Load element
```

## Array Traversal

### Forward Traversal

```asm
la t0, numbers              # t0 = array pointer
li t1, 0                    # t1 = index
li t2, 5                    # t2 = count

loop:
    bge t1, t2, done        # if index >= count, done
    lw t3, 0(t0)            # Load element
    # Process t3...
    addi t0, t0, 4          # Next element
    addi t1, t1, 1          # Increment index
    j loop
done:
```

### Backward Traversal

```asm
la t0, numbers              # Base address
li t1, 5                    # Count
slli t2, t1, 2              # Offset to last element
add t0, t0, t2              # Point to last element
addi t0, t0, -4             # Adjust

loop:
    beqz t1, done
    lw t3, 0(t0)            # Load element
    # Process t3...
    addi t0, t0, -4         # Previous element
    addi t1, t1, -1
    j loop
done:
```

## The Code - Array Operations

```asm
# arrays.s - Comprehensive array operations

.section .data

test_array:
    .word 15, 3, 9, 27, 6, 12, 18, 21, 24, 30
array_size:
    .word 10

search_target:
    .word 18

result_buffer:
    .space 40                   # Space for results

.section .text
.globl _start

_start:
    # Test 1: Sum array elements
    la a0, test_array
    lw a1, array_size
    call array_sum
    mv s0, a0                   # s0 = sum (165)
    
    # Test 2: Find maximum
    la a0, test_array
    lw a1, array_size
    call array_max
    mv s1, a0                   # s1 = max (30)
    
    # Test 3: Find minimum
    la a0, test_array
    lw a1, array_size
    call array_min
    mv s2, a0                   # s2 = min (3)
    
    # Test 4: Linear search
    la a0, test_array
    lw a1, array_size
    lw a2, search_target
    call array_search
    mv s3, a0                   # s3 = index (6) or -1 if not found
    
    # Test 5: Reverse array
    la a0, test_array
    lw a1, array_size
    call array_reverse
    
    # Test 6: Count occurrences
    la a0, test_array
    lw a1, array_size
    li a2, 18
    call array_count
    mv s4, a0                   # s4 = count
    
    # Test 7: Calculate average
    la a0, test_array
    lw a1, array_size
    call array_average
    mv s5, a0                   # s5 = average
    
    # Exit
    mv a0, s0
    li a7, 93
    ecall

# Function: array_sum
# Sum all elements in array
# Input: a0 = array address, a1 = count
# Output: a0 = sum
array_sum:
    li t0, 0                    # sum = 0
    li t1, 0                    # index = 0
    
sum_loop:
    bge t1, a1, sum_done
    slli t2, t1, 2              # offset = index * 4
    add t3, a0, t2              # address = base + offset
    lw t4, 0(t3)                # load element
    add t0, t0, t4              # sum += element
    addi t1, t1, 1
    j sum_loop
    
sum_done:
    mv a0, t0
    ret

# Function: array_max
# Find maximum element
# Input: a0 = array address, a1 = count
# Output: a0 = maximum value
array_max:
    beqz a1, max_empty          # Handle empty array
    
    lw t0, 0(a0)                # max = array[0]
    li t1, 1                    # Start from index 1
    
max_loop:
    bge t1, a1, max_done
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    
    ble t4, t0, max_next        # if element <= max, skip
    mv t0, t4                   # max = element
    
max_next:
    addi t1, t1, 1
    j max_loop
    
max_done:
    mv a0, t0
    ret

max_empty:
    li a0, 0
    ret

# Function: array_min
# Find minimum element
# Input: a0 = array address, a1 = count
# Output: a0 = minimum value
array_min:
    beqz a1, min_empty
    
    lw t0, 0(a0)                # min = array[0]
    li t1, 1
    
min_loop:
    bge t1, a1, min_done
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    
    bge t4, t0, min_next        # if element >= min, skip
    mv t0, t4                   # min = element
    
min_next:
    addi t1, t1, 1
    j min_loop
    
min_done:
    mv a0, t0
    ret

min_empty:
    li a0, 0
    ret

# Function: array_search
# Linear search for element
# Input: a0 = array address, a1 = count, a2 = target
# Output: a0 = index (or -1 if not found)
array_search:
    li t0, 0                    # index = 0
    
search_loop:
    bge t0, a1, search_not_found
    slli t1, t0, 2
    add t2, a0, t1
    lw t3, 0(t2)
    
    beq t3, a2, search_found    # if element == target
    
    addi t0, t0, 1
    j search_loop
    
search_found:
    mv a0, t0
    ret

search_not_found:
    li a0, -1
    ret

# Function: array_reverse
# Reverse array in place
# Input: a0 = array address, a1 = count
# Output: none (array modified)
array_reverse:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    
    mv s0, a0                   # Save base address
    li t0, 0                    # left = 0
    addi t1, a1, -1             # right = count - 1
    
reverse_loop:
    bge t0, t1, reverse_done    # if left >= right, done
    
    # Calculate addresses
    slli t2, t0, 2
    add t2, s0, t2              # &array[left]
    slli t3, t1, 2
    add t3, s0, t3              # &array[right]
    
    # Swap
    lw t4, 0(t2)                # temp = array[left]
    lw t5, 0(t3)                # array[right]
    sw t5, 0(t2)                # array[left] = array[right]
    sw t4, 0(t3)                # array[right] = temp
    
    addi t0, t0, 1              # left++
    addi t1, t1, -1             # right--
    j reverse_loop
    
reverse_done:
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

# Function: array_count
# Count occurrences of value
# Input: a0 = array address, a1 = count, a2 = value
# Output: a0 = number of occurrences
array_count:
    li t0, 0                    # count = 0
    li t1, 0                    # index = 0
    
count_loop:
    bge t1, a1, count_done
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    
    bne t4, a2, count_next
    addi t0, t0, 1              # Increment count
    
count_next:
    addi t1, t1, 1
    j count_loop
    
count_done:
    mv a0, t0
    ret

# Function: array_average
# Calculate average of array elements
# Input: a0 = array address, a1 = count
# Output: a0 = average (integer division)
array_average:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    mv s0, a1                   # Save count
    call array_sum              # Get sum
    div a0, a0, s0              # average = sum / count
    
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Function: array_copy
# Copy array from source to destination
# Input: a0 = source, a1 = dest, a2 = count
# Output: none
array_copy:
    li t0, 0                    # index = 0
    
copy_loop:
    bge t0, a2, copy_done
    slli t1, t0, 2
    add t2, a0, t1              # source address
    add t3, a1, t1              # dest address
    lw t4, 0(t2)
    sw t4, 0(t3)
    addi t0, t0, 1
    j copy_loop
    
copy_done:
    ret
```

## Breaking It Down

### Array Indexing

```asm
slli t2, t1, 2              # offset = index * 4
add t3, a0, t2              # address = base + offset
lw t4, 0(t3)                # load element
```

The formula `address = base + (index * element_size)` is fundamental:
- For bytes: offset = index * 1
- For halfwords: offset = index * 2
- For words: offset = index * 4

### In-Place Modification

```asm
# Reverse array in place
lw t4, 0(t2)                # Load left element
lw t5, 0(t3)                # Load right element
sw t5, 0(t2)                # Store right into left
sw t4, 0(t3)                # Store left into right
```

Modifying an array in place saves memory but destroys original data.

## Building and Running

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 -o arrays.o arrays.s

# Link
riscv64-unknown-elf-ld -m elf32lriscv -o arrays arrays.o

# Run
qemu-riscv32 arrays
```

## The Code - Sorting

```asm
# sort.s - Array sorting algorithms

.section .data

unsorted_array:
    .word 64, 34, 25, 12, 22, 11, 90, 88, 45, 50
array_size:
    .word 10

.section .text
.globl _start

_start:
    # Test 1: Bubble sort
    la a0, unsorted_array
    lw a1, array_size
    call bubble_sort
    
    # Array is now sorted
    # Verify by finding min and max
    la a0, unsorted_array
    lw a1, array_size
    call array_min
    mv s0, a0                   # s0 = 11 (min)
    
    la a0, unsorted_array
    lw a1, array_size
    call array_max
    mv s1, a0                   # s1 = 90 (max)
    
    # Test 2: Binary search (on sorted array)
    la a0, unsorted_array
    lw a1, array_size
    li a2, 45                   # Search for 45
    call binary_search
    mv s2, a0                   # s2 = index
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: bubble_sort
# Sort array using bubble sort
# Input: a0 = array address, a1 = count
# Output: none (array sorted in place)
bubble_sort:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    
    mv s0, a0                   # Save array address
    mv s1, a1                   # Save count
    
    # Outer loop: n-1 passes
    li s2, 0                    # i = 0
    
outer_loop:
    addi t0, s1, -1
    bge s2, t0, sort_done       # if i >= count-1, done
    
    # Inner loop: bubble largest to end
    li s3, 0                    # j = 0
    
inner_loop:
    sub t0, s1, s2
    addi t0, t0, -1
    bge s3, t0, outer_next      # if j >= count-i-1, next pass
    
    # Compare array[j] and array[j+1]
    slli t1, s3, 2
    add t2, s0, t1              # &array[j]
    lw t3, 0(t2)                # array[j]
    lw t4, 4(t2)                # array[j+1]
    
    ble t3, t4, inner_next      # if array[j] <= array[j+1], no swap
    
    # Swap array[j] and array[j+1]
    sw t4, 0(t2)
    sw t3, 4(t2)
    
inner_next:
    addi s3, s3, 1
    j inner_loop
    
outer_next:
    addi s2, s2, 1
    j outer_loop
    
sort_done:
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

# Function: selection_sort
# Sort array using selection sort
# Input: a0 = array address, a1 = count
# Output: none (array sorted in place)
selection_sort:
    addi sp, sp, -32
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    
    mv s0, a0                   # array address
    mv s1, a1                   # count
    li s2, 0                    # i = 0
    
sel_outer:
    addi t0, s1, -1
    bge s2, t0, sel_done
    
    # Find minimum in array[i..n-1]
    mv s3, s2                   # min_index = i
    slli t1, s2, 2
    add t2, s0, t1
    lw t3, 0(t2)                # min_value = array[i]
    
    addi t4, s2, 1              # j = i + 1
    
sel_inner:
    bge t4, s1, sel_swap
    
    slli t5, t4, 2
    add t6, s0, t5
    lw t0, 0(t6)                # array[j]
    
    bge t0, t3, sel_inner_next  # if array[j] >= min_value
    mv t3, t0                   # min_value = array[j]
    mv s3, t4                   # min_index = j
    
sel_inner_next:
    addi t4, t4, 1
    j sel_inner
    
sel_swap:
    # Swap array[i] and array[min_index]
    beq s2, s3, sel_outer_next  # if i == min_index, no swap
    
    slli t1, s2, 2
    add t2, s0, t1              # &array[i]
    slli t3, s3, 2
    add t4, s0, t3              # &array[min_index]
    
    lw t5, 0(t2)
    lw t6, 0(t4)
    sw t6, 0(t2)
    sw t5, 0(t4)
    
sel_outer_next:
    addi s2, s2, 1
    j sel_outer
    
sel_done:
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
    addi sp, sp, 32
    ret

# Function: binary_search
# Binary search in sorted array
# Input: a0 = array address, a1 = count, a2 = target
# Output: a0 = index (or -1 if not found)
binary_search:
    li t0, 0                    # left = 0
    addi t1, a1, -1             # right = count - 1
    
bsearch_loop:
    bgt t0, t1, bsearch_not_found
    
    # mid = (left + right) / 2
    add t2, t0, t1
    srli t2, t2, 1              # Divide by 2
    
    # Load array[mid]
    slli t3, t2, 2
    add t4, a0, t3
    lw t5, 0(t4)
    
    beq t5, a2, bsearch_found   # if array[mid] == target
    blt t5, a2, bsearch_right   # if array[mid] < target
    
    # Search left half
    addi t1, t2, -1             # right = mid - 1
    j bsearch_loop
    
bsearch_right:
    # Search right half
    addi t0, t2, 1              # left = mid + 1
    j bsearch_loop
    
bsearch_found:
    mv a0, t2                   # Return index
    ret

bsearch_not_found:
    li a0, -1
    ret

# Function: is_sorted
# Check if array is sorted (ascending)
# Input: a0 = array address, a1 = count
# Output: a0 = 1 if sorted, 0 otherwise
is_sorted:
    li t0, 1                    # index = 1
    
check_loop:
    bge t0, a1, is_sorted_yes
    
    # Compare array[i-1] and array[i]
    slli t1, t0, 2
    add t2, a0, t1
    lw t3, -4(t2)               # array[i-1]
    lw t4, 0(t2)                # array[i]
    
    bgt t3, t4, is_sorted_no    # if array[i-1] > array[i]
    
    addi t0, t0, 1
    j check_loop
    
is_sorted_yes:
    li a0, 1
    ret

is_sorted_no:
    li a0, 0
    ret

# Helper functions from arrays.s
array_min:
    beqz a1, min_empty
    lw t0, 0(a0)
    li t1, 1
min_loop:
    bge t1, a1, min_done
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    bge t4, t0, min_next
    mv t0, t4
min_next:
    addi t1, t1, 1
    j min_loop
min_done:
    mv a0, t0
    ret
min_empty:
    li a0, 0
    ret

array_max:
    beqz a1, max_empty
    lw t0, 0(a0)
    li t1, 1
max_loop:
    bge t1, a1, max_done
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    ble t4, t0, max_next
    mv t0, t4
max_next:
    addi t1, t1, 1
    j max_loop
max_done:
    mv a0, t0
    ret
max_empty:
    li a0, 0
    ret
```

## Breaking It Down - Sorting

### Bubble Sort Algorithm

```asm
# Pseudocode:
# for i = 0 to n-1:
#     for j = 0 to n-i-1:
#         if array[j] > array[j+1]:
#             swap(array[j], array[j+1])
```

Bubble sort repeatedly steps through the list, compares adjacent elements, and swaps them if they're in wrong order.

### Binary Search

```asm
# Requires sorted array
# Pseudocode:
# left = 0, right = n-1
# while left <= right:
#     mid = (left + right) / 2
#     if array[mid] == target: return mid
#     if array[mid] < target: left = mid + 1
#     else: right = mid - 1
```

Binary search is O(log n), much faster than linear search for sorted arrays.

## Multidimensional Arrays

### 2D Array Access

```asm
# 2D array: matrix[rows][cols]
# Element at [i][j]: address = base + (i * cols + j) * element_size

.section .data
matrix:
    # 3x3 matrix
    .word 1, 2, 3
    .word 4, 5, 6
    .word 7, 8, 9

.section .text
# Access matrix[1][2] (row 1, col 2)
la t0, matrix
li t1, 1                    # row
li t2, 2                    # col
li t3, 3                    # cols per row

mul t4, t1, t3              # row * cols
add t4, t4, t2              # + col
slli t4, t4, 2              # * 4 (word size)
add t5, t0, t4              # base + offset
lw t6, 0(t5)                # t6 = 6
```

## Structures in Assembly

```asm
# Define structure layout
# struct Person {
#     int age;        // offset 0
#     int height;     // offset 4
#     int weight;     // offset 8
# };

.section .data
person1:
    .word 25                # age
    .word 175               # height
    .word 70                # weight

# Access structure fields
la t0, person1
lw t1, 0(t0)                # age
lw t2, 4(t0)                # height
lw t3, 8(t0)                # weight

# Modify field
li t4, 26
sw t4, 0(t0)                # person1.age = 26
```

## Experiments to Try

1. **Performance Comparison**
   - Compare linear vs binary search
   - Time different sorting algorithms
   - Measure array traversal speeds

2. **Array Manipulation**
   - Remove duplicates
   - Rotate array elements
   - Partition around pivot

3. **2D Arrays**
   - Matrix transpose
   - Matrix multiplication
   - Row/column sums

## Exercises

**Exercise 1:** Write a function to find the second largest element in an array.

**Exercise 2:** Implement insertion sort.

**Exercise 3:** Create a function to merge two sorted arrays into one sorted array.

**Exercise 4:** Write a function to rotate an array left by n positions.

<details>
<summary>Solution to Exercise 1</summary>

```asm
# Find second largest element
# Input: a0 = array address, a1 = count (must be >= 2)
# Output: a0 = second largest
second_largest:
    lw t0, 0(a0)                # first = array[0]
    lw t1, 4(a0)                # second = array[1]
    
    # Ensure first >= second
    bge t0, t1, find_second
    mv t2, t0
    mv t0, t1
    mv t1, t2

find_second:
    li t2, 2                    # index = 2

second_loop:
    bge t2, a1, second_done
    slli t3, t2, 2
    add t4, a0, t3
    lw t5, 0(t4)                # current element
    
    ble t5, t1, second_next     # if element <= second
    
    # Check if new first
    bgt t5, t0, new_first
    # New second (between first and second)
    mv t1, t5
    j second_next

new_first:
    mv t1, t0                   # old first becomes second
    mv t0, t5                   # new first

second_next:
    addi t2, t2, 1
    j second_loop

second_done:
    mv a0, t1
    ret
```
</details>

<details>
<summary>Solution to Exercise 2</summary>

```asm
# Insertion sort
# Input: a0 = array address, a1 = count
# Output: none (array sorted)
insertion_sort:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    
    mv s0, a0                   # array
    mv s1, a1                   # count
    li s2, 1                    # i = 1

ins_outer:
    bge s2, s1, ins_done
    
    # key = array[i]
    slli t0, s2, 2
    add t1, s0, t0
    lw t2, 0(t1)                # key
    
    # j = i - 1
    addi t3, s2, -1

ins_inner:
    bltz t3, ins_insert         # if j < 0
    
    slli t4, t3, 2
    add t5, s0, t4
    lw t6, 0(t5)                # array[j]
    
    ble t6, t2, ins_insert      # if array[j] <= key
    
    # array[j+1] = array[j]
    sw t6, 4(t5)
    addi t3, t3, -1
    j ins_inner

ins_insert:
    # array[j+1] = key
    addi t3, t3, 1
    slli t4, t3, 2
    add t5, s0, t4
    sw t2, 0(t5)
    
    addi s2, s2, 1
    j ins_outer

ins_done:
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret
```
</details>

<details>
<summary>Solution to Exercise 4</summary>

```asm
# Rotate array left by n positions
# Input: a0 = array, a1 = count, a2 = positions
# Output: none (array rotated)
rotate_left:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    
    mv s0, a0                   # array
    mv s1, a1                   # count
    mv s2, a2                   # positions
    
    # Normalize positions (mod count)
    rem s2, s2, s1
    beqz s2, rotate_done
    
    # Reverse first n elements
    mv a0, s0
    mv a1, s2
    call reverse_range
    
    # Reverse remaining elements
    slli t0, s2, 2
    add a0, s0, t0
    sub a1, s1, s2
    call reverse_range
    
    # Reverse entire array
    mv a0, s0
    mv a1, s1
    call reverse_range

rotate_done:
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

reverse_range:
    li t0, 0                    # left = 0
    addi t1, a1, -1             # right = count - 1

rev_loop:
    bge t0, t1, rev_done
    slli t2, t0, 2
    add t3, a0, t2
    slli t4, t1, 2
    add t5, a0, t4
    lw t6, 0(t3)
    lw t7, 0(t5)
    sw t7, 0(t3)
    sw t6, 0(t5)
    addi t0, t0, 1
    addi t1, t1, -1
    j rev_loop

rev_done:
    ret
```
</details>

## Common Mistakes

❌ **Wrong index calculation**
```asm
add t1, a0, t0              # Wrong! Need to multiply index
# Should be: slli t0, t0, 2; add t1, a0, t0
```

❌ **Off-by-one errors**
```asm
li t0, 10
loop:
    bge t0, 10, done        # Wrong! Should be bge t0, a1
```

❌ **Forgetting element size**
```asm
addi t0, t0, 1              # Wrong for word arrays!
# Should be: addi t0, t0, 4
```

❌ **Modifying read-only arrays**
```asm
.section .rodata
array: .word 1, 2, 3
# Can't modify this!
```

## Key Takeaways

✅ **Arrays** are contiguous memory blocks

✅ **Index formula:** address = base + (index * size)

✅ **Use shifts** for multiply by powers of 2

✅ **Linear search:** O(n), works on any array

✅ **Binary search:** O(log n), requires sorted array

✅ **Bubble sort:** O(n²), simple but slow

✅ **Always bounds check** array access

## Next Lesson

Ready for system calls? Continue to:
**[Lesson 11: System Calls →](../11-syscalls/)**

Learn how to interact with the operating system!

---

## Quick Reference

**Array Access:**
```asm
# array[index]
slli t0, index, 2       # offset = index * 4
add t0, base, t0        # address = base + offset
lw value, 0(t0)         # load element
```

**Array Traversal:**
```asm
la t0, array
li t1, 0                # index
loop:
    bge t1, count, done
    lw t2, 0(t0)        # Process element
    addi t0, t0, 4      # Next element
    addi t1, t1, 1
    j loop
```

**Array Sorting:**
```asm
# Bubble sort: O(n²)
# Binary search: O(log n) on sorted
```

---

*Arrays: the foundation of data structures!* 📊
