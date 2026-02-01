# Project 4: Mini RISC-V Emulator 🖥️

## Overview

Build a simple RISC-V emulator that can execute a subset of RISC-V instructions. This project will deepen your understanding of:
- How CPUs execute instructions
- Instruction encoding and decoding
- Register file management
- Memory management
- The fetch-decode-execute cycle

## Features

Your emulator should support:

### Core Instructions (RV32I Base)
- **Arithmetic**: `add`, `sub`, `addi`
- **Logical**: `and`, `or`, `xor`, `andi`, `ori`, `xori`
- **Shifts**: `sll`, `srl`, `sra`, `slli`, `srli`, `srai`
- **Comparison**: `slt`, `sltu`, `slti`, `sltiu`
- **Loads**: `lw`, `lh`, `lb`, `lhu`, `lbu`
- **Stores**: `sw`, `sh`, `sb`
- **Branches**: `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
- **Jumps**: `jal`, `jalr`
- **Upper immediate**: `lui`, `auipc`

### Emulator Components

1. **Register File**: 32 integer registers (x0-x31)
2. **Memory**: Simulated RAM (e.g., 64KB)
3. **PC (Program Counter)**: Current instruction address
4. **Instruction Decoder**: Parse instruction encoding
5. **Executor**: Execute decoded instructions

## Architecture

```
┌──────────────────────────────────────┐
│         RISC-V Emulator              │
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │  Fetch                         │  │
│  │  - Read instruction from memory│  │
│  │  - Increment PC                │  │
│  └────────────────────────────────┘  │
│              ↓                       │
│  ┌────────────────────────────────┐  │
│  │  Decode                        │  │
│  │  - Parse opcode, registers     │  │
│  │  - Extract immediate values    │  │
│  └────────────────────────────────┘  │
│              ↓                       │
│  ┌────────────────────────────────┐  │
│  │  Execute                       │  │
│  │  - Perform operation           │  │
│  │  - Update registers/memory     │  │
│  │  - Update PC                   │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

## Implementation Guide

### Step 1: Define Data Structures

```assembly
.data
# Register file (32 registers × 4 bytes)
registers:    .space 128

# Memory (64KB)
memory:       .space 65536

# Program counter
pc:           .word 0

# Current instruction
current_inst: .word 0
```

### Step 2: Instruction Encoding

RISC-V instructions are 32 bits with different formats:

**R-Type** (Register-register operations):
```
31      25 24  20 19  15 14  12 11   7 6      0
[funct7  ][rs2  ][rs1  ][funct3][rd   ][opcode]
```

**I-Type** (Immediate operations):
```
31             20 19  15 14  12 11   7 6      0
[imm[11:0]      ][rs1  ][funct3][rd   ][opcode]
```

**S-Type** (Store operations):
```
31      25 24  20 19  15 14  12 11   7 6      0
[imm[11:5]][rs2  ][rs1  ][funct3][imm[4:0]][opcode]
```

### Step 3: Fetch Instruction

```assembly
# Function: fetch
# Fetch instruction from memory at PC
# Output: a0 = instruction

fetch:
    la t0, pc
    lw t1, 0(t0)          # t1 = PC value
    
    la t2, memory
    add t3, t2, t1        # t3 = memory[PC]
    lw a0, 0(t3)          # Load instruction
    
    # Increment PC
    addi t1, t1, 4
    sw t1, 0(t0)
    
    ret
```

### Step 4: Decode Instruction

```assembly
# Function: decode
# Decode instruction into components
# Input: a0 = instruction
# Output: Decoded components in specific registers

decode:
    # Extract opcode (bits 6:0)
    andi t0, a0, 0x7F
    
    # Extract rd (bits 11:7)
    srli t1, a0, 7
    andi t1, t1, 0x1F
    
    # Extract funct3 (bits 14:12)
    srli t2, a0, 12
    andi t2, t2, 0x7
    
    # Extract rs1 (bits 19:15)
    srli t3, a0, 15
    andi t3, t3, 0x1F
    
    # Extract rs2 (bits 24:20)
    srli t4, a0, 20
    andi t4, t4, 0x1F
    
    # Extract funct7 (bits 31:25) for R-type
    srli t5, a0, 25
    andi t5, t5, 0x7F
    
    # Store decoded values
    # ... (implementation dependent)
    
    ret
```

