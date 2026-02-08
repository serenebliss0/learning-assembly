# Lesson 14: Interrupt Handling - Responding to External Events

Interrupts are the heartbeat of responsive systems. They allow your code to react instantly to external events—timer ticks, keyboard presses, network packets—without wasting CPU cycles polling. Mastering interrupts is essential for real-time systems, operating systems, and embedded programming.

## Learning Objectives

By the end of this lesson, you'll:
- Understand the difference between interrupts and exceptions
- Master the three types of RISC-V interrupts (timer, external, software)
- Configure interrupt enable/disable mechanisms
- Work with interrupt-related CSRs (mie, mip, mstatus)
- Understand interrupt priorities and how they're resolved
- Implement timer interrupts for periodic tasks
- Write proper interrupt service routines (ISRs)
- Handle interrupt nesting and reentrancy
- Measure and optimize interrupt latency

## What Are Interrupts?

**Interrupts** are **asynchronous exceptions** triggered by events **external to the currently executing instruction**. Unlike synchronous exceptions (illegal instructions, page faults, ecall), interrupts can happen at any time.

### Interrupts vs. Exceptions

| Aspect | **Interrupts** | **Exceptions** |
|--------|----------------|----------------|
| **Timing** | Asynchronous (any time) | Synchronous (specific instruction) |
| **Cause** | External event | Instruction execution |
| **Source** | Hardware/software signal | Instruction side-effect |
| **PC saved** | Current or next instruction | Faulting instruction |
| **Examples** | Timer, keyboard, network | Illegal instruction, ecall, page fault |

**Key point:** Both use the same trap mechanism (CSRs, mtvec, mret) but have different causes and timing.

### When Do Interrupts Occur?

Interrupts can happen:
1. **Between instructions** - most common
2. **During multi-cycle instructions** - rare, implementation-dependent
3. **Never during critical sections** - when interrupts are disabled

## Types of RISC-V Interrupts

RISC-V defines **three standard interrupt types** at each privilege level:

| Interrupt | mcause Code | Description | Use Case |
|-----------|-------------|-------------|----------|
| **Software Interrupt** | 0x80000003 (M-mode) | Inter-processor interrupt | IPI, synchronization |
| **Timer Interrupt** | 0x80000007 (M-mode) | Timer expired | Scheduling, timeouts |
| **External Interrupt** | 0x8000000B (M-mode) | External hardware | Peripherals, I/O devices |

**Note:** The high bit (bit 31) is set to indicate interrupt (vs. exception).

### Machine-Mode Interrupt Codes

```
mcause value for interrupts (bit 31 = 1):
0x80000003 - Machine software interrupt (MSI)
0x80000007 - Machine timer interrupt (MTI)  
0x8000000B - Machine external interrupt (MEI)

mcause value for supervisor-mode (when delegated):
0x80000001 - Supervisor software interrupt (SSI)
0x80000005 - Supervisor timer interrupt (STI)
0x80000009 - Supervisor external interrupt (SEI)
```

## Interrupt Enable/Disable Mechanisms

RISC-V has a **two-level interrupt enable system**:

### Level 1: Global Interrupt Enable (mstatus.MIE)

The `mstatus` register has a global interrupt enable bit:

```
mstatus.MIE (bit 3):
  0 = All interrupts disabled
  1 = Interrupts enabled (subject to mie mask)
```

**Usage:**
```asm
# Disable all interrupts
csrci mstatus, 0x8      # Clear MIE bit (bit 3)

# Enable all interrupts
csrsi mstatus, 0x8      # Set MIE bit (bit 3)
```

### Level 2: Individual Interrupt Enable (mie)

The `mie` register enables/disables **specific interrupt types**:

```
mie register bits:
Bit 11 - MEIE - Machine external interrupt enable
Bit 7  - MTIE - Machine timer interrupt enable
Bit 3  - MSIE - Machine software interrupt enable
```

**Usage:**
```asm
# Enable timer interrupts only
li t0, 0x80             # Bit 7
csrw mie, t0

# Enable both timer and external interrupts
li t0, 0x880            # Bits 7 and 11
csrw mie, t0

# Disable timer interrupts
li t0, 0x80
csrc mie, t0            # Clear bit 7
```

### Interrupt Enable Logic

For an interrupt to fire:
```
Interrupt fires if:
  (mstatus.MIE == 1) AND 
  (mie.MTIE/MEIE/MSIE == 1) AND 
  (mip.MTIP/MEIP/MSIP == 1)
```

## Control and Status Registers for Interrupts

### mie - Machine Interrupt Enable

Controls which interrupt types are enabled:

