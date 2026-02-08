# Lesson 13: Exception Handling - When Things Go Wrong

Exceptions are the foundation of modern operating systems. They allow the system to respond to errors, handle system calls, manage interrupts, and implement virtual memory. Understanding exceptions is essential for systems programming.

## Learning Objectives

By the end of this lesson, you'll:
- Understand what exceptions are and why they're needed
- Know the different types of exceptions (synchronous vs asynchronous)
- Master Control and Status Registers (CSRs) for exception handling
- Write basic exception handlers
- Use `ecall` and `ebreak` instructions
- Understand privilege levels and how exceptions change privilege
- Handle different exception causes
- Return from exceptions properly

## What Are Exceptions?

An **exception** (also called a **trap**) is an **unscheduled control transfer** from user code to kernel code. They occur when:

1. **Synchronous exceptions** - caused by executing instruction:
   - System calls (`ecall`)
   - Breakpoints (`ebreak`)
   - Illegal instructions
   - Misaligned accesses
   - Page faults

2. **Asynchronous exceptions (interrupts)** - external events:
   - Timer interrupts
   - External hardware interrupts
   - Software interrupts

When an exception occurs:
1. **Current execution stops**
2. **PC and status are saved** to CSRs
3. **Privilege level changes** (usually to machine mode)
4. **PC jumps to trap handler** (exception vector)
5. **Handler processes exception**
6. **Returns to user code** (or terminates process)

## RISC-V Privilege Levels

RISC-V defines **three privilege levels**:

| Level | Name | Typical Use | Description |
|-------|------|-------------|-------------|
| 0 | User (U-mode) | Applications | Least privileged |
| 1 | Supervisor (S-mode) | OS kernel | Manages virtual memory |
| 3 | Machine (M-mode) | Bootloader/firmware | Most privileged |

**Note:** Level 2 (Hypervisor) exists but is optional.

**Key points:**
- Lower privilege can't access higher privilege resources
- Exceptions typically trap to a higher privilege level
- Trap handlers run in higher privilege mode

## Control and Status Registers (CSRs)

CSRs are **special registers** for configuring and controlling the CPU. They're accessed with special instructions.

### CSR Access Instructions

| Instruction | Operation | Description |
|-------------|-----------|-------------|
| `csrr rd, csr` | rd = CSR | Read CSR |
| `csrw csr, rs` | CSR = rs | Write CSR |
| `csrs csr, rs` | CSR \|= rs | Set bits in CSR |
| `csrc csr, rs` | CSR &= ~rs | Clear bits in CSR |
| `csrrw rd, csr, rs` | Swap: rd = CSR, CSR = rs | Atomic read-write |
| `csrrs rd, csr, rs` | rd = CSR, CSR \|= rs | Read and set bits |
| `csrrc rd, csr, rs` | rd = CSR, CSR &= ~rs | Read and clear bits |

Each has an immediate version (`csrrwi`, `csrrsi`, `csrrci`) that uses a 5-bit immediate instead of register.

### Machine-Mode Exception CSRs

| CSR | Name | Purpose |
|-----|------|---------|
| `mstatus` | Machine Status | CPU status flags |
| `misa` | Machine ISA | Available extensions |
| `mie` | Machine Interrupt Enable | Interrupt enable bits |
| `mtvec` | Machine Trap Vector | Trap handler address |
| `mscratch` | Machine Scratch | Temporary storage |
| `mepc` | Machine Exception PC | PC when exception occurred |
| `mcause` | Machine Cause | Exception/interrupt cause |
| `mtval` | Machine Trap Value | Additional exception info |
| `mip` | Machine Interrupt Pending | Pending interrupt bits |

### Understanding mcause

The `mcause` register tells you **why the exception occurred**:

**Format:**
```
[31] [30:0]
 |      |
 |      +-- Exception Code
 |
 +-- Interrupt bit (1=interrupt, 0=exception)
```

**Exception Codes (bit 31 = 0):**
| Code | Name | Description |
|------|------|-------------|
| 0 | Instruction address misaligned | PC not aligned |
| 1 | Instruction access fault | Can't fetch instruction |
| 2 | Illegal instruction | Invalid opcode |
| 3 | Breakpoint | `ebreak` executed |
| 4 | Load address misaligned | Unaligned load |
| 5 | Load access fault | Can't read memory |
| 6 | Store address misaligned | Unaligned store |
| 7 | Store access fault | Can't write memory |
| 8 | Environment call from U-mode | `ecall` in user mode |
| 9 | Environment call from S-mode | `ecall` in supervisor mode |
| 11 | Environment call from M-mode | `ecall` in machine mode |
| 12 | Instruction page fault | Page not present |
| 13 | Load page fault | Load from unmapped page |
| 15 | Store page fault | Store to unmapped page |

