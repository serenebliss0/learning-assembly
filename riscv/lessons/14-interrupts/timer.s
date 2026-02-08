# timer.s - Timer interrupt demonstration
# Shows periodic timer interrupt handling

.section .data
msg_setup:
    .string "Setting up timer...\n"
msg_setup_len = . - msg_setup

msg_tick:
    .string "Tick!\n"
msg_tick_len = . - msg_tick

msg_tock:
    .string "Tock!\n"
msg_tock_len = . - msg_tock

msg_done:
    .string "Timer demo complete\n"
msg_done_len = . - msg_done

# Timer state
.align 4
tick_count:
    .word 0

timer_interval:
    .word 100000           # Ticks between interrupts (platform-dependent timing)

.section .text
.globl _start

_start:
    # Print setup message
    li a7, 64
    li a0, 1
    la a1, msg_setup
    li a2, msg_setup_len
    ecall
    
    # === Initialize timer ===
    # In real code:
    # 1. Read current mtime
    # 2. Add interval to get mtimecmp
    # 3. Write mtimecmp
    
    # Example (pseudo-code, platform-specific):
    # li t0, 0x0200BFF8     # mtime address
    # ld t1, 0(t0)          # Read current time
    # la t2, timer_interval
    # lw t2, 0(t2)          # Load interval
    # add t1, t1, t2        # Calculate next interrupt
    # li t0, 0x02004000     # mtimecmp address
    # sd t1, 0(t0)          # Set compare value
    
    # === Enable timer interrupt ===
    # li t0, 0x80           # MTIE bit
    # csrs mie, t0
    
    # === Set trap vector ===
    # la t0, trap_handler
    # csrw mtvec, t0
    
    # === Enable global interrupts ===
    # csrsi mstatus, 0x8
    
    # === Main loop ===
    # Wait for some timer ticks
    li t0, 10
wait_loop:
    # Check tick count
    la t1, tick_count
    lw t2, 0(t1)
    bge t2, t0, done
    
    # Busy wait (in real code, could use WFI)
    # wfi                   # Wait for interrupt
    j wait_loop

done:
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

# === Timer Interrupt Handler ===
.align 4
trap_handler:
    # Save minimal context
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw a7, 28(sp)
    
    # Increment tick counter
    la t0, tick_count
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    
    # === Acknowledge timer interrupt ===
    # Update mtimecmp to clear pending interrupt
    # li t0, 0x02004000     # mtimecmp address
    # ld t1, 0(t0)          # Read current mtimecmp
    # la t2, timer_interval
    # lw t2, 0(t2)
    # add t1, t1, t2        # Add interval
    # sd t1, 0(t0)          # Write new mtimecmp
    
    # Print tick or tock alternately
    la t0, tick_count
    lw t0, 0(t0)
    andi t0, t0, 1         # Check if odd or even
    beqz t0, print_tick

print_tock:
    li a7, 64
    li a0, 1
    la a1, msg_tock
    li a2, msg_tock_len
    ecall
    j timer_return

print_tick:
    li a7, 64
    li a0, 1
    la a1, msg_tick
    li a2, msg_tick_len
    ecall

timer_return:
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
    
    # Return from interrupt
    # mret
    ret
