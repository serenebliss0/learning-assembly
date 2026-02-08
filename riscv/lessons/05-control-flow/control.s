# control.s - RISC-V control flow demonstrations
# Shows branches, jumps, loops, and conditional logic

.section .data
msg_equal:    .string "Numbers are equal\n"
msg_less:     .string "First is less\n"
msg_greater:  .string "First is greater\n"
msg_done:     .string "Loop complete!\n"

.section .text
.globl _start

_start:
    # Example 1: Simple comparison (if-else-if-else)
    li a0, 10
    li a1, 20
    
    beq a0, a1, equal       # Branch if equal
    blt a0, a1, less        # Branch if a0 < a1
    j greater               # Otherwise, a0 > a1

equal:
    la a1, msg_equal
    li a2, 18
    j print_and_continue

less:
    la a1, msg_less
    li a2, 14
    j print_and_continue

greater:
    la a1, msg_greater
    li a2, 18

print_and_continue:
    li a0, 1
    li a7, 64
    ecall
    
    # Example 2: Simple loop - count from 0 to 9
    li t0, 0                # Counter = 0
    li t1, 10               # Limit = 10

count_loop:
    bge t0, t1, loop_done   # Exit if t0 >= 10
    addi t0, t0, 1          # Increment counter
    j count_loop            # Repeat

loop_done:
    # Print completion message
    li a0, 1
    la a1, msg_done
    li a2, 15
    li a7, 64
    ecall
    
    # Example 3: Find maximum of two numbers
    li s0, 42
    li s1, 37
    
    bge s0, s1, s0_is_max
    mv s2, s1               # s2 = s1 (s1 is larger)
    j check_done

s0_is_max:
    mv s2, s0               # s2 = s0 (s0 is larger)

check_done:
    # s2 now contains max(42, 37) = 42
    
    # Exit with max as exit code
    mv a0, s2
    li a7, 93
    ecall
