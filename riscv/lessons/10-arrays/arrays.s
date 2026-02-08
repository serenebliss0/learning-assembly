# arrays.s - Comprehensive array operations

.section .data

test_array:
    .word 15, 3, 9, 27, 6, 12, 18, 21, 24, 30
array_size:
    .word 10

search_value:
    .word 18

result:
    .word 0

.section .text
.globl _start

_start:
    # Test 1: Sum array
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
    lw a2, search_value
    call array_search
    mv s3, a0                   # s3 = index (6) or -1
    
    # Test 5: Reverse array in place
    la a0, test_array
    lw a1, array_size
    call array_reverse
    # Array now reversed
    
    # Test 6: Reverse it back
    la a0, test_array
    lw a1, array_size
    call array_reverse
    # Array back to original
    
    # Test 7: Count occurrences
    la a0, test_array
    lw a1, array_size
    li a2, 3
    call array_count
    mv s4, a0                   # s4 = count of 3
    
    # Test 8: Find index of minimum
    la a0, test_array
    lw a1, array_size
    call array_min_index
    mv s5, a0                   # s5 = index of min
    
    # Test 9: Calculate average
    la a0, test_array
    lw a1, array_size
    call array_average
    mv s6, a0                   # s6 = average
    
    # Exit with sum
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
    mv t2, a0                   # array pointer
    
sum_loop:
    bge t1, a1, sum_done
    lw t3, 0(t2)                # Load element
    add t0, t0, t3              # sum += element
    addi t2, t2, 4              # Next element
    addi t1, t1, 1              # Increment index
    j sum_loop
    
sum_done:
    mv a0, t0
    ret

# Function: array_max
# Find maximum element in array
# Input: a0 = array address, a1 = count
# Output: a0 = maximum value
array_max:
    beqz a1, max_empty
    
    lw t0, 0(a0)                # max = array[0]
    li t1, 1                    # index = 1
    addi t2, a0, 4              # pointer to array[1]
    
max_loop:
    bge t1, a1, max_done
    lw t3, 0(t2)                # Load element
    
    ble t3, t0, max_next        # if element <= max, skip
    mv t0, t3                   # max = element
    
max_next:
    addi t2, t2, 4
    addi t1, t1, 1
    j max_loop
    
max_done:
    mv a0, t0
    ret

max_empty:
    li a0, 0
    ret

# Function: array_min
# Find minimum element in array
# Input: a0 = array address, a1 = count
# Output: a0 = minimum value
array_min:
    beqz a1, min_empty
    
    lw t0, 0(a0)                # min = array[0]
    li t1, 1                    # index = 1
    addi t2, a0, 4              # pointer
    
min_loop:
    bge t1, a1, min_done
    lw t3, 0(t2)
    
    bge t3, t0, min_next        # if element >= min, skip
    mv t0, t3                   # min = element
    
min_next:
    addi t2, t2, 4
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
    mv t1, a0                   # pointer
    
search_loop:
    bge t0, a1, not_found
    lw t2, 0(t1)
    
    beq t2, a2, found           # if element == target
    
    addi t1, t1, 4
    addi t0, t0, 1
    j search_loop
    
found:
    mv a0, t0
    ret

not_found:
    li a0, -1
    ret

# Function: array_reverse
# Reverse array in place
# Input: a0 = array address, a1 = count
# Output: none (array modified)
array_reverse:
    li t0, 0                    # left = 0
    addi t1, a1, -1             # right = count - 1
    
reverse_loop:
    bge t0, t1, reverse_done
    
    # Calculate addresses
    slli t2, t0, 2
    add t2, a0, t2              # &array[left]
    slli t3, t1, 2
    add t3, a0, t3              # &array[right]
    
    # Swap
    lw t4, 0(t2)
    lw t5, 0(t3)
    sw t5, 0(t2)
    sw t4, 0(t3)
    
    addi t0, t0, 1
    addi t1, t1, -1
    j reverse_loop
    
reverse_done:
    ret

# Function: array_count
# Count occurrences of value
# Input: a0 = array address, a1 = count, a2 = value
# Output: a0 = number of occurrences
array_count:
    li t0, 0                    # count = 0
    li t1, 0                    # index = 0
    mv t2, a0                   # pointer
    
count_loop:
    bge t1, a1, count_done
    lw t3, 0(t2)
    
    bne t3, a2, count_next
    addi t0, t0, 1              # Found one
    
count_next:
    addi t2, t2, 4
    addi t1, t1, 1
    j count_loop
    
count_done:
    mv a0, t0
    ret

# Function: array_min_index
# Find index of minimum element
# Input: a0 = array address, a1 = count
# Output: a0 = index of minimum
array_min_index:
    beqz a1, min_idx_empty
    
    lw t0, 0(a0)                # min_val = array[0]
    li t1, 0                    # min_idx = 0
    li t2, 1                    # index = 1
    
min_idx_loop:
    bge t2, a1, min_idx_done
    
    slli t3, t2, 2
    add t4, a0, t3
    lw t5, 0(t4)
    
    bge t5, t0, min_idx_next
    mv t0, t5                   # New min
    mv t1, t2                   # New min index
    
min_idx_next:
    addi t2, t2, 1
    j min_idx_loop
    
min_idx_done:
    mv a0, t1
    ret

min_idx_empty:
    li a0, -1
    ret

# Function: array_average
# Calculate average (integer division)
# Input: a0 = array address, a1 = count
# Output: a0 = average
array_average:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    beqz a1, avg_zero
    
    mv s0, a1                   # Save count
    call array_sum
    div a0, a0, s0              # average = sum / count (requires M extension)
    
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

avg_zero:
    li a0, 0
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
    add t2, a0, t1              # Source address
    add t3, a1, t1              # Dest address
    lw t4, 0(t2)
    sw t4, 0(t3)
    addi t0, t0, 1
    j copy_loop
    
copy_done:
    ret

# Function: array_fill
# Fill array with value
# Input: a0 = array address, a1 = count, a2 = value
# Output: none
array_fill:
    li t0, 0                    # index = 0
    mv t1, a0                   # pointer
    
fill_loop:
    bge t0, a1, fill_done
    sw a2, 0(t1)                # Store value
    addi t1, t1, 4
    addi t0, t0, 1
    j fill_loop
    
fill_done:
    ret

# Function: array_contains
# Check if array contains value
# Input: a0 = array address, a1 = count, a2 = value
# Output: a0 = 1 if found, 0 otherwise
array_contains:
    addi sp, sp, -16
    sw ra, 12(sp)
    
    call array_search
    
    # Convert index to boolean
    li t0, -1
    bne a0, t0, contains_yes
    
    li a0, 0
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

contains_yes:
    li a0, 1
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