| Bit | Name | Description |
|-----|------|-------------|
| 11 | MEIE | Machine external interrupt enable |
| 9 | SEIE | Supervisor external interrupt enable |
| 7 | MTIE | Machine timer interrupt enable |
| 5 | STIE | Supervisor timer interrupt enable |
| 3 | MSIE | Machine software interrupt enable |
| 1 | SSIE | Supervisor software interrupt enable |

### mip - Machine Interrupt Pending

Shows which interrupts are **pending** (waiting to be handled):

| Bit | Name | Description |
|-----|------|-------------|
| 11 | MEIP | Machine external interrupt pending |
| 9 | SEIP | Supervisor external interrupt pending |
| 7 | MTIP | Machine timer interrupt pending |
| 5 | STIP | Supervisor timer interrupt pending |
| 3 | MSIP | Machine software interrupt pending |
| 1 | SSIP | Supervisor software interrupt pending |

**Note:** These bits are typically **read-only** and set by hardware when interrupt arrives.

### mstatus - Machine Status

Critical bits for interrupts:

| Bit | Name | Description |
|-----|------|-------------|
| 7 | MPIE | Previous MIE value (saved on trap) |
| 3 | MIE | Global interrupt enable |

**Trap behavior:**
```
On trap entry:
  mstatus.MPIE ← mstatus.MIE  # Save old enable
  mstatus.MIE ← 0              # Disable interrupts

On mret:
  mstatus.MIE ← mstatus.MPIE   # Restore old enable
```

## Interrupt Priorities

When **multiple interrupts are pending**, RISC-V uses fixed priority:

| Priority | Interrupt | Reason |
|----------|-----------|--------|
| **Highest** | Machine external (MEI) | Critical hardware events |
| **Medium** | Machine software (MSI) | Inter-processor communication |
| **Lowest** | Machine timer (MTI) | Can be delayed slightly |

**Note:** Higher-priority interrupts preempt lower-priority ones if both are pending.

## Timer Interrupts

Timer interrupts are the most commonly used interrupt type. They enable:
- **Task scheduling** - switch between tasks periodically
- **Timeouts** - detect when operations take too long
- **Periodic sampling** - read sensors at regular intervals
- **Watchdog timers** - detect system hangs

### RISC-V Timer Architecture

RISC-V has two timer-related registers:

| Register | Access | Description |
|----------|--------|-------------|
| `mtime` | Read-only | Current time (64-bit counter) |
| `mtimecmp` | Read-write | Timer compare value |

**Timer interrupt fires when:** `mtime >= mtimecmp`

### Setting Up Timer Interrupts

```asm
# 1. Set mtimecmp to future value
la t0, mtimecmp_addr
ld t1, 0(t0)           # Read current mtimecmp (or mtime)
li t2, 1000000         # Add 1M cycles (~1ms at 1GHz)
add t1, t1, t2
sd t1, 0(t0)           # Write new mtimecmp

# 2. Enable timer interrupts in mie
li t0, 0x80            # MTIE bit
csrs mie, t0

# 3. Enable global interrupts
li t0, 0x8             # MIE bit
csrs mstatus, t0
```

### Memory-Mapped Timer Registers

**Important:** `mtime` and `mtimecmp` are **memory-mapped**, not CSRs:

```
Standard RISC-V addresses (platform-dependent):
mtime:    0x0200BFF8 (64-bit, read-only)
mtimecmp: 0x02004000 (64-bit, read-write)

These addresses vary by platform!
Check your platform's memory map.
```

## Writing Interrupt Handlers

### Basic Interrupt Handler Structure

```asm
interrupt_handler:
    # 1. Save context
    addi sp, sp, -64
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    # ... save other registers
    
    # 2. Determine interrupt cause
    csrr t0, mcause
    
    # 3. Check if it's an interrupt (bit 31 set)
    bgez t0, not_interrupt  # If positive, it's an exception
    
    # 4. Get interrupt code (bits 30:0)
    slli t0, t0, 1
    srli t0, t0, 1         # Clear bit 31
    
    # 5. Dispatch to specific handler
    li t1, 7
    beq t0, t1, handle_timer_interrupt
    
    li t1, 11
    beq t0, t1, handle_external_interrupt
    
    # ... handle other types
    
handle_timer_interrupt:
    # Handle timer interrupt
    call service_timer
    j interrupt_return
    
handle_external_interrupt:
    # Handle external interrupt
    call service_external
    j interrupt_return
    
interrupt_return:
    # 6. Restore context
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    # ... restore other registers
    addi sp, sp, 64
    
    # 7. Return from interrupt
    mret
```

### Critical Rules for ISRs

1. **Save ALL used registers** - any register you touch must be saved
2. **Keep it short** - long ISRs increase interrupt latency
3. **Don't call blocking functions** - no I/O, no sleep
4. **Clear the interrupt source** - or it will fire again immediately
5. **Be reentrant** - if nesting enabled, ISR may interrupt itself