**Interrupt Codes (bit 31 = 1):**
| Code | Name | Description |
|------|------|-------------|
| 3 | Machine software interrupt | Software triggered |
| 7 | Machine timer interrupt | Timer expired |
| 11 | Machine external interrupt | External device |

### Understanding mstatus

The `mstatus` register contains CPU status flags:

**Important bits:**
- **MIE** (bit 3): Machine Interrupt Enable (global interrupt enable)
- **MPIE** (bit 7): Previous MIE value (before trap)
- **MPP** (bits 12-11): Previous privilege mode

When a trap occurs:
1. `MIE` → `MPIE` (save interrupt enable)
2. `current_privilege` → `MPP` (save privilege level)
3. `MIE` ← 0 (disable interrupts)
4. `current_privilege` ← M (switch to machine mode)

When returning from trap (`mret`):
1. `MPIE` → `MIE` (restore interrupt enable)
2. `MPP` → `current_privilege` (restore privilege)
3. `PC` ← `mepc` (return to saved PC)

## The Code: Basic Exception Handling

Create a file called `exceptions.s`:

```asm
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
```

## The Code: Comprehensive Trap Handler

Create a file called `trap_handler.s`:

```asm
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
```

## Building and Running

### Compile

```bash
# Compile exceptions.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o exceptions.o exceptions.s
riscv64-linux-gnu-ld -m elf32lriscv -o exceptions exceptions.o

# Compile trap_handler.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o trap_handler.o trap_handler.s
riscv64-linux-gnu-ld -m elf32lriscv -o trap_handler trap_handler.o
```

### Run with QEMU

```bash
qemu-riscv32 ./exceptions
qemu-riscv32 ./trap_handler
```

## Important Notes About These Examples

**Privilege Level Limitations:**
These examples are **demonstrative**. In reality:

1. **Linux userspace programs can't access CSRs** - they run in U-mode
2. **CSR instructions require S-mode or M-mode** - will trigger illegal instruction exception in U-mode
3. **Trap handlers run in kernel** - your program doesn't see them
4. **mret is privileged** - only kernel can execute it

To truly experiment with exception handling, you need:
- **Bare-metal code** (no OS)
- **M-mode execution** (bootloader/firmware)
- **Special hardware or emulator** (like Spike or custom QEMU)

The examples show the **structure and concepts** but won't actually execute the CSR operations when run as Linux programs.

## Experiments to Try

### 1. **Trigger Illegal Instruction**
Insert an invalid instruction (`.word 0x00000000`) and see what happens.

### 2. **Breakpoint Handling**
Uncomment the `ebreak` instruction and run under GDB to see breakpoint handling.

### 3. **Examine Kernel Trap Handler**
On a Linux system, look at kernel source to see real trap handlers.

### 4. **Syscall Tracing**
Use `strace` to see all syscalls your program makes and how they're handled.

## Deep Dive: The ecall Journey

What happens when you execute `ecall`?

1. **CPU detects ecall** instruction
2. **Hardware actions:**
   - `mstatus.MIE` → `mstatus.MPIE` (save interrupt enable)
   - Current privilege → `mstatus.MPP` (save privilege mode)
   - `PC` → `mepc` (save program counter)
   - Privilege → M-mode (switch to machine mode)
   - Exception code (8/9/11) → `mcause`
   - `mtvec` → `PC` (jump to trap handler)
   - `mstatus.MIE` ← 0 (disable interrupts)
3. **Trap handler executes:**
   - Saves registers
   - Reads `mcause` to determine it's an ecall
   - Reads `a7` to get syscall number
   - Dispatches to appropriate syscall handler
   - Executes syscall
   - Puts return value in `a0`
   - Adjusts `mepc` += 4 (skip ecall instruction)
   - Restores registers
   - Executes `mret`
4. **mret instruction:**
   - `mepc` → `PC` (restore program counter)
   - `mstatus.MPIE` → `mstatus.MIE` (restore interrupt enable)
   - `mstatus.MPP` → current privilege (restore privilege mode)
