# trap_handler.s - More complete trap handler example
# This demonstrates the structure of a real trap handler

.section .data
.align 4
# Exception message strings
msg_illegal:
    .string "Illegal instruction exception\n"
msg_illegal_len = . - msg_illegal

msg_breakpoint:
    .string "Breakpoint exception\n"
msg_breakpoint_len = . - msg_breakpoint

msg_ecall:
    .string "Ecall exception\n"
msg_ecall_len = . - msg_ecall

msg_load_fault:
    .string "Load access fault\n"
msg_load_fault_len = . - msg_load_fault

msg_store_fault:
    .string "Store access fault\n"
msg_store_fault_len = . - msg_store_fault

msg_unknown:
    .string "Unknown exception\n"
msg_unknown_len = . - msg_unknown

msg_interrupt:
    .string "Interrupt received\n"
msg_interrupt_len = . - msg_interrupt

# Context save area
.align 4
saved_context:
    .space 128             # Space for all registers

.section .text
.globl trap_handler
.align 4

trap_handler:
    # === Save ALL registers ===
    # In a real trap handler, we must save all registers
    # that we might use, to avoid corrupting user state
    
    # Use mscratch to save one register temporarily
    # csrw mscratch, sp     # Save sp
    
    # Get pointer to save area
    la sp, saved_context
    
    # Save all general-purpose registers
    sw x1, 0(sp)           # ra
    sw x2, 4(sp)           # sp (will fix later)
    sw x3, 8(sp)           # gp
    sw x4, 12(sp)          # tp
    sw x5, 16(sp)          # t0
    sw x6, 20(sp)          # t1
    sw x7, 24(sp)          # t2
    sw x8, 28(sp)          # s0/fp
    sw x9, 32(sp)          # s1
    sw x10, 36(sp)         # a0
    sw x11, 40(sp)         # a1
    sw x12, 44(sp)         # a2
    sw x13, 48(sp)         # a3
    sw x14, 52(sp)         # a4
    sw x15, 56(sp)         # a5
    sw x16, 60(sp)         # a6
    sw x17, 64(sp)         # a7
    sw x18, 68(sp)         # s2
    sw x19, 72(sp)         # s3
    sw x20, 76(sp)         # s4
    sw x21, 80(sp)         # s5
    sw x22, 84(sp)         # s6
    sw x23, 88(sp)         # s7
    sw x24, 92(sp)         # s8
    sw x25, 96(sp)         # s9
    sw x26, 100(sp)        # s10
    sw x27, 104(sp)        # s11
    sw x28, 108(sp)        # t3
    sw x29, 112(sp)        # t4
    sw x30, 116(sp)        # t5
    sw x31, 120(sp)        # t6
    
    # Restore actual sp from mscratch and save it
    # csrr t0, mscratch
    # sw t0, 4(sp)
    
    # === Read exception information ===
    # csrr a0, mcause       # a0 = exception cause
    # csrr a1, mepc         # a1 = exception PC
    # csrr a2, mtval        # a2 = additional info
    
    # For this demo, use dummy values
    li a0, 0               # Assume no exception
    li a1, 0
    li a2, 0
    
    # === Check if interrupt or exception ===
    srli t0, a0, 31        # Get interrupt bit
    bnez t0, is_interrupt
    
is_exception:
    # It's a synchronous exception
    # Get exception code (lower 31 bits)
    andi t0, a0, 0x7FFFFFFF
    
    # Dispatch based on exception code
    li t1, 0
    beq t0, t1, handle_instr_misaligned
    
    li t1, 2
    beq t0, t1, handle_illegal_instr
    
    li t1, 3
    beq t0, t1, handle_breakpoint_trap
    
    li t1, 4
    beq t0, t1, handle_load_misaligned
    
    li t1, 5
    beq t0, t1, handle_load_fault_trap
    
    li t1, 6
    beq t0, t1, handle_store_misaligned
    
    li t1, 7
    beq t0, t1, handle_store_fault_trap
    
    li t1, 8
    beq t0, t1, handle_ecall_u
    
    li t1, 9
    beq t0, t1, handle_ecall_s
    
    li t1, 11
    beq t0, t1, handle_ecall_m
    
    # Unknown exception
    j handle_unknown_exception
    
