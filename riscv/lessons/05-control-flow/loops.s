# loops.s - Various loop patterns in RISC-V assembly
# Demonstrates while loops, do-while loops, and for loops

.section .data
array: .word 10, 20, 30, 40, 50
count: .word 5

.section .text
.globl _start

_start:
    # Example 1: Simple for loop (sum 1 to 10)
    li t0, 1                # i = 1
    li t1, 11               # limit = 11 (loop while i < 11)
    li t2, 0                # sum = 0

for_loop:
    bge t0, t1, for_done    # if i >= 11, exit
    add t2, t2, t0          # sum += i
    addi t0, t0, 1          # i++
    j for_loop

for_done:
    # t2 now = 55 (sum of 1..10)
    
    # Example 2: Sum array elements
    la t0, array            # Address of array
    la t1, count
    lw t1, 0(t1)            # Number of elements
    li t2, 0                # Sum = 0
    li t3, 0                # Index = 0

sum_loop:
    bge t3, t1, sum_done    # if index >= count, done
    
    lw t4, 0(t0)            # Load array[index]
    add t2, t2, t4          # sum += array[index]
    addi t0, t0, 4          # Move to next element (4 bytes)
    addi t3, t3, 1          # index++
    j sum_loop

sum_done:
    # t2 = 150 (10+20+30+40+50)
    
    # Example 3: Countdown (do-while pattern)
    li t0, 5                # counter = 5

countdown:
    # Loop body executes first
    addi t0, t0, -1         # counter--
    bnez t0, countdown      # if counter != 0, repeat
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
