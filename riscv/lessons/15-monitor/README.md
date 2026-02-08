# Lesson 15: Building a Monitor/Debugger - Interactive System Control

A monitor (or debugger) is one of the most powerful tools for understanding and controlling a computer system. It allows you to peek into memory, modify registers, step through code, and understand what's happening at the lowest level. Building your own monitor teaches you how debuggers like GDB work internally.

## Learning Objectives

By the end of this lesson, you'll:
- Understand what a monitor/debugger is and why it's essential
- Design a command-line interface for interactive control
- Implement memory inspection commands (dump, examine)
- Build register display and modification features
- Understand breakpoint mechanisms (software vs hardware)
- Implement single-stepping for code execution
- Parse and execute text commands
- Handle user input and output efficiently
- Build a complete working monitor program
- Debug bare-metal RISC-V programs

## What is a Monitor/Debugger?

A **monitor** (also called **debug monitor** or **ROM monitor**) is a small program that:
1. **Runs in privileged mode** (M-mode or S-mode)
2. **Provides interactive control** via command-line interface
3. **Allows inspection and modification** of system state
4. **Facilitates debugging** of other programs

### Monitor vs. Debugger

| Aspect | **Monitor** | **Debugger** |
|--------|-------------|--------------|
| **Where runs** | On target machine | Separate machine (often) |
| **Control** | Direct hardware access | Via debug interface |
| **Typical use** | Embedded/bare-metal | Application debugging |
| **Interface** | Serial/console | GUI or CLI |
| **Examples** | PMON, U-Boot shell | GDB, LLDB |

**Key insight:** Debuggers like GDB often communicate with a monitor running on the target system!

### When Do You Need a Monitor?

Monitors are essential for:
- **Bare-metal development** - No OS to help debug
- **Bootloader debugging** - Before OS is loaded
- **Embedded systems** - Limited debugging tools
- **Hardware bringup** - Testing new hardware
- **OS kernel development** - Debugging the debugger
- **Learning** - Understanding how systems work

## Monitor Architecture

### Basic Components

```
┌─────────────────────────────────────┐
│         Monitor Program             │
├─────────────────────────────────────┤
│  Command Parser                     │
│  ├─ Tokenizer (split input)         │
│  ├─ Command lookup                  │
│  └─ Argument parsing                │
├─────────────────────────────────────┤
│  Command Handlers                   │
│  ├─ dump    (show memory)           │
│  ├─ examine (inspect location)      │
│  ├─ set     (modify register/mem)   │
│  ├─ get     (read register/mem)     │
│  ├─ run     (execute program)       │
│  ├─ step    (single-step)           │
│  ├─ break   (set breakpoint)        │
│  └─ help    (show commands)         │
├─────────────────────────────────────┤
│  Utility Functions                  │
│  ├─ Print hex values                │
│  ├─ Parse hex strings               │
│  ├─ Read/write memory               │
│  └─ Save/restore state              │
└─────────────────────────────────────┘
```

### Execution Flow

```
1. Initialize → 2. Print prompt → 3. Read command
                        ↑                  ↓
                        |            4. Parse input
                        |                  ↓
                        |            5. Lookup command
                        |                  ↓
                        |            6. Execute handler
                        |                  ↓
                        └───────── 7. Display result
```

## Command-Line Interface Design

### Essential Commands

Every monitor needs these basic commands:

| Command | Syntax | Description |
|---------|--------|-------------|
| **dump** | `dump <addr> [len]` | Display memory contents |
| **examine** | `examine <addr>` | Inspect single location |
| **set** | `set <reg> <value>` | Set register value |
| **get** | `get <reg>` | Read register value |
| **run** | `run [addr]` | Execute program |
| **step** | `step [n]` | Single-step n instructions |
| **break** | `break <addr>` | Set breakpoint |
| **continue** | `continue` | Resume execution |
| **help** | `help [cmd]` | Show help |
| **quit** | `quit` | Exit monitor |

