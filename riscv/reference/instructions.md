# RISC-V Instruction Reference

Complete reference for RV32I base instruction set with extensions.

## Table of Contents
- [Instruction Formats](#instruction-formats)
- [Base Integer Instructions (RV32I)](#base-integer-instructions-rv32i)
- [Multiplication Extension (M)](#multiplication-extension-m)
- [Atomic Extension (A)](#atomic-extension-a)
- [Compressed Extension (C)](#compressed-extension-c)
- [Pseudo-Instructions](#pseudo-instructions)

## Instruction Formats

RISC-V has 6 base instruction formats:

### R-Type (Register-Register)
```
 31    25 24  20 19  15 14  12 11   7 6      0
[funct7  ][rs2  ][rs1  ][funct3][rd   ][opcode]
```
Used for: arithmetic, logical, shifts (register operands)

### I-Type (Immediate)
```
 31             20 19  15 14  12 11   7 6      0
[imm[11:0]      ][rs1  ][funct3][rd   ][opcode]
```
Used for: immediate arithmetic, loads, jalr, system calls

### S-Type (Store)
```
 31      25 24  20 19  15 14  12 11   7 6      0
[imm[11:5]][rs2  ][rs1  ][funct3][imm[4:0]][opcode]
```
Used for: store instructions

### B-Type (Branch)
```
 31   30    25 24  20 19  15 14  12 11  8 7    6      0
[imm12][imm[10:5]][rs2  ][rs1  ][funct3][imm[4:1]][imm11][opcode]
```
Used for: conditional branches

### U-Type (Upper Immediate)
```
 31                   12 11   7 6      0
[imm[31:12]            ][rd   ][opcode]
```
Used for: lui, auipc

### J-Type (Jump)
```
 31   30      21 20   19      12 11   7 6      0
[imm20][imm[10:1]][imm11][imm[19:12]][rd   ][opcode]
```
Used for: jal

## Base Integer Instructions (RV32I)

### Arithmetic Operations

#### ADD - Add
```assembly
add rd, rs1, rs2
```
- **Operation**: `rd = rs1 + rs2`
- **Format**: R-type
- **Example**: `add a0, a1, a2  # a0 = a1 + a2`

#### ADDI - Add Immediate
```assembly
addi rd, rs1, imm
```
- **Operation**: `rd = rs1 + sign_extend(imm)`
- **Format**: I-type
- **Range**: -2048 to 2047
- **Example**: `addi sp, sp, -16  # Allocate 16 bytes on stack`

#### SUB - Subtract
```assembly
sub rd, rs1, rs2
```
- **Operation**: `rd = rs1 - rs2`
- **Format**: R-type
- **Example**: `sub t0, t1, t2  # t0 = t1 - t2`

### Logical Operations

#### AND - Bitwise AND
```assembly
and rd, rs1, rs2
```
- **Operation**: `rd = rs1 & rs2`
- **Example**: `and t0, t1, t2  # Mask bits`

#### ANDI - AND Immediate
```assembly
andi rd, rs1, imm
```
- **Operation**: `rd = rs1 & sign_extend(imm)`
- **Example**: `andi t0, t1, 0xFF  # Keep lower 8 bits`

#### OR - Bitwise OR
```assembly
or rd, rs1, rs2
```
- **Operation**: `rd = rs1 | rs2`

#### ORI - OR Immediate
```assembly
ori rd, rs1, imm
```
- **Operation**: `rd = rs1 | sign_extend(imm)`

#### XOR - Bitwise XOR
```assembly
xor rd, rs1, rs2
```
- **Operation**: `rd = rs1 ^ rs2`
- **Example**: `xor t0, t1, t1  # Zero register (t0 = 0)`

#### XORI - XOR Immediate
```assembly
xori rd, rs1, imm
```
- **Operation**: `rd = rs1 ^ sign_extend(imm)`

### Shift Operations

#### SLL - Shift Left Logical
```assembly
sll rd, rs1, rs2
```
- **Operation**: `rd = rs1 << rs2[4:0]`
- **Example**: `sll t0, t1, t2  # Shift left by t2 bits`

#### SLLI - Shift Left Logical Immediate
```assembly
slli rd, rs1, shamt
```
- **Operation**: `rd = rs1 << shamt`
- **Range**: 0-31
- **Example**: `slli t0, t1, 3  # Multiply by 8`

#### SRL - Shift Right Logical
```assembly
srl rd, rs1, rs2
```
- **Operation**: `rd = rs1 >> rs2[4:0]` (unsigned)
- **Example**: `srl t0, t1, t2  # Unsigned shift right`

#### SRLI - Shift Right Logical Immediate
```assembly
srli rd, rs1, shamt
```
- **Operation**: `rd = rs1 >> shamt` (unsigned)
- **Example**: `srli t0, t1, 2  # Divide by 4 (unsigned)`

#### SRA - Shift Right Arithmetic
```assembly
sra rd, rs1, rs2
```
- **Operation**: `rd = rs1 >> rs2[4:0]` (signed, preserves sign bit)
- **Example**: `sra t0, t1, t2  # Signed shift right`

#### SRAI - Shift Right Arithmetic Immediate
```assembly
srai rd, rs1, shamt
```
- **Operation**: `rd = rs1 >> shamt` (signed)
- **Example**: `srai t0, t1, 1  # Divide by 2 (signed)`

### Comparison Operations

#### SLT - Set Less Than
```assembly
slt rd, rs1, rs2
```
- **Operation**: `rd = (rs1 < rs2) ? 1 : 0` (signed)
- **Example**: `slt t0, t1, t2  # t0 = 1 if t1 < t2 (signed)`

#### SLTI - Set Less Than Immediate
```assembly
slti rd, rs1, imm
```
- **Operation**: `rd = (rs1 < sign_extend(imm)) ? 1 : 0` (signed)

#### SLTU - Set Less Than Unsigned
```assembly
sltu rd, rs1, rs2
```
- **Operation**: `rd = (rs1 < rs2) ? 1 : 0` (unsigned)

#### SLTIU - Set Less Than Immediate Unsigned
```assembly
sltiu rd, rs1, imm
```
- **Operation**: `rd = (rs1 < sign_extend(imm)) ? 1 : 0` (unsigned)

### Load Instructions

#### LW - Load Word
```assembly
lw rd, offset(rs1)
```
- **Operation**: `rd = memory[rs1 + offset]` (32 bits)
- **Example**: `lw a0, 0(sp)  # Load word from stack`

#### LH - Load Halfword
```assembly
lh rd, offset(rs1)
```
- **Operation**: `rd = sign_extend(memory[rs1 + offset][15:0])`
- **Size**: 16 bits, sign-extended

#### LHU - Load Halfword Unsigned
```assembly
lhu rd, offset(rs1)
```
- **Operation**: `rd = zero_extend(memory[rs1 + offset][15:0])`
- **Size**: 16 bits, zero-extended

#### LB - Load Byte
```assembly
lb rd, offset(rs1)
```
- **Operation**: `rd = sign_extend(memory[rs1 + offset][7:0])`
- **Size**: 8 bits, sign-extended

#### LBU - Load Byte Unsigned
```assembly
lbu rd, offset(rs1)
```
- **Operation**: `rd = zero_extend(memory[rs1 + offset][7:0])`
- **Size**: 8 bits, zero-extended
- **Example**: `lbu t0, 0(a0)  # Load character`

### Store Instructions

#### SW - Store Word
```assembly
sw rs2, offset(rs1)
```
- **Operation**: `memory[rs1 + offset] = rs2[31:0]`
- **Example**: `sw a0, 4(sp)  # Store word to stack`

#### SH - Store Halfword
```assembly
sh rs2, offset(rs1)
```
- **Operation**: `memory[rs1 + offset][15:0] = rs2[15:0]`
- **Size**: 16 bits

#### SB - Store Byte
```assembly
sb rs2, offset(rs1)
```
- **Operation**: `memory[rs1 + offset][7:0] = rs2[7:0]`
- **Size**: 8 bits
- **Example**: `sb t0, 0(a0)  # Store character`

### Branch Instructions

#### BEQ - Branch if Equal
```assembly
beq rs1, rs2, offset
```
- **Operation**: `if (rs1 == rs2) PC += offset`
- **Example**: `beq a0, a1, equal  # Branch if equal`

#### BNE - Branch if Not Equal
```assembly
bne rs1, rs2, offset
```
- **Operation**: `if (rs1 != rs2) PC += offset`
- **Example**: `bne t0, zero, loop  # Continue if not zero`

#### BLT - Branch if Less Than
```assembly
blt rs1, rs2, offset
```
- **Operation**: `if (rs1 < rs2) PC += offset` (signed)
- **Example**: `blt a0, a1, less  # Branch if a0 < a1`

#### BGE - Branch if Greater or Equal
```assembly
bge rs1, rs2, offset
```
- **Operation**: `if (rs1 >= rs2) PC += offset` (signed)

#### BLTU - Branch if Less Than Unsigned
```assembly
bltu rs1, rs2, offset
```
- **Operation**: `if (rs1 < rs2) PC += offset` (unsigned)

#### BGEU - Branch if Greater or Equal Unsigned
```assembly
bgeu rs1, rs2, offset
```
- **Operation**: `if (rs1 >= rs2) PC += offset` (unsigned)

### Jump Instructions

#### JAL - Jump and Link
```assembly
jal rd, offset
```
- **Operation**: `rd = PC + 4; PC += offset`
- **Usage**: Function calls
- **Example**: `jal ra, function  # Call function`

#### JALR - Jump and Link Register
```assembly
jalr rd, offset(rs1)
```
- **Operation**: `rd = PC + 4; PC = (rs1 + offset) & ~1`
- **Usage**: Return from function, indirect calls
- **Example**: `jalr zero, 0(ra)  # Return (same as ret)`

### Upper Immediate Instructions

#### LUI - Load Upper Immediate
```assembly
lui rd, imm
```
- **Operation**: `rd = imm << 12`
- **Usage**: Load large constants
- **Example**: `lui t0, 0x12345  # t0 = 0x12345000`

#### AUIPC - Add Upper Immediate to PC
```assembly
auipc rd, imm
```
- **Operation**: `rd = PC + (imm << 12)`
- **Usage**: PC-relative addressing
- **Example**: `auipc a0, 0  # Get current PC`

### System Instructions

#### ECALL - Environment Call
```assembly
ecall
```
- **Operation**: System call to OS
- **Usage**: System calls, traps

#### EBREAK - Environment Break
```assembly
ebreak
```
- **Operation**: Breakpoint for debugger
- **Usage**: Debugging

#### FENCE - Memory Fence
```assembly
fence pred, succ
```
- **Operation**: Memory ordering
- **Usage**: Synchronization

## Multiplication Extension (M)

#### MUL - Multiply
```assembly
mul rd, rs1, rs2
```
- **Operation**: `rd = (rs1 * rs2)[31:0]`
- **Example**: `mul a0, a1, a2  # a0 = a1 * a2`

#### MULH - Multiply High Signed
```assembly
mulh rd, rs1, rs2
```
- **Operation**: `rd = (rs1 * rs2)[63:32]` (signed × signed)

#### MULHU - Multiply High Unsigned
```assembly
mulhu rd, rs1, rs2
```
- **Operation**: `rd = (rs1 * rs2)[63:32]` (unsigned × unsigned)

#### MULHSU - Multiply High Signed-Unsigned
```assembly
mulhsu rd, rs1, rs2
```
- **Operation**: `rd = (rs1 * rs2)[63:32]` (signed × unsigned)

#### DIV - Divide
```assembly
div rd, rs1, rs2
```
- **Operation**: `rd = rs1 / rs2` (signed)
- **Note**: Division by zero returns -1

#### DIVU - Divide Unsigned
```assembly
divu rd, rs1, rs2
```
- **Operation**: `rd = rs1 / rs2` (unsigned)

#### REM - Remainder
```assembly
rem rd, rs1, rs2
```
- **Operation**: `rd = rs1 % rs2` (signed)
- **Example**: `rem a0, a1, a2  # a0 = a1 % a2`

#### REMU - Remainder Unsigned
```assembly
remu rd, rs1, rs2
```
- **Operation**: `rd = rs1 % rs2` (unsigned)

## Atomic Extension (A)

For atomic operations on memory. See [Lesson 12: Atomic Operations](../lessons/12-atomic/).

## Compressed Extension (C)

16-bit compressed instructions. See [Lesson 11: Compressed Instructions](../lessons/11-compressed/).

## Pseudo-Instructions

Pseudo-instructions are assembler conveniences that expand to real instructions:

| Pseudo-Instruction | Real Instruction | Description |
|--------------------|------------------|-------------|
| `nop` | `addi x0, x0, 0` | No operation |
| `li rd, imm` | Various | Load immediate |
| `mv rd, rs` | `addi rd, rs, 0` | Copy register |
| `not rd, rs` | `xori rd, rs, -1` | Bitwise NOT |
| `neg rd, rs` | `sub rd, x0, rs` | Negate |
| `seqz rd, rs` | `sltiu rd, rs, 1` | Set if equal to zero |
| `snez rd, rs` | `sltu rd, x0, rs` | Set if not equal to zero |
| `sltz rd, rs` | `slt rd, rs, x0` | Set if less than zero |
| `sgtz rd, rs` | `slt rd, x0, rs` | Set if greater than zero |
| `beqz rs, offset` | `beq rs, x0, offset` | Branch if equal to zero |
| `bnez rs, offset` | `bne rs, x0, offset` | Branch if not equal to zero |
| `blez rs, offset` | `bge x0, rs, offset` | Branch if ≤ zero |
| `bgez rs, offset` | `bge rs, x0, offset` | Branch if ≥ zero |
| `bltz rs, offset` | `blt rs, x0, offset` | Branch if < zero |
| `bgtz rs, offset` | `blt x0, rs, offset` | Branch if > zero |
| `j offset` | `jal x0, offset` | Jump |
| `jr rs` | `jalr x0, 0(rs)` | Jump register |
| `ret` | `jalr x0, 0(ra)` | Return from function |
| `call offset` | `auipc+jalr` | Call far function |
| `tail offset` | `auipc+jalr` | Tail call |
| `la rd, symbol` | `auipc+addi` | Load address |

## Quick Reference

### Common Patterns

**Load 32-bit constant:**
```assembly
lui t0, %hi(value)
addi t0, t0, %lo(value)
# Or use pseudo-instruction:
li t0, value
```

**Function call:**
```assembly
jal ra, function      # Call
# ... function executes ...
jalr zero, 0(ra)      # Return (or: ret)
```

**Conditional move (if a1 == 0 then a0 = a2):**
```assembly
bnez a1, skip
mv a0, a2
skip:
```

**Loop:**
```assembly
li t0, 10             # Counter
loop:
    # ... loop body ...
    addi t0, t0, -1
    bnez t0, loop     # Continue if not zero
```

## Resources

- [Official RISC-V Spec](https://riscv.org/technical/specifications/)
- [RISC-V Reader (Book)](https://www.riscvbook.com/)
- [Online Instruction Encoder](https://luplab.gitlab.io/rvcodecjs/)

---

*This reference covers RV32I base + M extension. For floating-point (F/D) and other extensions, see their respective lesson pages.*