### Step 5: Execute Instructions

Implement execution for each instruction type:

```assembly
# Function: execute_add
# Execute ADD instruction: rd = rs1 + rs2
# Input: t1=rd, t3=rs1, t4=rs2

execute_add:
    # Load register values
    la t0, registers
    slli t5, t3, 2
    add t5, t0, t5
    lw a0, 0(t5)          # a0 = registers[rs1]
    
    slli t6, t4, 2
    add t6, t0, t6
    lw a1, 0(t6)          # a1 = registers[rs2]
    
    # Perform addition
    add a2, a0, a1
    
    # Store result in rd (skip if rd = x0)
    beqz t1, execute_add_done
    slli t5, t1, 2
    add t5, t0, t5
    sw a2, 0(t5)
    
execute_add_done:
    ret
```

### Step 6: Main Emulation Loop

```assembly
main:
    # Load program into memory
    jal ra, load_program
    
emulation_loop:
    # Fetch
    jal ra, fetch
    mv s0, a0             # s0 = instruction
    
    # Check for halt (or end condition)
    beqz s0, emulation_done
    
    # Decode
    mv a0, s0
    jal ra, decode
    
    # Execute
    jal ra, execute
    
    # Continue loop
    j emulation_loop
    
emulation_done:
    # Print final state
    jal ra, print_registers
    
    # Exit
    li a7, 10
    ecall
```

## Testing

### Test Programs

Create simple test programs to verify your emulator:

```assembly
# Test 1: Simple arithmetic
addi x1, x0, 5        # x1 = 5
addi x2, x0, 10       # x2 = 10
add  x3, x1, x2       # x3 = 15
sub  x4, x2, x1       # x4 = 5
```

```assembly
# Test 2: Branches
addi x1, x0, 5
addi x2, x0, 5
beq  x1, x2, equal    # Should branch
addi x3, x0, 1        # Should skip
equal:
addi x3, x0, 2        # x3 = 2
```

```assembly
# Test 3: Memory operations
addi x1, x0, 100      # x1 = 100
addi x2, x0, 0x1000   # x2 = address
sw   x1, 0(x2)        # Store 100 at address
lw   x3, 0(x2)        # Load back (x3 = 100)
```

### Verification

- Print register file after execution
- Compare with expected results
- Test edge cases (x0 writes, overflow, etc.)

## Skills Practiced

- ✅ Instruction encoding/decoding
- ✅ Binary operations and bit manipulation
- ✅ Memory management
- ✅ State machine implementation
- ✅ Debugging complex systems
- ✅ Deep understanding of CPU operation

## Tips

1. **Start simple** - Implement `addi` first
2. **Test each instruction** - Before moving to the next
3. **Use assertions** - Verify assumptions
4. **Print state** - Debug by printing registers/memory
5. **Reference the spec** - RISC-V spec has all encodings
6. **Handle x0** - Remember x0 is always zero

## Extensions

- Add support for M extension (mul, div)
- Implement F/D extensions (floating-point)
- Add cycle counting and performance analysis
- Create a debugger interface
- Support ELF file loading
- Add virtual memory support
- Implement pipelining simulation

## Provided Code

A basic framework is provided in `emulator.s` that includes:
- Register file management
- Memory simulation
- Basic instruction decoding
- Example implementations

## Resources

- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- [Lesson 08: Bit Manipulation](../../lessons/08-bits/)
- [RISC-V Instruction Formats](../../reference/instructions.md)

## Next Steps

After building your emulator:
- Understand how real CPUs work
- Study pipelining and superscalar execution
- Explore out-of-order execution
- Learn about caches and memory hierarchy

---

Building an emulator is the best way to truly understand a CPU! 🔧