### Command Design Principles

1. **Keep commands short** - Users type them frequently
2. **Make common tasks easy** - Default arguments for typical use
3. **Be consistent** - Similar commands have similar syntax
4. **Provide feedback** - Confirm actions, show errors clearly
5. **Support abbreviations** - `d` for dump, `x` for examine

### Example Session

```
Monitor v1.0
> dump 0x10000 16
10000: 00 00 00 93  13 01 00 00  97 00 00 00  e7 80 00 00
> set a0 42
a0 = 0x0000002a
> step
PC: 0x10004  Inst: addi a0, zero, 0
> help dump
dump <addr> [len] - Display memory contents
  addr: Start address (hex)
  len:  Number of bytes (default: 64)
> quit
```

## Memory Inspection

### The dump Command

The `dump` command displays a region of memory in hex+ASCII format:

```
> dump 0x10000 64
10000: 48 65 6c 6c 6f 2c 20 57 6f 72 6c 64 21 0a 00 00  Hello, World!...
10010: 6d 6f 6e 69 74 6f 72 20 76 31 2e 30 0a 00 00 00  monitor v1.0....
10020: 00 00 00 00 00 00 00 00 93 00 00 00 13 01 00 00  ................
10030: 17 01 00 00 13 01 01 00 6f 00 80 00 00 00 00 00  ........o.......
```

**Format breakdown:**
- **Address** (left): Where this line starts
- **Hex bytes** (middle): 16 bytes in hexadecimal
- **ASCII** (right): Printable characters (or `.`)

### Implementation Strategy

```asm
dump_command:
    # Parse arguments
    # 1. Get start address
    # 2. Get length (default: 64 bytes)
    
    # Loop through memory
    li t0, 0              # Counter
dump_loop:
    # Print address at start of line
    andi t1, t0, 0xf
    bnez t1, skip_addr
    mv a0, s0             # Current address
    call print_hex32
    
skip_addr:
    # Print byte as hex
    lbu a0, 0(s0)
    call print_hex8
    
    # Print space
    li a0, ' '
    call print_char
    
    # Check if end of line (16 bytes)
    addi t0, t0, 1
    andi t1, t0, 0xf
    bnez t1, not_eol
    
    # Print ASCII representation
    call print_ascii_line
    
not_eol:
    addi s0, s0, 1        # Next address
    blt t0, s1, dump_loop # Continue if more bytes
    ret
```

### The examine Command

The `examine` command provides detailed information about a single location:

```
> examine 0x10000
0x10000: 0x93000000  [addi zero, zero, 0]
         Binary: 10010011 00000000 00000000 00000000
         Opcode: I-type (0x13)
         rd: x0  rs1: x0  imm: 0
```

This disassembles the instruction and shows its encoding.

## Register Display and Modification

### Reading Registers

In a real monitor, you'd need to save all registers when entering the monitor:

```asm
monitor_entry:
    # Save ALL registers
    la t0, saved_registers
    sw x1, 0(t0)          # Save ra
    sw x2, 4(t0)          # Save sp
    sw x3, 8(t0)          # Save gp
    # ... save all 32 registers
    
    # Now we can inspect them
    call monitor_loop
    
    # Restore and return
    la t0, saved_registers
    lw x1, 0(t0)
    lw x2, 4(t0)
    # ... restore all
    ret
```

### The get Command

```
> get a0
a0 (x10) = 0x0000002a (42)

> get pc
pc = 0x00010004
```

### The set Command

```
> set a0 100
a0 = 0x00000064 (was 0x0000002a)

> set pc 0x10000
pc = 0x00010000 (was 0x00010004)
```

**Warning:** Setting PC or sp can crash the system!

### Displaying All Registers