## The Code: Basic Interrupt Setup

Create a file called `interrupts.s`:

```asm
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
```

## The Code: Timer Interrupt Example

Create a file called `timer.s`:

```asm
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
    .word 100000           # Ticks between interrupts

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
```

## Building and Running

### Compile

```bash
# Compile interrupts.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o interrupts.o interrupts.s
riscv64-linux-gnu-ld -m elf32lriscv -o interrupts interrupts.o

# Compile timer.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o timer.o timer.s
riscv64-linux-gnu-ld -m elf32lriscv -o timer timer.o
```

### Run with QEMU

```bash
qemu-riscv32 ./interrupts
qemu-riscv32 ./timer
```

## Important Notes About These Examples

**Privilege Level Limitations:**

These examples are **demonstrative** and show the structure of interrupt handling. In reality:

1. **Linux userspace can't access CSRs** - runs in U-mode without privilege
2. **Interrupt CSR operations require M-mode** - will cause illegal instruction exception
3. **Real interrupts are handled by kernel** - your program doesn't see them
4. **mtime/mtimecmp access requires privilege** - not accessible from userspace

To truly experiment with interrupts, you need:
- **Bare-metal environment** (no OS)
- **M-mode execution** (firmware/bootloader level)
- **Real hardware or full system emulator** (QEMU system mode, not user mode)
- **Platform-specific memory map** (for mtime/mtimecmp addresses)

The examples demonstrate **concepts and structure** but won't execute interrupt operations when run as Linux programs.

## Experiments to Try

### 1. **Multiple Interrupt Types**
Set up both timer and external interrupts, see which one fires first.

### 2. **Interrupt Masking**
Disable specific interrupts using `mie`, verify they don't fire.

### 3. **Measure Interrupt Latency**
Read `mtime` at interrupt entry and exit to measure overhead.

### 4. **Interrupt Coalescing**
Handle multiple pending interrupts in a single handler invocation.

### 5. **Priority Testing**
Trigger multiple interrupts simultaneously, observe priority handling.

## Deep Dive: Interrupt Latency

**Interrupt latency** is the time from when an interrupt occurs to when the ISR starts executing.

### Components of Latency

```
Total latency = 
  Hardware detection time +
  Pipeline drain time +
  Context save time +
  Handler dispatch time
```

**Typical values (rough estimates):**
- Hardware detection: 1-2 cycles
- Pipeline drain: 3-5 cycles (depends on pipeline depth)
- Context save: 2 cycles per register (e.g., 32 cycles for 16 registers)
- Dispatch overhead: 5-10 cycles

**Total:** ~50-100 cycles for minimal ISR

### Reducing Latency

1. **Save fewer registers** - only save what you'll use
2. **Use vectored interrupts** - skip dispatch logic
3. **Keep ISRs short** - defer work to main loop
4. **Optimize critical paths** - use inline assembly for hot paths
5. **Enable interrupt nesting** - let higher priority interrupt lower priority

## Deep Dive: Interrupt Nesting

By default, **interrupts are disabled during trap handling** (`mstatus.MIE = 0`).

### Enabling Nested Interrupts

```asm
trap_handler:
    # Save context
    addi sp, sp, -32
    sw ra, 0(sp)
    # ... save other registers
    
    # Re-enable interrupts for nesting
    csrsi mstatus, 0x8     # Set MIE bit
    
    # Now higher-priority interrupts can preempt us
    
    # Do interrupt work
    call handle_interrupt_work
    
    # Disable interrupts before returning
    csrci mstatus, 0x8     # Clear MIE bit
    
    # Restore context
    lw ra, 0(sp)
    # ... restore other registers
    addi sp, sp, 32
    
    mret
```

**Caution:**
- Can cause deep nesting and stack overflow
- Makes debugging harder
- Only enable if you need low latency for high-priority interrupts

## Deep Dive: Wait for Interrupt (WFI)

The `wfi` instruction puts the CPU in **low-power mode** until an interrupt arrives:

```asm
main_loop:
    # Do work
    call process_data
    
    # Sleep until next interrupt
    wfi                    # Wait for interrupt
    
    # Interrupt handler runs, then returns here
    j main_loop
```

**Benefits:**
- **Saves power** - CPU stops executing
- **Reduces heat** - lower power = less heat
- **Battery life** - crucial for embedded systems

**Note:** `wfi` is a **hint** - CPU may wake up for other reasons.

## Deep Dive: Software Interrupts

Software interrupts (IPI - Inter-Processor Interrupts) are used for **multi-core synchronization**:

### Triggering Software Interrupt

```asm
# Trigger software interrupt on this core
# This is platform-specific, typically memory-mapped
li t0, 0x02000000      # CLINT base address (example)
li t1, 1
sw t1, 0(t0)           # Set MSIP bit

# The interrupt will fire if enabled
```