5. **User code resumes** at instruction after `ecall`

This entire process takes hundreds of CPU cycles!

## Deep Dive: Direct vs Vectored Traps

The `mtvec` register has two modes:

**Format:**
```
[31:2] [1:0]
  |      |
  |      +-- MODE (0=Direct, 1=Vectored)
  |
  +-- BASE (trap handler address, 4-byte aligned)
```

**Direct mode (MODE=0):**
- All traps jump to BASE
- Handler must check `mcause` to dispatch

**Vectored mode (MODE=1):**
- Synchronous exceptions jump to BASE
- Interrupt N jumps to BASE + (N × 4)
- Faster interrupt handling (no dispatch needed)

Most systems use **vectored mode** for better interrupt performance.

## Common Mistakes

### 1. **Forgetting to Save Registers**
```asm
trap_handler:
    # WRONG - Using registers without saving!
    li t0, 0
    csrr t1, mcause
    # ...
```

Always save registers you'll modify!

### 2. **Not Adjusting mepc**
```asm
# After handling ecall/ebreak
mret                   # WRONG - Will execute same instruction again!
```

Must increment `mepc` to skip the trapping instruction.

### 3. **Using CSRs in User Mode**
```asm
# WRONG - This will trigger illegal instruction exception!
csrr t0, mstatus       # Requires M-mode or S-mode!
```

CSR instructions are privileged.

### 4. **Stack Overflow in Handler**
```asm
trap_handler:
    addi sp, sp, -16   # WRONG - sp might be invalid!
```

Use `mscratch` or dedicated stack for trap handlers.

### 5. **Re-enabling Interrupts Too Early**
```asm
trap_handler:
    csrsi mstatus, 0x8  # WRONG - Enabling interrupts in handler!
```

Can cause nested traps and stack overflow.

## CSR Quick Reference

### Machine-Mode CSRs (Most Common)

| Address | Name | R/W | Description |
|---------|------|-----|-------------|
| 0x300 | mstatus | RW | Machine status |
| 0x301 | misa | RW | ISA and extensions |
| 0x304 | mie | RW | Interrupt enable |
| 0x305 | mtvec | RW | Trap vector base |
| 0x340 | mscratch | RW | Scratch register |
| 0x341 | mepc | RW | Exception program counter |
| 0x342 | mcause | RW | Exception cause |
| 0x343 | mtval | RW | Trap value |
| 0x344 | mip | RW | Interrupt pending |

### Supervisor-Mode CSRs (When Using OS)

| Address | Name | R/W | Description |
|---------|------|-----|-------------|
| 0x100 | sstatus | RW | Supervisor status |
| 0x104 | sie | RW | Supervisor interrupt enable |
| 0x105 | stvec | RW | Supervisor trap vector |
| 0x140 | sscratch | RW | Supervisor scratch |
| 0x141 | sepc | RW | Supervisor exception PC |
| 0x142 | scause | RW | Supervisor cause |
| 0x143 | stval | RW | Supervisor trap value |
| 0x144 | sip | RW | Supervisor interrupt pending |

## Key Takeaways

1. **Exceptions are unscheduled control transfers** - from user to kernel
2. **Two types: synchronous (exceptions) and asynchronous (interrupts)**
3. **CSRs control exception handling** - mtvec, mstatus, mepc, mcause
4. **mcause tells you what happened** - exception code or interrupt number
5. **mepc saves the PC** - where exception occurred
6. **Trap handlers must save registers** - preserve user state
7. **Must adjust mepc for ecall/ebreak** - skip the instruction
8. **mret returns from trap** - restores privilege and PC
9. **Privilege levels protect system** - U < S < M
10. **CSR instructions are privileged** - can't use from userspace

## Additional Resources

- [RISC-V Privileged Specification](https://riscv.org/technical/specifications/)
- [RISC-V CSR Documentation](https://github.com/riscv/riscv-isa-manual)
- [Understanding Traps](https://danielmangum.com/posts/risc-v-bytes-privilege-levels/)
- [Writing Trap Handlers](https://osblog.stephenmarz.com/ch10.html)

## What's Next?

In **Lesson 14: Interrupt Handling**, we'll focus specifically on asynchronous exceptions:
- Different types of interrupts
- Interrupt enable/disable mechanisms
- Timer interrupts
- Writing interrupt service routines
- Interrupt priorities and nesting

Interrupts are crucial for responsive systems - let's master them! 🚀