```
> registers
x0  (zero) = 0x00000000    x16 (a6)  = 0x00000000
x1  (ra)   = 0x00010234    x17 (a7)  = 0x00000040
x2  (sp)   = 0x7fff8000    x18 (s2)  = 0x00000000
x3  (gp)   = 0x00011000    x19 (s3)  = 0x00000000
x4  (tp)   = 0x00000000    x20 (s4)  = 0x00000000
x5  (t0)   = 0x00000010    x21 (s5)  = 0x00000000
x6  (t1)   = 0x00000001    x22 (s6)  = 0x00000000
x7  (t2)   = 0x00000000    x23 (s7)  = 0x00000000
x8  (s0/fp)= 0x7fff8000    x24 (s8)  = 0x00000000
x9  (s1)   = 0x00000000    x25 (s9)  = 0x00000000
x10 (a0)   = 0x0000002a    x26 (s10) = 0x00000000
x11 (a1)   = 0x00000000    x27 (s11) = 0x00000000
x12 (a2)   = 0x00000000    x28 (t3)  = 0x00000000
x13 (a3)   = 0x00000000    x29 (t4)  = 0x00000000
x14 (a4)   = 0x00000000    x30 (t5)  = 0x00000000
x15 (a5)   = 0x00000000    x31 (t6)  = 0x00000000
pc = 0x00010004
```

## Breakpoint Concepts

### Software Breakpoints

**Software breakpoints** work by replacing an instruction with a **breakpoint instruction**:

```
Original code:          With breakpoint:
0x10000: addi a0, a0, 1    0x10000: ebreak
0x10004: addi a1, a1, 2    0x10004: addi a1, a1, 2
```

**How it works:**
1. **Set breakpoint**: Replace instruction with `ebreak`
2. **Execute**: When PC reaches breakpoint, CPU traps
3. **Monitor entry**: Trap handler enters monitor
4. **Restore**: Replace `ebreak` with original instruction
5. **Continue**: User can inspect, then continue

**Implementation:**
```asm
set_breakpoint:
    # Save original instruction
    la t0, breakpoint_table
    lw t1, 0(a0)          # Read original instruction
    sw t1, 4(t0)          # Save it
    sw a0, 0(t0)          # Save address
    
    # Replace with ebreak
    li t1, 0x00100073     # ebreak instruction
    sw t1, 0(a0)          # Write breakpoint
    
    # Flush instruction cache
    fence.i
    ret
```

**Challenge:** Software breakpoints modify code!
- Can't use in ROM
- Need to track what you changed
- Must flush I-cache after modification

### Hardware Breakpoints

**Hardware breakpoints** use **trigger registers** (part of Debug spec):

```
tselect - Select trigger
tdata1  - Trigger configuration
tdata2  - Trigger address/data
```

**Advantages:**
- Don't modify code
- Work in ROM
- Can break on data access (watchpoints)
- Can break on specific conditions

**Disadvantages:**
- Limited number (typically 2-4)
- Not always available
- More complex to configure

### Watchpoints

**Watchpoints** break when memory is accessed:

```
> watch 0x1000 write
Watchpoint set: break on write to 0x1000

> continue
[Stopped: Write to 0x1000 from PC 0x10234]
```

Implemented with hardware triggers that match load/store addresses.

## Single-Stepping

**Single-stepping** executes one instruction then returns to monitor.

### Software Single-Step

Use `ebreak` after each instruction:

```asm
single_step:
    # Get current PC
    la t0, saved_pc
    lw t1, 0(t0)
    
    # Set breakpoint at next instruction
    addi t1, t1, 4        # PC + 4
    sw t1, 0(t0)
    call set_breakpoint
    
    # Resume execution
    j resume_program
```

**Problem:** What about branches?
- Need to decode instruction
- Calculate all possible next PCs
- Set breakpoint at each

### Hardware Single-Step

Use `dcsr.step` (Debug Control and Status Register):

```asm
# Enable single-step mode
li t0, 1 << 2             # step bit
csrs dcsr, t0

# Execute one instruction
dret                      # Debug return

# Trap immediately after instruction
# (Handled by debug trap handler)
```

