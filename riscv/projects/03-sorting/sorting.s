# RISC-V Sorting Algorithms
# Implementations of bubble sort, selection sort, and quicksort

.data
array:      .word 64, 34, 25, 12, 22, 11, 90, 88, 45, 50
array_len:  .word 10
msg1:       .string "Original array: "
msg2:       .string "\nAfter bubble sort: "
msg3:       .string "\nAfter selection sort: "
msg4:       .string "\nAfter quicksort: "
space:      .string " "
newline:    .string "\n"

.text
.globl main

main:
    # Print original array
    la a0, msg1
    jal ra, print_string
    la a0, array
    la t0, array_len
    lw a1, 0(t0)
    jal ra, print_array
    
    # Test bubble sort
    la a0, msg2
    jal ra, print_string
    la a0, array
    la t0, array_len
    lw a1, 0(t0)
    jal ra, bubble_sort
    la a0, array
    la t0, array_len
    lw a1, 0(t0)
    jal ra, print_array
    
    # Reset array for next test
    jal ra, reset_array
    
    # Test selection sort
    la a0, msg3
    jal ra, print_string
    la a0, array
    la t0, array_len
    lw a1, 0(t0)
    jal ra, selection_sort
    la a0, array
    la t0, array_len
    lw a1, 0(t0)
    jal ra, print_array
    
    # Reset array for next test
    jal ra, reset_array
    
    # Test quicksort
    la a0, msg4
    jal ra, print_string
    la a0, array
    li a1, 0
    la t0, array_len
    lw a2, 0(t0)
    addi a2, a2, -1
    jal ra, quicksort
    la a0, array
    la t0, array_len
    lw a1, 0(t0)
    jal ra, print_array
    
    # Print final newline
    la a0, newline
    jal ra, print_string
    
    # Exit
    li a7, 10
    ecall

# ========================================
# Bubble Sort
# ========================================
bubble_sort:
    addi sp, sp, -4
    sw s0, 0(sp)
    
    mv s0, a1             # s0 = n
    
bubble_outer:
    beqz s0, bubble_done
    li t0, 0              # i = 0
    addi t1, s0, -1       # limit = n - 1
    
bubble_inner:
    bge t0, t1, bubble_outer_next
    
    slli t2, t0, 2
    add t3, a0, t2
    lw t4, 0(t3)
    lw t5, 4(t3)
    
    ble t4, t5, bubble_no_swap
    
    sw t5, 0(t3)
    sw t4, 4(t3)
    
bubble_no_swap:
    addi t0, t0, 1
    j bubble_inner
    
bubble_outer_next:
    addi s0, s0, -1
    j bubble_outer
    
bubble_done:
    lw s0, 0(sp)
    addi sp, sp, 4
    ret

# ========================================
# Selection Sort
# ========================================
selection_sort:
    li t0, 0
    
sel_outer:
    bge t0, a1, sel_done
    mv t1, t0
    addi t2, t0, 1
    
sel_inner:
    bge t2, a1, sel_swap
    
    slli t3, t2, 2
    add t4, a0, t3
    lw t5, 0(t4)
    
    slli t3, t1, 2
    add t4, a0, t3
    lw t6, 0(t4)
    
    bge t5, t6, sel_no_update
    mv t1, t2
    
sel_no_update:
    addi t2, t2, 1
    j sel_inner
    
sel_swap:
    beq t0, t1, sel_no_swap_needed
    
    slli t2, t0, 2
    add t3, a0, t2
    lw t4, 0(t3)
    
    slli t2, t1, 2
    add t3, a0, t2
    lw t5, 0(t3)
    
    slli t2, t0, 2
    add t3, a0, t2
    sw t5, 0(t3)
    
    slli t2, t1, 2
    add t3, a0, t2
    sw t4, 0(t3)
    
sel_no_swap_needed:
    addi t0, t0, 1
    j sel_outer
    
sel_done:
    ret

# ========================================
# Quicksort
# ========================================
quicksort:
    bge a1, a2, qs_done
    
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    jal ra, partition
    mv s3, a0
    
    mv a0, s0
    mv a1, s1
    addi a2, s3, -1
    jal ra, quicksort
    
    mv a0, s0
    addi a1, s3, 1
    mv a2, s2
    jal ra, quicksort
    
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20
    
qs_done:
    ret

# Partition function for quicksort
partition:
    slli t0, a2, 2
    add t1, a0, t0
    lw t2, 0(t1)
    
    addi t3, a1, -1
    mv t4, a1
    
part_loop:
    bge t4, a2, part_done
    
    slli t0, t4, 2
    add t1, a0, t0
    lw t5, 0(t1)
    
    bge t5, t2, part_no_swap
    
    addi t3, t3, 1
    
    slli t0, t3, 2
    add t1, a0, t0
    lw t6, 0(t1)
    
    sw t5, 0(t1)
    
    slli t0, t4, 2
    add t1, a0, t0
    sw t6, 0(t1)
    
part_no_swap:
    addi t4, t4, 1
    j part_loop
    
part_done:
    addi t3, t3, 1
    
    slli t0, t3, 2
    add t1, a0, t0
    lw t5, 0(t1)
    
    slli t0, a2, 2
    add t1, a0, t0
    lw t6, 0(t1)
    
    slli t0, t3, 2
    add t1, a0, t0
    sw t6, 0(t1)
    
    slli t0, a2, 2
    add t1, a0, t0
    sw t5, 0(t1)
    
    mv a0, t3
    ret

# ========================================
# Helper Functions
# ========================================

print_array:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    mv s0, a0
    mv s1, a1
    li t0, 0
    
print_loop:
    bge t0, s1, print_done
    
    slli t1, t0, 2
    add t2, s0, t1
    lw a0, 0(t2)
    li a7, 1
    ecall
    
    la a0, space
    jal ra, print_string
    
    addi t0, t0, 1
    j print_loop
    
print_done:
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12
    ret

print_string:
    li a7, 4
    ecall
    ret

reset_array:
    la t0, array
    li t1, 64
    sw t1, 0(t0)
    li t1, 34
    sw t1, 4(t0)
    li t1, 25
    sw t1, 8(t0)
    li t1, 12
    sw t1, 12(t0)
    li t1, 22
    sw t1, 16(t0)
    li t1, 11
    sw t1, 20(t0)
    li t1, 90
    sw t1, 24(t0)
    li t1, 88
    sw t1, 28(t0)
    li t1, 45
    sw t1, 32(t0)
    li t1, 50
    sw t1, 36(t0)
    ret
