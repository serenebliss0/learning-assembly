# sort.s - Array sorting and searching algorithms

.section .data

test_array:
    .word 64, 34, 25, 12, 22, 11, 90, 88, 45, 50
array_size:
    .word 10

sorted_array:
    .word 5, 10, 15, 20, 25, 30, 35, 40, 45, 50
sorted_size:
    .word 10

.section .text
.globl _start

_start:
    # Test 1: Bubble sort
    la a0, test_array
    lw a1, array_size
    call bubble_sort
    # Array now sorted: 11, 12, 22, 25, 34, 45, 50, 64, 88, 90
    
    # Verify sorting worked
    la a0, test_array
    lw a1, array_size
    call is_sorted
    mv s0, a0                   # s0 = 1 (is sorted)
    
    # Test 2: Binary search on sorted array
    la a0, test_array
    lw a1, array_size
    li a2, 45                   # Search for 45
    call binary_search
    mv s1, a0                   # s1 = index of 45
    
    # Test 3: Binary search for non-existent element
    la a0, test_array
    lw a1, array_size
    li a2, 100
    call binary_search
    mv s2, a0                   # s2 = -1 (not found)
    
    # Test 4: Selection sort on pre-sorted array
    la a0, sorted_array
    lw a1, sorted_size
    call selection_sort
    
    # Test 5: Find median (middle element of sorted array)
    la a0, test_array
    lw a1, array_size
    call find_median
    mv s3, a0                   # s3 = median value
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: bubble_sort
# Sort array using bubble sort algorithm
# Input: a0 = array address, a1 = count
# Output: none (array sorted in place)
bubble_sort:
    addi sp, sp, -32
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    
    mv s0, a0                   # Save array address
    mv s1, a1                   # Save count
    
    # Outer loop: n-1 passes
    li s2, 0                    # i = 0
    
bubble_outer:
    addi t0, s1, -1
    bge s2, t0, bubble_done     # if i >= count-1, done
    
    # Inner loop: compare adjacent elements
    li s3, 0                    # j = 0
    
bubble_inner:
    sub t0, s1, s2
    addi t0, t0, -1
    bge s3, t0, bubble_outer_next
    
    # Load array[j] and array[j+1]
    slli t1, s3, 2
    add t2, s0, t1              # Address of array[j]
    lw t3, 0(t2)                # array[j]
    lw t4, 4(t2)                # array[j+1]
    
    ble t3, t4, bubble_inner_next  # if array[j] <= array[j+1], no swap
    
    # Swap array[j] and array[j+1]
    sw t4, 0(t2)
    sw t3, 4(t2)
    
bubble_inner_next:
    addi s3, s3, 1
    j bubble_inner
    
bubble_outer_next:
    addi s2, s2, 1
    j bubble_outer
    
bubble_done:
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
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
    mv t3, t0                   # Update min_value
    mv s3, t4                   # Update min_index
    
sel_inner_next:
    addi t4, t4, 1
    j sel_inner
    
sel_swap:
    # Swap array[i] and array[min_index]
    beq s2, s3, sel_outer_next  # No swap if same
    
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
# Binary search in SORTED array
# Input: a0 = array address, a1 = count, a2 = target
# Output: a0 = index (or -1 if not found)
binary_search:
    li t0, 0                    # left = 0
    addi t1, a1, -1             # right = count - 1
    
bsearch_loop:
    bgt t0, t1, bsearch_not_found
    
    # mid = (left + right) / 2
    add t2, t0, t1
    srli t2, t2, 1              # Divide by 2 using shift
    
    # Load array[mid]
    slli t3, t2, 2
    add t4, a0, t3
    lw t5, 0(t4)
    
    beq t5, a2, bsearch_found   # Found target
    
    blt t5, a2, bsearch_right   # if array[mid] < target
    
    # Search left half
    addi t1, t2, -1             # right = mid - 1
    j bsearch_loop
    
bsearch_right:
    # Search right half
    addi t0, t2, 1              # left = mid + 1
    j bsearch_loop
    
bsearch_found:
    mv a0, t2
    ret

bsearch_not_found:
    li a0, -1
    ret

# Function: is_sorted
# Check if array is sorted in ascending order
# Input: a0 = array address, a1 = count
# Output: a0 = 1 if sorted, 0 otherwise
is_sorted:
    li t0, 1                    # index = 1
    
sorted_loop:
    bge t0, a1, sorted_yes
    
    # Compare array[i-1] and array[i]
    slli t1, t0, 2
    add t2, a0, t1
    lw t3, -4(t2)               # array[i-1]
    lw t4, 0(t2)                # array[i]
    
    bgt t3, t4, sorted_no       # if array[i-1] > array[i]
    
    addi t0, t0, 1
    j sorted_loop
    
sorted_yes:
    li a0, 1
    ret

sorted_no:
    li a0, 0
    ret

# Function: find_median
# Find median of sorted array
# Input: a0 = array address (must be sorted), a1 = count
# Output: a0 = median value
find_median:
    # For simplicity, return middle element
    # (For even count, this returns lower of two middle elements)
    srli t0, a1, 1              # mid_index = count / 2
    slli t1, t0, 2              # offset = mid_index * 4
    add t2, a0, t1              # address
    lw a0, 0(t2)                # median value
    ret

# Function: partition (for quicksort)
# Partition array around pivot (last element)
# Input: a0 = array, a1 = low, a2 = high
# Output: a0 = partition index
partition:
    addi sp, sp, -32
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    
    mv s0, a0                   # array
    mv s1, a1                   # low
    mv s2, a2                   # high
    
    # pivot = array[high]
    slli t0, s2, 2
    add t1, s0, t0
    lw s3, 0(t1)                # pivot value
    
    addi t2, s1, -1             # i = low - 1
    mv t3, s1                   # j = low
    
partition_loop:
    bge t3, s2, partition_done  # while j < high
    
    # Load array[j]
    slli t4, t3, 2
    add t5, s0, t4
    lw t6, 0(t5)
    
    bge t6, s3, partition_next  # if array[j] >= pivot
    
    # Swap array[i+1] and array[j]
    addi t2, t2, 1              # i++
    
    slli t0, t2, 2
    add t1, s0, t0              # &array[i]
    
    lw t4, 0(t1)                # temp = array[i]
    sw t6, 0(t1)                # array[i] = array[j]
    sw t4, 0(t5)                # array[j] = temp
    
partition_next:
    addi t3, t3, 1              # j++
    j partition_loop
    
partition_done:
    # Swap array[i+1] and array[high]
    addi t2, t2, 1
    slli t0, t2, 2
    add t1, s0, t0              # &array[i+1]
    slli t3, s2, 2
    add t4, s0, t3              # &array[high]
    
    lw t5, 0(t1)
    lw t6, 0(t4)
    sw t6, 0(t1)
    sw t5, 0(t4)
    
    mv a0, t2                   # Return partition index
    
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
    addi sp, sp, 32
    ret

# Function: swap_elements
# Swap two array elements
# Input: a0 = array, a1 = index1, a2 = index2
# Output: none
swap_elements:
    slli t0, a1, 2
    add t1, a0, t0              # &array[index1]
    slli t2, a2, 2
    add t3, a0, t2              # &array[index2]
    
    lw t4, 0(t1)
    lw t5, 0(t3)
    sw t5, 0(t1)
    sw t4, 0(t3)
    ret