**Advantage:** Hardware handles everything!

**Problem:** Requires Debug Module (not always available).

## Command Parsing Techniques

### Tokenization

Split input into tokens (words):

```asm
tokenize:
    # Input: a0 = input string
    # Output: a0 = token array, a1 = token count
    
    la t0, token_buffer
    li t1, 0              # Token count
    
tokenize_loop:
    # Skip whitespace
    lbu t2, 0(a0)
    li t3, ' '
    beq t2, t3, skip_space
    li t3, '\t'
    beq t2, t3, skip_space
    beqz t2, tokenize_done
    
    # Copy token
    sb t2, 0(t0)
    addi t0, t0, 1
    addi a0, a0, 1
    j tokenize_loop
    
skip_space:
    addi a0, a0, 1
    j tokenize_loop
    
tokenize_done:
    sb zero, 0(t0)        # Null terminate
    mv a0, t0
    mv a1, t1
    ret
```

### Command Lookup

Use a **command table** to find handlers:

```asm
.data
command_table:
    .string "dump"
    .word cmd_dump
    .string "examine"
    .word cmd_examine
    .string "set"
    .word cmd_set
    .string "get"
    .word cmd_get
    .string "help"
    .word cmd_help
    .string "quit"
    .word cmd_quit
    .word 0               # End marker

.text
find_command:
    # Input: a0 = command string
    # Output: a0 = handler address (or 0)
    
    la t0, command_table
find_loop:
    lw t1, 0(t0)          # Load command name
    beqz t1, not_found
    
    # Compare strings
    mv a1, t1
    call strcmp
    beqz a0, found
    
    # Next entry
    addi t0, t0, 8        # Skip name + handler
    j find_loop
    
found:
    lw a0, 4(t0)          # Get handler address
    ret
    
not_found:
    li a0, 0
    ret
```

### Argument Parsing

Parse hex numbers, register names, etc.:

```asm
parse_hex:
    # Input: a0 = string (e.g., "0x1234" or "1234")
    # Output: a0 = number, a1 = success (0/1)
    
    li t0, 0              # Accumulator
    li t1, 0              # Digit count
    
    # Skip "0x" prefix
    lbu t2, 0(a0)
    li t3, '0'
    bne t2, t3, parse_loop
    lbu t2, 1(a0)
    li t3, 'x'
    bne t2, t3, parse_loop
    addi a0, a0, 2
    
parse_loop:
    lbu t2, 0(a0)
    beqz t2, parse_done
    
    # Convert hex digit
    call hex_to_nibble
    bltz a1, parse_error
    
    # Accumulate: result = (result << 4) | digit
    slli t0, t0, 4
    or t0, t0, a1
    
    addi t1, t1, 1
    addi a0, a0, 1
    j parse_loop
    
parse_done:
    mv a0, t0
    li a1, 1              # Success
    ret
    
parse_error:
    li a1, 0              # Failure
    ret
```

## Building a Simple Monitor

### Main Loop

```asm
monitor_main:
    # Initialize
    call init_monitor
    
main_loop:
    # Print prompt
    la a0, prompt
    call print_string
    
    # Read command line
    la a0, input_buffer
    li a1, 256
    call read_line
    
    # Tokenize
    la a0, input_buffer
    call tokenize
    
    # Empty line?
    beqz a1, main_loop
    
    # Find command
    la a0, token_buffer
    call find_command
    beqz a0, cmd_unknown
    
    # Execute command
    jalr a0
    
    j main_loop
    
cmd_unknown:
    la a0, msg_unknown
    call print_string
    j main_loop
```

### Command Handler Template

