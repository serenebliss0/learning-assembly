# atomic.s - A Extension: Atomic Operations
# Requires -march=rv32ima or higher

.section .data
counter:
    .word 0                # Shared counter

lock_var:
    .word 0                # Lock variable (0=unlocked, 1=locked)

array_data:
    .word 10, 20, 30, 40, 50

msg_start:
    .string "=== Atomic Operations Demo ===\n"
msg_start_len = . - msg_start

msg_counter:
    .string "Counter operations complete\n"
msg_counter_len = . - msg_counter

msg_lock:
    .string "Lock/unlock operations complete\n"
msg_lock_len = . - msg_lock

msg_swap:
    .string "Swap operations complete\n"
msg_swap_len = . - msg_swap

.section .text
.globl _start

_start:
    # Print start message
    li a7, 64
    li a0, 1
    la a1, msg_start
    li a2, msg_start_len
    ecall
    
    # === Example 1: Atomic increment with AMO ===
    la t0, counter
    
    # Atomic add: counter += 5
    li t1, 5
    amoadd.w t2, t1, (t0)  # t2 = old value, mem[t0] += t1
    
    # Do it again
    li t1, 3
    amoadd.w t2, t1, (t0)  # counter is now 8
    
    # Print counter message
    li a7, 64
    li a0, 1
    la a1, msg_counter
    li a2, msg_counter_len
    ecall
    
    # === Example 2: Spinlock with LR/SC ===
    la s0, lock_var
    
acquire_lock:
    # Try to acquire lock
    li t0, 1               # Value to write (locked)
    
    lr.w t1, (s0)          # Load-reserved from lock
    bnez t1, acquire_lock  # If already locked, spin
    
    sc.w t2, t0, (s0)      # Try to store 1 (acquire)
    bnez t2, acquire_lock  # If sc failed (t2 != 0), retry
    
    # === Lock acquired - critical section ===
    # Do some work...
    li t0, 42
    addi t0, t0, 8
    
    # === Release lock ===
release_lock:
    sw zero, (s0)          # Simple store to release
    
    # Print lock message
    li a7, 64
    li a0, 1
    la a1, msg_lock
    li a2, msg_lock_len
    ecall
    
    # === Example 3: Atomic swap ===
    la t0, array_data
    lw t1, 0(t0)           # t1 = 10
    
    li t2, 99
    amoswap.w t3, t2, (t0) # Swap: t3 = old value (10), mem = 99
    
    # Now array_data[0] = 99, t3 = 10
    
    # === Example 4: Atomic maximum ===
    la t0, counter
    li t1, 100
    amomax.w t2, t1, (t0)  # mem = max(mem, t1)
    
    # === Example 5: Compare-and-swap using LR/SC ===
    # Atomic: if (mem == expected) mem = new_value
    la t0, counter
    li t1, 100             # expected
    li t2, 200             # new_value
    
cas_loop:
    lr.w t3, (t0)          # Load current value
    bne t3, t1, cas_fail   # If not equal to expected, fail
    
    sc.w t4, t2, (t0)      # Try to store new value
    bnez t4, cas_loop      # If failed, retry
    
    # Success: counter was 100, now is 200
    j cas_done
    
cas_fail:
    # Value was not as expected
    
cas_done:
    # Print swap message
    li a7, 64
    li a0, 1
    la a1, msg_swap
    li a2, msg_swap_len
    ecall
    
    # === Exit ===
    li a7, 93
    li a0, 0
    ecall
