# exceptions.s - Basic exception handling demonstration
# Shows how to trigger and handle exceptions

.section .data
msg_start:
    .string "Starting exception demo...\n"
msg_start_len = . - msg_start

msg_ecall:
    .string "About to trigger ecall...\n"
msg_ecall_len = . - msg_ecall

msg_handled:
    .string "Exception handled successfully!\n"
msg_handled_len = . - msg_handled

msg_ebreak:
    .string "About to trigger ebreak...\n"
msg_ebreak_len = . - msg_ebreak

msg_done:
    .string "All exceptions handled!\n"
msg_done_len = . - msg_done

exception_count:
    .word 0

.align 4                   # Trap vector must be aligned
trap_vector:
    .word 0

.section .text
.globl _start

_start:
    # Print start message
    li a7, 64
    li a0, 1
    la a1, msg_start
    li a2, msg_start_len
    ecall
    
    # === Setup: Install trap handler ===
    # Note: In bare-metal, we'd set mtvec
    # In Linux, the kernel handles this
    # This is demonstrative code
    
    # la t0, trap_handler
    # csrw mtvec, t0        # Set trap vector (requires M-mode)
    
    # === Example 1: ecall (system call) ===
    # Print ecall message
    li a7, 64
    li a0, 1
    la a1, msg_ecall
    li a2, msg_ecall_len
    ecall                  # This is an exception!
    
    # If we get here, syscall was handled by kernel
    
    # === Example 2: ebreak (breakpoint) ===
    # Print ebreak message
    li a7, 64
    li a0, 1
    la a1, msg_ebreak
    li a2, msg_ebreak_len
    ecall
    
    # ebreak                # Uncomment to trigger breakpoint
    # Note: In Linux, this sends SIGTRAP to process
    
    # === Done ===
    li a7, 64
    li a0, 1
    la a1, msg_done
    li a2, msg_done_len
    ecall
    
    # Exit
    li a7, 93
    li a0, 0
    ecall

# This is a simplified trap handler
# In reality, trap handlers need to:
# 1. Save all registers
# 2. Determine exception cause
# 3. Handle the exception
# 4. Restore registers
# 5. Return with mret
trap_handler:
    # Save context (simplified)
    addi sp, sp, -64
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    
    # Read exception cause
    # csrr t0, mcause       # What caused the exception?
    # csrr t1, mepc         # Where did it occur?
    # csrr t2, mtval        # Additional info
    
    # Check if it's an interrupt (bit 31 set)
    # srli t3, t0, 31
    # bnez t3, handle_interrupt
    
handle_exception:
    # Get exception code (bits 30:0)
    # andi t0, t0, 0x7FFFFFFF
    
    # Check exception type
    # li t1, 8              # Ecall from U-mode
    # beq t0, t1, handle_ecall
    
    # li t1, 3              # Breakpoint
    # beq t0, t1, handle_breakpoint
    
    # Unknown exception - just return
    j trap_return
    
handle_ecall:
    # Handle system call
    # In real OS, dispatch to syscall handler
    j trap_return
    
handle_breakpoint:
    # Handle breakpoint
    # In real debugger, stop and wait for commands
    j trap_return
    
handle_interrupt:
    # Handle interrupt
    j trap_return
    
trap_return:
    # Increment mepc by 4 to skip the trapping instruction
    # (for ecall/ebreak)
    # csrr t0, mepc
    # addi t0, t0, 4
    # csrw mepc, t0
    
    # Restore context
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    addi sp, sp, 64
    
    # Return from trap
    # mret                  # Requires M-mode
    ret                    # Simplified for this demo