```asm
cmd_dump:
    # Save registers
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    # Parse arguments
    # token[1] = address
    # token[2] = length (optional)
    
    la a0, token_buffer + 16  # Second token
    call parse_hex
    beqz a1, arg_error
    mv s0, a0                  # s0 = address
    
    # Get length (default: 64)
    la a0, token_buffer + 32   # Third token
    lbu t0, 0(a0)
    beqz t0, use_default
    call parse_hex
    mv s1, a0
    j do_dump
    
use_default:
    li s1, 64
    
do_dump:
    # Display memory
    mv a0, s0
    mv a1, s1
    call dump_memory
    
    # Restore and return
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret
    
arg_error:
    la a0, msg_invalid_arg
    call print_string
    j cmd_dump + 24       # Jump to restore/return
```

## Complete Monitor Example

Here's the structure of our complete monitor:

```asm
# monitor.s - Main monitor program

.data
prompt:     .string "> "
input_buffer: .space 256
saved_regs:   .space 128      # 32 registers × 4 bytes

.text
.globl _start

_start:
    # Setup
    la sp, stack_top
    call init_monitor
    
    # Enter main loop
    j monitor_main

monitor_main:
    # (Main loop as shown above)

# Command handlers
cmd_dump:
    # (As shown above)

cmd_examine:
    # Display single location with details

cmd_set:
    # Modify register or memory

cmd_get:
    # Read register or memory

cmd_help:
    # Show help message

cmd_quit:
    # Exit monitor
    li a7, 93
    li a0, 0
    ecall

# Utility functions
print_hex8:
print_hex32:
parse_hex:
read_line:
# ...
```

## Building and Running

### Building the Monitor

```bash
# Assemble
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o monitor.o monitor.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o commands.o commands.s

# Link
riscv64-linux-gnu-ld -m elf32lriscv -o monitor monitor.o commands.o

# Test
spike --isa=RV32I pk monitor
```

### Running on QEMU

```bash
# Build for QEMU virt machine
riscv64-linux-gnu-as -march=rv32imac -mabi=ilp32 -o monitor.o monitor.s

# Link at ROM address
riscv64-linux-gnu-ld -m elf32lriscv -Ttext=0x80000000 -o monitor.elf monitor.o

# Convert to binary
riscv64-linux-gnu-objcopy -O binary monitor.elf monitor.bin

# Run
qemu-system-riscv32 -M virt -nographic -bios monitor.bin
```

### Running on Hardware

For real hardware (e.g., SiFive boards):
```bash
# Build with correct memory layout
riscv64-linux-gnu-ld -m elf32lriscv -T monitor.ld -o monitor.elf *.o

# Flash to board
openocd -f board.cfg -c "program monitor.elf verify reset exit"

# Connect via serial
screen /dev/ttyUSB0 115200
```

## Experiments

### Experiment 1: Basic Memory Inspection

```bash
# Build and run
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 monitor.s -o monitor.o
riscv64-linux-gnu-ld -m elf32lriscv monitor.o -o monitor
spike --isa=RV32I pk monitor

# Try these commands:
> help
> dump 0x10000 64
> examine 0x10000
```

**What to observe:**
- Command parsing works
- Memory displays in hex+ASCII
- Address alignment

### Experiment 2: Register Manipulation

```
> get a0
> set a0 42
> get a0
> set pc 0x10000
> get pc
```

**What to observe:**
- Register values change
- Hex and decimal display
- Invalid register names rejected

### Experiment 3: Command Parsing Edge Cases

```
> dump
> dump xyz
> dump 0x10000 abc
>     dump    0x10000    16
> DUMP 0x10000
```

**What to observe:**
- Error handling
- Whitespace handling
- Case sensitivity
- Default arguments

### Experiment 4: Memory Protection

```
> dump 0x0
> dump 0xFFFFFFFF
> set 0x0 12345
```

**What to observe:**
- Invalid address handling
- Potential segfaults
- Protection mechanisms

## Deep Dives

### Deep Dive 1: Instruction Disassembly

To implement `examine` properly, decode the instruction:

