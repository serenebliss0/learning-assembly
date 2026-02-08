# interrupts.s - Basic interrupt handling demonstration
# Shows structure of interrupt setup and handling

.section .data
msg_start:
    .string "Setting up interrupts...\n"
msg_start_len = . - msg_start

msg_enabled:
    .string "Interrupts enabled!\n"
msg_enabled_len = . - msg_enabled

msg_interrupt:
    .string "Interrupt received!\n"
msg_interrupt_len = . - msg_interrupt

msg_done:
    .string "Done\n"
msg_done_len = . - msg_done

# Interrupt counter
.align 4
interrupt_count:
    .word 0

.section .text
.globl _start

_start:
    # Print startup message
    li a7, 64
    li a0, 1
    la a1, msg_start
    li a2, msg_start_len
    ecall
    
    # === Setup interrupt vector ===
    # NOTE: In real bare-metal code, you would:
    # la t0, trap_vector
    # csrw mtvec, t0
    
    # === Enable specific interrupts ===
    # Enable machine timer interrupt (MTIE)
    # li t0, 0x80           # Bit 7 = MTIE
    # csrs mie, t0
    
    # Enable machine external interrupt (MEIE)
    # li t0, 0x800          # Bit 11 = MEIE  
    # csrs mie, t0
    
    # === Enable global interrupts ===
    # csrsi mstatus, 0x8    # Set MIE bit
    
    # Print enabled message
    li a7, 64
    li a0, 1
    la a1, msg_enabled
    li a2, msg_enabled_len
    ecall
    
    # === Main loop ===
    # In a real system, this would be your main program
    # Interrupts would fire asynchronously
    li t0, 10
main_loop:
    # Simulate work
    addi t0, t0, -1
    bnez t0, main_loop
    
    # Print done message
    li a7, 64
    li a0, 1
    la a1, msg_done
    li a2, msg_done_len
    ecall
    
    # Exit
    li a7, 93
    li a0, 0
    ecall

# === Interrupt Vector Table ===
# In vectored mode, this would be a table of jump instructions
.align 4
trap_vector:
    j trap_handler         # All traps go here in direct mode

# === Trap Handler ===
.align 4
trap_handler:
    # Save context
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw a7, 28(sp)
    
    # Read mcause
    # csrr t0, mcause
    
    # Check if interrupt (bit 31 set)
    # bgez t0, handle_exception
    
    # Get interrupt code
    # slli t0, t0, 1
    # srli t0, t0, 1        # Clear bit 31
    
    # Dispatch based on code
    # li t1, 7              # Timer interrupt
    # beq t0, t1, handle_timer_int
    
    # li t1, 11             # External interrupt
    # beq t0, t1, handle_external_int
    
handle_timer_int:
    # Increment counter
    la t0, interrupt_count
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    
    # Clear timer interrupt by updating mtimecmp
    # This is platform-specific
    
    # Print message
    li a7, 64
    li a0, 1
    la a1, msg_interrupt
    li a2, msg_interrupt_len
    ecall
    
    j trap_return

handle_external_int:
    # Handle external interrupt
    # Read peripheral status registers
    # Service the device
    # Clear interrupt source
    
    j trap_return

handle_exception:
    # Handle synchronous exception
    j trap_return

trap_return:
    # Restore context
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    lw a7, 28(sp)
    addi sp, sp, 32
    
    # Return from trap
    # mret                  # In real M-mode code
    ret                    # Simplified for demo