### Use Cases

1. **Cross-core communication** - wake up another core
2. **Deferred work** - schedule work for later
3. **Synchronization** - coordinate between cores

## Common Mistakes

### 1. **Forgetting to Clear Interrupt Source**
```asm
timer_handler:
    # Handle timer
    # ... do work
    mret               # WRONG - interrupt still pending!
```

**Fix:** Update `mtimecmp` to clear `MTIP`:
```asm
timer_handler:
    # Update mtimecmp
    la t0, mtimecmp_addr
    ld t1, 0(t0)
    li t2, 1000000
    add t1, t1, t2
    sd t1, 0(t0)       # Clears MTIP
    mret
```

### 2. **Not Saving Enough Registers**
```asm
interrupt_handler:
    sw t0, 0(sp)       # Only save t0
    # Use t1, t2, a0... # WRONG - corrupting caller's registers!
```

**Fix:** Save ALL registers you use.

### 3. **Doing Too Much in ISR**
```asm
timer_handler:
    # WRONG - Too much work in ISR!
    call complex_processing
    call write_to_disk
    call network_send
    mret
```

**Fix:** Set a flag, defer work to main loop:
```asm
timer_handler:
    la t0, timer_flag
    li t1, 1
    sw t1, 0(t0)       # Set flag
    mret

main_loop:
    la t0, timer_flag
    lw t1, 0(t0)
    beqz t1, main_loop
    
    # Clear flag
    sw zero, 0(t0)
    
    # Do the work here
    call complex_processing
    j main_loop
```

### 4. **Incorrect mtvec Mode**
```asm
la t0, trap_handler
csrw mtvec, t0         # WRONG if t0 is not 4-byte aligned!
```

**Fix:** Ensure alignment and set mode bits:
```asm
.align 4
trap_handler:
    # ...

# Setup
la t0, trap_handler
ori t0, t0, 0          # Direct mode (bits [1:0] = 00)
csrw mtvec, t0
```

### 5. **Using WFI Without Enabling Interrupts**
```asm
# WRONG - WFI will hang forever!
csrci mstatus, 0x8     # Disable interrupts
wfi                    # Will never wake up!
```

**Fix:** Enable interrupts before WFI:
```asm
csrsi mstatus, 0x8     # Enable interrupts
wfi                    # Will wake on interrupt
```

## Interrupt CSR Quick Reference

### Machine-Mode Interrupt CSRs

| Address | Name | Bits | Description |
|---------|------|------|-------------|
| 0x304 | mie | [11:0] | Interrupt enable (MEIE, MTIE, MSIE) |
| 0x344 | mip | [11:0] | Interrupt pending (MEIP, MTIP, MSIP) |
| 0x300 | mstatus | [3] | MIE - global interrupt enable |

### Key Bit Positions

```
mie/mip register:
Bit 11 - MEIE/MEIP - External interrupt
Bit 7  - MTIE/MTIP - Timer interrupt
Bit 3  - MSIE/MSIP - Software interrupt

mstatus register:
Bit 7 - MPIE - Previous interrupt enable
Bit 3 - MIE  - Current interrupt enable
```

## Key Takeaways

1. **Interrupts are asynchronous** - can happen at any time, unlike exceptions
2. **Three types: timer, external, software** - each has specific use cases
3. **Two-level enable: global (MIE) + individual (mie)** - both must be set
4. **mip shows pending interrupts** - hardware sets these bits
5. **Fixed priority: external > software > timer** - hardware resolves conflicts
6. **Timer uses mtimecmp** - fires when mtime >= mtimecmp
7. **Must clear interrupt source** - or it fires again immediately
8. **Keep ISRs short** - defer work to avoid high latency
9. **WFI saves power** - sleep until interrupt arrives
10. **Nesting requires care** - can overflow stack if not careful

## Additional Resources

- [RISC-V Privileged Specification](https://riscv.org/technical/specifications/) - Chapter 3 (Machine-Level ISA)
- [RISC-V Platform Spec](https://github.com/riscv/riscv-platform-specs) - Timer and interrupt mappings
- [RISC-V Interrupt Handling](https://danielmangum.com/posts/risc-v-bytes-privilege-levels/)
- [Writing ISRs](https://interrupt.memfault.com/blog/cortex-m-rtos-context-switching)
- [CLINT Specification](https://github.com/riscv/riscv-aclint) - Core Local Interruptor

## What's Next?

In **Lesson 15: Monitor/Debugger**, we'll learn how to:
- Build a simple machine-mode monitor
- Implement a debugger interface
- Handle breakpoints and single-stepping
- Inspect and modify system state
- Debug bare-metal RISC-V code

Debugging is essential for systems programming - let's master it! 🚀