```asm
disassemble:
    # Input: a0 = instruction word
    # Output: print disassembled instruction
    
    # Extract opcode (bits 6:0)
    andi t0, a0, 0x7f
    
    # Check opcode
    li t1, 0x33           # R-type
    beq t0, t1, disasm_r_type
    
    li t1, 0x13           # I-type
    beq t0, t1, disasm_i_type
    
    # ... handle all types
    
disasm_r_type:
    # Extract fields
    srli t1, a0, 7
    andi t1, t1, 0x1f     # rd
    
    srli t2, a0, 15
    andi t2, t2, 0x1f     # rs1
    
    srli t3, a0, 20
    andi t3, t3, 0x1f     # rs2
    
    srli t4, a0, 25
    andi t4, t4, 0x7f     # funct7
    
    srli t5, a0, 12
    andi t5, t5, 0x7      # funct3
    
    # Lookup instruction
    # (Check funct3 + funct7)
    # Print mnemonic and operands
```

### Deep Dive 2: Efficient Command Tables

Use **perfect hashing** for fast lookup:

```asm
# Hash function: first char + length
hash_command:
    lbu t0, 0(a0)         # First char
    li t1, 0
count_loop:
    lbu t2, 0(a0)
    beqz t2, hash_done
    addi t1, t1, 1
    addi a0, a0, 1
    j count_loop
hash_done:
    add a0, t0, t1        # Hash = char + len
    andi a0, a0, 0x1f     # Mod 32
    ret

# Hash table (32 entries)
command_hash_table:
    .word 0, 0, cmd_dump, 0, 0, ...
```

This reduces lookup time from O(n) to O(1).

### Deep Dive 3: Input History

Implement command history with ring buffer:

```asm
.data
history_buffer: .space 4096   # 16 entries × 256 bytes
history_head: .word 0
history_tail: .word 0

add_history:
    # Add command to history
    la t0, history_head
    lw t1, 0(t0)
    
    # Copy to buffer
    la t2, history_buffer
    slli t3, t1, 8        # × 256
    add t2, t2, t3
    
    # Copy string
    # ...
    
    # Update head
    addi t1, t1, 1
    andi t1, t1, 0xf      # Mod 16
    sw t1, 0(t0)
    ret

# Support up-arrow to recall previous command
```

### Deep Dive 4: Breakpoint Management

Track multiple breakpoints:

```asm
.data
breakpoint_table:
    # Each entry: address (4 bytes) + original instruction (4 bytes)
    .space 64             # Support 8 breakpoints

num_breakpoints: .word 0

find_breakpoint:
    # Search for breakpoint by address
    la t0, breakpoint_table
    la t1, num_breakpoints
    lw t1, 0(t1)
    li t2, 0
find_bp_loop:
    beq t2, t1, not_found
    lw t3, 0(t0)
    beq t3, a0, found_bp
    addi t0, t0, 8
    addi t2, t2, 1
    j find_bp_loop
found_bp:
    mv a0, t0
    li a1, 1
    ret
not_found:
    li a1, 0
    ret
```

## Common Mistakes

### 1. **Not Validating Addresses**
```asm
cmd_dump:
    # WRONG - No validation!
    lw t0, 0(a0)          # Could be invalid address!
```

**Fix:** Check address range:
```asm
cmd_dump:
    # Check if address is valid
    li t0, 0x80000000
    bltu a0, t0, invalid_addr
    li t0, 0x80100000
    bgeu a0, t0, invalid_addr
    # OK, proceed
```

### 2. **Buffer Overflows in Input**
```asm
read_line:
    # WRONG - No bounds check!
read_loop:
    call getchar
    sb a0, 0(t0)
    addi t0, t0, 1
    j read_loop           # Infinite!
```

**Fix:** Check buffer size:
```asm
read_line:
    li t1, 0              # Count
read_loop:
    bge t1, a1, line_full # Check limit
    call getchar
    sb a0, 0(t0)
    addi t0, t0, 1
    addi t1, t1, 1
    j read_loop
```