is_interrupt:
    # It's an asynchronous interrupt
    andi t0, a0, 0x7FFFFFFF  # Get interrupt code
    
    li t1, 3
    beq t0, t1, handle_software_interrupt
    
    li t1, 7
    beq t0, t1, handle_timer_interrupt
    
    li t1, 11
    beq t0, t1, handle_external_interrupt
    
    j handle_unknown_interrupt

# === Exception handlers ===
handle_instr_misaligned:
    # PC is not aligned to instruction boundary
    j trap_done

handle_illegal_instr:
    # Invalid instruction
    # Print message (simplified)
    j trap_done

handle_breakpoint_trap:
    # ebreak instruction
    j trap_done

handle_load_misaligned:
    # Unaligned load address
    j trap_done

handle_load_fault_trap:
    # Can't read from address
    j trap_done

handle_store_misaligned:
    # Unaligned store address
    j trap_done

handle_store_fault_trap:
    # Can't write to address
    j trap_done

handle_ecall_u:
    # System call from user mode
    # This is the normal syscall path
    # Dispatch based on a7 register
    j trap_done

handle_ecall_s:
    # System call from supervisor mode
    j trap_done

handle_ecall_m:
    # System call from machine mode
    j trap_done

handle_unknown_exception:
    # Unknown exception type
    j trap_done

# === Interrupt handlers ===
handle_software_interrupt:
    # Software interrupt (IPI)
    j trap_done

handle_timer_interrupt:
    # Timer interrupt
    j trap_done

handle_external_interrupt:
    # External hardware interrupt
    j trap_done

handle_unknown_interrupt:
    # Unknown interrupt type
    j trap_done

trap_done:
    # === Adjust mepc if necessary ===
    # For ecall/ebreak, we need to skip the instruction
    # csrr t0, mcause
    # andi t0, t0, 0x7FFFFFFF
    # li t1, 3               # Breakpoint
    # beq t0, t1, skip_instr
    # li t1, 8               # Ecall from U
    # beq t0, t1, skip_instr
    # li t1, 9               # Ecall from S
    # beq t0, t1, skip_instr
    # li t1, 11              # Ecall from M
    # beq t0, t1, skip_instr
    # j restore_context
    
skip_instr:
    # csrr t0, mepc
    # addi t0, t0, 4         # Skip the instruction
    # csrw mepc, t0
    
restore_context:
    # === Restore all registers ===
    la sp, saved_context
    
    lw x1, 0(sp)           # ra
    # Skip x2 (sp) for now
    lw x3, 8(sp)           # gp
    lw x4, 12(sp)          # tp
    lw x5, 16(sp)          # t0
    lw x6, 20(sp)          # t1
    lw x7, 24(sp)          # t2
    lw x8, 28(sp)          # s0/fp
    lw x9, 32(sp)          # s1
    lw x10, 36(sp)         # a0
    lw x11, 40(sp)         # a1
    lw x12, 44(sp)         # a2
    lw x13, 48(sp)         # a3
    lw x14, 52(sp)         # a4
    lw x15, 56(sp)         # a5
    lw x16, 60(sp)         # a6
    lw x17, 64(sp)         # a7
    lw x18, 68(sp)         # s2
    lw x19, 72(sp)         # s3
    lw x20, 76(sp)         # s4
    lw x21, 80(sp)         # s5
    lw x22, 84(sp)         # s6
    lw x23, 88(sp)         # s7
    lw x24, 92(sp)         # s8
    lw x25, 96(sp)         # s9
    lw x26, 100(sp)        # s10
    lw x27, 104(sp)        # s11
    lw x28, 108(sp)        # t3
    lw x29, 112(sp)        # t4
    lw x30, 116(sp)        # t5
    lw x31, 120(sp)        # t6
    
    # Restore sp last
    lw x2, 4(sp)           # sp
    
    # === Return from trap ===
    # mret                  # Return to mepc, restore privilege/interrupts
    ret                    # Simplified for this demo