### 3. **Forgetting to Flush I-Cache**
```asm
set_breakpoint:
    li t0, 0x00100073     # ebreak
    sw t0, 0(a0)
    ret                   # WRONG - I-cache still has old instruction!
```

**Fix:** Add fence.i:
```asm
set_breakpoint:
    li t0, 0x00100073
    sw t0, 0(a0)
    fence.i               # Flush instruction cache!
    ret
```

### 4. **Not Handling Empty Input**
```asm
parse_command:
    lbu t0, 0(a0)
    # WRONG - What if string is empty?
    call find_command
```

**Fix:** Check for empty string:
```asm
parse_command:
    lbu t0, 0(a0)
    beqz t0, empty_input  # Handle gracefully
    call find_command
```

### 5. **Modifying Code Under Execution**
```asm
# WRONG - Setting breakpoint at current PC!
> set pc 0x10000
> break 0x10000         # Will break immediately!
> continue              # Stuck in loop!
```

**Fix:** Warn user or handle specially:
```asm
set_breakpoint:
    la t0, saved_pc
    lw t0, 0(t0)
    beq a0, t0, warn_current_pc
    # ... set breakpoint
```

## Advanced Features

### Tab Completion

```asm
handle_tab:
    # Get partial command
    la a0, input_buffer
    call find_matches
    
    # One match? Complete it
    li t0, 1
    beq a1, t0, complete
    
    # Multiple? Show options
    call show_matches
    ret
```

### Command Aliases

```asm
.data
alias_table:
    .string "x"           # Short for examine
    .word cmd_examine
    .string "d"           # Short for dump
    .word cmd_dump
```

### Scripting Support

```asm
# Read commands from file
> source commands.txt

# Or batch mode
./monitor < script.txt
```

### Remote Debugging

```asm
# Monitor listens on serial port
# GDB connects via remote protocol
# Implements GDB remote serial protocol (RSP)
```

## Key Takeaways

1. **Monitors provide interactive control** - Essential for bare-metal debugging
2. **Command parsing is critical** - Tokenize, validate, execute
3. **Memory inspection is fundamental** - dump and examine commands
4. **Register access requires saved state** - Save on entry, restore on exit
5. **Software breakpoints modify code** - Replace instruction with ebreak
6. **Hardware breakpoints use triggers** - Don't modify code, limited number
7. **Single-stepping needs careful handling** - Calculate next PC(s) or use hardware
8. **Always validate input** - Addresses, arguments, commands
9. **Flush I-cache after code modification** - fence.i instruction
10. **Good UX matters** - Clear errors, helpful messages, consistent interface

## Additional Resources

- [RISC-V Debug Specification](https://riscv.org/technical/specifications/) - Debug module and triggers
- [GDB Remote Serial Protocol](https://sourceware.org/gdb/current/onlinedocs/gdb/Remote-Protocol.html) - How GDB communicates
- [OpenOCD](https://openocd.org/) - Open On-Chip Debugger
- [Debugging Embedded Systems](https://interrupt.memfault.com/blog/tag/debugging) - Practical guide
- [PMON Source Code](https://github.com/loongson/pmon) - Real monitor implementation
- [U-Boot Command Shell](https://github.com/u-boot/u-boot) - Bootloader monitor

## What's Next?

This is the final lesson in our RISC-V journey! You've learned:
- Basic instructions and registers
- Memory and addressing modes
- Functions and calling conventions
- System calls and exceptions
- Interrupts and privileged mode
- Building a complete monitor/debugger

**Where to go from here:**
- **Operating Systems** - Use your knowledge to build a simple OS
- **Embedded Systems** - Program real RISC-V hardware
- **Compiler Design** - Understand how compilers generate assembly
- **Computer Architecture** - Design your own RISC-V processor
- **Advanced Topics** - Vector extensions, hypervisor mode, formal verification

Congratulations on completing this course! You now have deep knowledge of RISC-V assembly and systems programming. Keep building, keep learning! 🚀
