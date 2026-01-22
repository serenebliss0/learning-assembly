# W65C02 Instruction Set Reference

Complete reference for all W65C02 instructions including enhancements over the original 6502.

## Quick Reference Table

| Mnemonic | Description | N | V | B | D | I | Z | C |
|----------|-------------|---|---|---|---|---|---|---|
| **Data Movement** |
| LDA | Load Accumulator | ✓ | - | - | - | - | ✓ | - |
| LDX | Load X Register | ✓ | - | - | - | - | ✓ | - |
| LDY | Load Y Register | ✓ | - | - | - | - | ✓ | - |
| STA | Store Accumulator | - | - | - | - | - | - | - |
| STX | Store X Register | - | - | - | - | - | - | - |
| STY | Store Y Register | - | - | - | - | - | - | - |
| STZ* | Store Zero | - | - | - | - | - | - | - |
| TAX | Transfer A to X | ✓ | - | - | - | - | ✓ | - |
| TAY | Transfer A to Y | ✓ | - | - | - | - | ✓ | - |
| TXA | Transfer X to A | ✓ | - | - | - | - | ✓ | - |
| TYA | Transfer Y to A | ✓ | - | - | - | - | ✓ | - |
| TSX | Transfer SP to X | ✓ | - | - | - | - | ✓ | - |
| TXS | Transfer X to SP | - | - | - | - | - | - | - |
| **Arithmetic** |
| ADC | Add with Carry | ✓ | ✓ | - | - | - | ✓ | ✓ |
| SBC | Subtract with Carry | ✓ | ✓ | - | - | - | ✓ | ✓ |
| INC | Increment Memory | ✓ | - | - | - | - | ✓ | - |
| INX | Increment X | ✓ | - | - | - | - | ✓ | - |
| INY | Increment Y | ✓ | - | - | - | - | ✓ | - |
| DEC | Decrement Memory | ✓ | - | - | - | - | ✓ | - |
| DEX | Decrement X | ✓ | - | - | - | - | ✓ | - |
| DEY | Decrement Y | ✓ | - | - | - | - | ✓ | - |
| **Logic** |
| AND | Logical AND | ✓ | - | - | - | - | ✓ | - |
| ORA | Logical OR | ✓ | - | - | - | - | ✓ | - |
| EOR | Exclusive OR | ✓ | - | - | - | - | ✓ | - |
| BIT | Bit Test | ✓ | ✓ | - | - | - | ✓ | - |
| TRB* | Test and Reset Bits | - | - | - | - | - | ✓ | - |
| TSB* | Test and Set Bits | - | - | - | - | - | ✓ | - |
| **Shift/Rotate** |
| ASL | Arithmetic Shift Left | ✓ | - | - | - | - | ✓ | ✓ |
| LSR | Logical Shift Right | ✓ | - | - | - | - | ✓ | ✓ |
| ROL | Rotate Left | ✓ | - | - | - | - | ✓ | ✓ |
| ROR | Rotate Right | ✓ | - | - | - | - | ✓ | ✓ |
| **Branch** |
| BCC | Branch if Carry Clear | - | - | - | - | - | - | - |
| BCS | Branch if Carry Set | - | - | - | - | - | - | - |
| BEQ | Branch if Equal (Zero) | - | - | - | - | - | - | - |
| BNE | Branch if Not Equal | - | - | - | - | - | - | - |
| BMI | Branch if Minus | - | - | - | - | - | - | - |
| BPL | Branch if Plus | - | - | - | - | - | - | - |
| BVC | Branch if Overflow Clear | - | - | - | - | - | - | - |
| BVS | Branch if Overflow Set | - | - | - | - | - | - | - |
| BRA* | Branch Always | - | - | - | - | - | - | - |
| **Jump/Call** |
| JMP | Jump | - | - | - | - | - | - | - |
| JSR | Jump to Subroutine | - | - | - | - | - | - | - |
| RTS | Return from Subroutine | - | - | - | - | - | - | - |
| RTI | Return from Interrupt | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Stack** |
| PHA | Push Accumulator | - | - | - | - | - | - | - |
| PLA | Pull Accumulator | ✓ | - | - | - | - | ✓ | - |
| PHP | Push Processor Status | - | - | - | - | - | - | - |
| PLP | Pull Processor Status | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| PHX* | Push X Register | - | - | - | - | - | - | - |
| PLX* | Pull X Register | ✓ | - | - | - | - | ✓ | - |
| PHY* | Push Y Register | - | - | - | - | - | - | - |
| PLY* | Pull Y Register | ✓ | - | - | - | - | ✓ | - |
| **Status** |
| CLC | Clear Carry | - | - | - | - | - | - | 0 |
| CLD | Clear Decimal | - | - | - | 0 | - | - | - |
| CLI | Clear Interrupt Disable | - | - | - | - | 0 | - | - |
| CLV | Clear Overflow | - | 0 | - | - | - | - | - |
| SEC | Set Carry | - | - | - | - | - | - | 1 |
| SED | Set Decimal | - | - | - | 1 | - | - | - |
| SEI | Set Interrupt Disable | - | - | - | - | 1 | - | - |
| **System** |
| BRK | Break | - | - | 1 | - | 1 | - | - |
| NOP | No Operation | - | - | - | - | - | - | - |

\* = W65C02 enhancement (not in original 6502)

**Flag Legend:**
- N = Negative, V = Overflow, B = Break, D = Decimal, I = Interrupt Disable, Z = Zero, C = Carry
- ✓ = Modified by instruction, - = Not affected, 0/1 = Cleared/Set

---

## Detailed Instruction Reference

### Data Movement Instructions

#### LDA - Load Accumulator
Loads a byte into the accumulator.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | LDA #$44 | A9 | 2 | 2 |
| Zero Page | LDA $44 | A5 | 2 | 3 |
| Zero Page,X | LDA $44,X | B5 | 2 | 4 |
| Absolute | LDA $4400 | AD | 3 | 4 |
| Absolute,X | LDA $4400,X | BD | 3 | 4+ |
| Absolute,Y | LDA $4400,Y | B9 | 3 | 4+ |
| (Indirect,X) | LDA ($44,X) | A1 | 2 | 6 |
| (Indirect),Y | LDA ($44),Y | B1 | 2 | 5+ |
| (Indirect)* | LDA ($44) | B2 | 2 | 5 |

\+ Add 1 cycle if page boundary crossed  
\* W65C02 only

#### LDX - Load X Register
Loads a byte into the X register.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | LDX #$44 | A2 | 2 | 2 |
| Zero Page | LDX $44 | A6 | 2 | 3 |
| Zero Page,Y | LDX $44,Y | B6 | 2 | 4 |
| Absolute | LDX $4400 | AE | 3 | 4 |
| Absolute,Y | LDX $4400,Y | BE | 3 | 4+ |

#### LDY - Load Y Register
Loads a byte into the Y register.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | LDY #$44 | A0 | 2 | 2 |
| Zero Page | LDY $44 | A4 | 2 | 3 |
| Zero Page,X | LDY $44,X | B4 | 2 | 4 |
| Absolute | LDY $4400 | AC | 3 | 4 |
| Absolute,X | LDY $4400,X | BC | 3 | 4+ |

#### STA - Store Accumulator
Stores the accumulator to memory.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Zero Page | STA $44 | 85 | 2 | 3 |
| Zero Page,X | STA $44,X | 95 | 2 | 4 |
| Absolute | STA $4400 | 8D | 3 | 4 |
| Absolute,X | STA $4400,X | 9D | 3 | 5 |
| Absolute,Y | STA $4400,Y | 99 | 3 | 5 |
| (Indirect,X) | STA ($44,X) | 81 | 2 | 6 |
| (Indirect),Y | STA ($44),Y | 91 | 2 | 6 |
| (Indirect)* | STA ($44) | 92 | 2 | 5 |

#### STX - Store X Register
Stores the X register to memory.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Zero Page | STX $44 | 86 | 2 | 3 |
| Zero Page,Y | STX $44,Y | 96 | 2 | 4 |
| Absolute | STX $4400 | 8E | 3 | 4 |

#### STY - Store Y Register
Stores the Y register to memory.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Zero Page | STY $44 | 84 | 2 | 3 |
| Zero Page,X | STY $44,X | 94 | 2 | 4 |
| Absolute | STY $4400 | 8C | 3 | 4 |

#### STZ - Store Zero (W65C02)
Stores zero to memory. More efficient than loading zero then storing.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Zero Page | STZ $44 | 64 | 2 | 3 |
| Zero Page,X | STZ $44,X | 74 | 2 | 4 |
| Absolute | STZ $4400 | 9C | 3 | 4 |
| Absolute,X | STZ $4400,X | 9E | 3 | 5 |

#### TAX - Transfer A to X
Copies the accumulator to the X register.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | TAX | AA | 1 | 2 |

#### TAY - Transfer A to Y
Copies the accumulator to the Y register.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | TAY | A8 | 1 | 2 |

#### TXA - Transfer X to A
Copies the X register to the accumulator.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | TXA | 8A | 1 | 2 |

#### TYA - Transfer Y to A
Copies the Y register to the accumulator.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | TYA | 98 | 1 | 2 |

#### TSX - Transfer SP to X
Copies the stack pointer to the X register.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | TSX | BA | 1 | 2 |

#### TXS - Transfer X to SP
Copies the X register to the stack pointer.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | TXS | 9A | 1 | 2 |

---

### Arithmetic Instructions

#### ADC - Add with Carry
Adds a value to the accumulator with carry.  
`A = A + M + C`

**Flags:** N, V, Z, C  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | ADC #$44 | 69 | 2 | 2 |
| Zero Page | ADC $44 | 65 | 2 | 3 |
| Zero Page,X | ADC $44,X | 75 | 2 | 4 |
| Absolute | ADC $4400 | 6D | 3 | 4 |
| Absolute,X | ADC $4400,X | 7D | 3 | 4+ |
| Absolute,Y | ADC $4400,Y | 79 | 3 | 4+ |
| (Indirect,X) | ADC ($44,X) | 61 | 2 | 6 |
| (Indirect),Y | ADC ($44),Y | 71 | 2 | 5+ |
| (Indirect)* | ADC ($44) | 72 | 2 | 5 |

**Note:** In decimal mode (D flag set), performs BCD addition.

#### SBC - Subtract with Carry
Subtracts a value from the accumulator with borrow.  
`A = A - M - (1 - C)`

**Flags:** N, V, Z, C  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | SBC #$44 | E9 | 2 | 2 |
| Zero Page | SBC $44 | E5 | 2 | 3 |
| Zero Page,X | SBC $44,X | F5 | 2 | 4 |
| Absolute | SBC $4400 | ED | 3 | 4 |
| Absolute,X | SBC $4400,X | FD | 3 | 4+ |
| Absolute,Y | SBC $4400,Y | F9 | 3 | 4+ |
| (Indirect,X) | SBC ($44,X) | E1 | 2 | 6 |
| (Indirect),Y | SBC ($44),Y | F1 | 2 | 5+ |
| (Indirect)* | SBC ($44) | F2 | 2 | 5 |

**Note:** In decimal mode (D flag set), performs BCD subtraction. W65C02 fixes decimal mode flags.

#### INC - Increment Memory
Increments a memory location by one.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Accumulator* | INC A | 1A | 1 | 2 |
| Zero Page | INC $44 | E6 | 2 | 5 |
| Zero Page,X | INC $44,X | F6 | 2 | 6 |
| Absolute | INC $4400 | EE | 3 | 6 |
| Absolute,X | INC $4400,X | FE | 3 | 7 |

\* Accumulator mode is W65C02 only

#### INX - Increment X
Increments the X register by one.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | INX | E8 | 1 | 2 |

#### INY - Increment Y
Increments the Y register by one.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | INY | C8 | 1 | 2 |

#### DEC - Decrement Memory
Decrements a memory location by one.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Accumulator* | DEC A | 3A | 1 | 2 |
| Zero Page | DEC $44 | C6 | 2 | 5 |
| Zero Page,X | DEC $44,X | D6 | 2 | 6 |
| Absolute | DEC $4400 | CE | 3 | 6 |
| Absolute,X | DEC $4400,X | DE | 3 | 7 |

\* Accumulator mode is W65C02 only

#### DEX - Decrement X
Decrements the X register by one.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | DEX | CA | 1 | 2 |

#### DEY - Decrement Y
Decrements the Y register by one.

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | DEY | 88 | 1 | 2 |

---

### Logic Instructions

#### AND - Logical AND
Performs bitwise AND between accumulator and memory.  
`A = A & M`

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | AND #$44 | 29 | 2 | 2 |
| Zero Page | AND $44 | 25 | 2 | 3 |
| Zero Page,X | AND $44,X | 35 | 2 | 4 |
| Absolute | AND $4400 | 2D | 3 | 4 |
| Absolute,X | AND $4400,X | 3D | 3 | 4+ |
| Absolute,Y | AND $4400,Y | 39 | 3 | 4+ |
| (Indirect,X) | AND ($44,X) | 21 | 2 | 6 |
| (Indirect),Y | AND ($44),Y | 31 | 2 | 5+ |
| (Indirect)* | AND ($44) | 32 | 2 | 5 |

#### ORA - Logical OR
Performs bitwise OR between accumulator and memory.  
`A = A | M`

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | ORA #$44 | 09 | 2 | 2 |
| Zero Page | ORA $44 | 05 | 2 | 3 |
| Zero Page,X | ORA $44,X | 15 | 2 | 4 |
| Absolute | ORA $4400 | 0D | 3 | 4 |
| Absolute,X | ORA $4400,X | 1D | 3 | 4+ |
| Absolute,Y | ORA $4400,Y | 19 | 3 | 4+ |
| (Indirect,X) | ORA ($44,X) | 01 | 2 | 6 |
| (Indirect),Y | ORA ($44),Y | 11 | 2 | 5+ |
| (Indirect)* | ORA ($44) | 12 | 2 | 5 |

#### EOR - Exclusive OR
Performs bitwise XOR between accumulator and memory.  
`A = A ^ M`

**Flags:** N, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate | EOR #$44 | 49 | 2 | 2 |
| Zero Page | EOR $44 | 45 | 2 | 3 |
| Zero Page,X | EOR $44,X | 55 | 2 | 4 |
| Absolute | EOR $4400 | 4D | 3 | 4 |
| Absolute,X | EOR $4400,X | 5D | 3 | 4+ |
| Absolute,Y | EOR $4400,Y | 59 | 3 | 4+ |
| (Indirect,X) | EOR ($44,X) | 41 | 2 | 6 |
| (Indirect),Y | EOR ($44),Y | 51 | 2 | 5+ |
| (Indirect)* | EOR ($44) | 52 | 2 | 5 |

#### BIT - Bit Test
Tests bits in accumulator against memory.  
- Bit 7 → N flag  
- Bit 6 → V flag  
- A & M → Z flag (zero if no bits in common)

**Flags:** N, V, Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Immediate* | BIT #$44 | 89 | 2 | 2 |
| Zero Page | BIT $44 | 24 | 2 | 3 |
| Zero Page,X* | BIT $44,X | 34 | 2 | 4 |
| Absolute | BIT $4400 | 2C | 3 | 4 |
| Absolute,X* | BIT $4400,X | 3C | 3 | 4+ |

\* W65C02 only. Note: Immediate mode only affects Z flag, not N or V.

#### TRB - Test and Reset Bits (W65C02)
Tests bits then clears them in memory.  
- A & M → Z flag  
- M & ~A → M (clears bits set in A)

**Flags:** Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Zero Page | TRB $44 | 14 | 2 | 5 |
| Absolute | TRB $4400 | 1C | 3 | 6 |

#### TSB - Test and Set Bits (W65C02)
Tests bits then sets them in memory.  
- A & M → Z flag  
- M | A → M (sets bits set in A)

**Flags:** Z  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Zero Page | TSB $44 | 04 | 2 | 5 |
| Absolute | TSB $4400 | 0C | 3 | 6 |

---

### Shift and Rotate Instructions

#### ASL - Arithmetic Shift Left
Shifts all bits left. Bit 0 becomes 0, bit 7 goes to carry.

```
C ← [7][6][5][4][3][2][1][0] ← 0
```

**Flags:** N, Z, C  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Accumulator | ASL A | 0A | 1 | 2 |
| Zero Page | ASL $44 | 06 | 2 | 5 |
| Zero Page,X | ASL $44,X | 16 | 2 | 6 |
| Absolute | ASL $4400 | 0E | 3 | 6 |
| Absolute,X | ASL $4400,X | 1E | 3 | 7 |

#### LSR - Logical Shift Right
Shifts all bits right. Bit 7 becomes 0, bit 0 goes to carry.

```
0 → [7][6][5][4][3][2][1][0] → C
```

**Flags:** N (always 0), Z, C  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Accumulator | LSR A | 4A | 1 | 2 |
| Zero Page | LSR $44 | 46 | 2 | 5 |
| Zero Page,X | LSR $44,X | 56 | 2 | 6 |
| Absolute | LSR $4400 | 4E | 3 | 6 |
| Absolute,X | LSR $4400,X | 5E | 3 | 7 |

#### ROL - Rotate Left
Rotates all bits left through carry.

```
C ← [7][6][5][4][3][2][1][0] ← C
```

**Flags:** N, Z, C  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Accumulator | ROL A | 2A | 1 | 2 |
| Zero Page | ROL $44 | 26 | 2 | 5 |
| Zero Page,X | ROL $44,X | 36 | 2 | 6 |
| Absolute | ROL $4400 | 2E | 3 | 6 |
| Absolute,X | ROL $4400,X | 3E | 3 | 7 |

#### ROR - Rotate Right
Rotates all bits right through carry.

```
C → [7][6][5][4][3][2][1][0] → C
```

**Flags:** N, Z, C  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Accumulator | ROR A | 6A | 1 | 2 |
| Zero Page | ROR $44 | 66 | 2 | 5 |
| Zero Page,X | ROR $44,X | 76 | 2 | 6 |
| Absolute | ROR $4400 | 6E | 3 | 6 |
| Absolute,X | ROR $4400,X | 7E | 3 | 7 |

---

### Branch Instructions

All branch instructions use **relative addressing** (signed 8-bit offset: -128 to +127 bytes).

**Cycles:** 2 (not taken), 3 (taken, same page), 4 (taken, page boundary crossed)

#### BCC - Branch if Carry Clear
Branch if C = 0.

**Opcode:** 90 | **Bytes:** 2

#### BCS - Branch if Carry Set
Branch if C = 1.

**Opcode:** B0 | **Bytes:** 2

#### BEQ - Branch if Equal
Branch if Z = 1.

**Opcode:** F0 | **Bytes:** 2

#### BNE - Branch if Not Equal
Branch if Z = 0.

**Opcode:** D0 | **Bytes:** 2

#### BMI - Branch if Minus
Branch if N = 1.

**Opcode:** 30 | **Bytes:** 2

#### BPL - Branch if Plus
Branch if N = 0.

**Opcode:** 10 | **Bytes:** 2

#### BVC - Branch if Overflow Clear
Branch if V = 0.

**Opcode:** 50 | **Bytes:** 2

#### BVS - Branch if Overflow Set
Branch if V = 1.

**Opcode:** 70 | **Bytes:** 2

#### BRA - Branch Always (W65C02)
Unconditional branch. Always taken.

**Opcode:** 80 | **Bytes:** 2 | **Cycles:** 3 (same page), 4 (page boundary)

---

### Jump and Call Instructions

#### JMP - Jump
Jumps to a new location.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Absolute | JMP $4400 | 4C | 3 | 3 |
| Indirect | JMP ($4400) | 6C | 3 | 5† |
| (Indirect,X)* | JMP ($4400,X) | 7C | 3 | 6 |

† W65C02 fixes the 6502 indirect JMP page boundary bug.  
\* W65C02 only

#### JSR - Jump to Subroutine
Pushes return address (PC-1) to stack, then jumps.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Absolute | JSR $4400 | 20 | 3 | 6 |

#### RTS - Return from Subroutine
Pulls return address from stack and increments PC.

**Flags:** None  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | RTS | 60 | 1 | 6 |

#### RTI - Return from Interrupt
Pulls processor status and return address from stack.

**Flags:** All (restored from stack)  
**Addressing Modes:**
| Mode | Syntax | Opcode | Bytes | Cycles |
|------|--------|--------|-------|--------|
| Implied | RTI | 40 | 1 | 6 |

---

### Stack Instructions

Stack grows downward from $01FF. Stack pointer (SP) points to next free location.

#### PHA - Push Accumulator
Pushes accumulator to stack.

**Flags:** None  
**Opcode:** 48 | **Bytes:** 1 | **Cycles:** 3

#### PLA - Pull Accumulator
Pulls accumulator from stack.

**Flags:** N, Z  
**Opcode:** 68 | **Bytes:** 1 | **Cycles:** 4

#### PHP - Push Processor Status
Pushes status register to stack (with B flag set).

**Flags:** None  
**Opcode:** 08 | **Bytes:** 1 | **Cycles:** 3

#### PLP - Pull Processor Status
Pulls status register from stack.

**Flags:** All (restored from stack)  
**Opcode:** 28 | **Bytes:** 1 | **Cycles:** 4

#### PHX - Push X Register (W65C02)
Pushes X register to stack.

**Flags:** None  
**Opcode:** DA | **Bytes:** 1 | **Cycles:** 3

#### PLX - Pull X Register (W65C02)
Pulls X register from stack.

**Flags:** N, Z  
**Opcode:** FA | **Bytes:** 1 | **Cycles:** 4

#### PHY - Push Y Register (W65C02)
Pushes Y register to stack.

**Flags:** None  
**Opcode:** 5A | **Bytes:** 1 | **Cycles:** 3

#### PLY - Pull Y Register (W65C02)
Pulls Y register from stack.

**Flags:** N, Z  
**Opcode:** 7A | **Bytes:** 1 | **Cycles:** 4

---

### Status Flag Instructions

#### CLC - Clear Carry
Sets carry flag to 0.

**Opcode:** 18 | **Bytes:** 1 | **Cycles:** 2

#### CLD - Clear Decimal
Sets decimal mode flag to 0 (binary mode).

**Opcode:** D8 | **Bytes:** 1 | **Cycles:** 2

#### CLI - Clear Interrupt Disable
Sets interrupt disable flag to 0 (enables IRQ).

**Opcode:** 58 | **Bytes:** 1 | **Cycles:** 2

#### CLV - Clear Overflow
Sets overflow flag to 0.

**Opcode:** B8 | **Bytes:** 1 | **Cycles:** 2

#### SEC - Set Carry
Sets carry flag to 1.

**Opcode:** 38 | **Bytes:** 1 | **Cycles:** 2

#### SED - Set Decimal
Sets decimal mode flag to 1 (BCD mode).

**Opcode:** F8 | **Bytes:** 1 | **Cycles:** 2

#### SEI - Set Interrupt Disable
Sets interrupt disable flag to 1 (disables IRQ).

**Opcode:** 78 | **Bytes:** 1 | **Cycles:** 2

---

### System Instructions

#### BRK - Break
Software interrupt. Pushes PC+2 and status (with B flag set), then jumps to IRQ vector.

**Flags:** B = 1, I = 1  
**Opcode:** 00 | **Bytes:** 1† | **Cycles:** 7

† BRK is 1 byte but increments PC by 2. The extra byte is available for debugging info.

#### NOP - No Operation
Does nothing for 2 cycles.

**Flags:** None  
**Opcode:** EA | **Bytes:** 1 | **Cycles:** 2

---

## W65C02 Enhancements Summary

### New Instructions
- **BRA** - Branch Always
- **PHX, PLX** - Push/Pull X Register
- **PHY, PLY** - Push/Pull Y Register
- **STZ** - Store Zero
- **TRB, TSB** - Test and Reset/Set Bits

### Extended Instructions
- **BIT** - Added Immediate, Zero Page,X and Absolute,X modes
- **INC, DEC** - Added Accumulator mode
- **JMP** - Added (Indirect,X) mode

### New Addressing Modes
- **(Indirect)** - Zero page indirect (without indexing)
- **JMP (Absolute,X)** - Indexed indirect jump

### Bug Fixes
- **JMP Indirect** - Fixed page boundary bug from 6502
- **Decimal Mode** - Flags now set correctly in decimal mode
- **ROR** - Fixed bit 6 bug from 6502

### Timing Improvements
- Many instructions execute 1 cycle faster than 6502
- No page boundary penalty on some indexed instructions

---

## Processor Status Register (P)

```
 7  6  5  4  3  2  1  0
[N][V][-][B][D][I][Z][C]
```

- **N** - Negative (bit 7 of result)
- **V** - Overflow (signed arithmetic overflow)
- **B** - Break (set by BRK, cleared by IRQ)
- **D** - Decimal (BCD mode)
- **I** - Interrupt Disable (masks IRQ)
- **Z** - Zero (result is zero)
- **C** - Carry (arithmetic carry/borrow)

Bit 5 is always 1 (not used).

---

## Cycle Count Notes

- **+** = Add 1 cycle if page boundary crossed on indexed addressing
- **W65C02** fixes some 6502 bugs and has slightly different timing on some instructions
- **Branch** instructions: 2 cycles if not taken, 3 if taken (same page), 4 if page boundary crossed
- **Interrupts** take 7 cycles

---

## Opcode Map Quick Reference

```
     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
0x  BRK ORA    TSB ORA ASL    PHP ORA ASL    TSB ORA ASL
1x  BPL ORA    TRB ORA ASL    CLC ORA    INC TRB ORA ASL
2x  JSR AND    BIT AND ROL    PLP AND ROL    BIT AND ROL
3x  BMI AND    BIT AND ROL    SEC AND    DEC BIT AND ROL
4x  RTI EOR    NOP EOR LSR    PHA EOR LSR    JMP EOR LSR
5x  BVC EOR    NOP EOR LSR    CLI EOR    PHY NOP EOR LSR
6x  RTS ADC    STZ ADC ROR    PLA ADC ROR    JMP ADC ROR
7x  BVS ADC    STZ ADC ROR    SEI ADC    PLY JMP ADC ROR
8x  BRA STA        STY STA STX    DEY    TXA    STY STA STX
9x  BCC STA        STY STA STX    TYA STA TXS    STZ STA STZ
Ax  LDY LDA LDX    LDY LDA LDX    TAY LDA TAX    LDY LDA LDX
Bx  BCS LDA        LDY LDA LDX    CLV LDA TSX    LDY LDA LDX
Cx  CPY CMP        CPY CMP DEC    INY CMP DEX    CPY CMP DEC
Dx  BNE CMP        NOP CMP DEC    CLD CMP    NOP NOP CMP DEC
Ex  CPX SBC        CPX SBC INC    INX SBC NOP    CPX SBC INC
Fx  BEQ SBC        NOP SBC INC    SED SBC    NOP NOP SBC INC
```

---

## Additional Resources

- WDC W65C02S Datasheet: https://www.westerndesigncenter.com/
- Programming the 65816 (includes 65C02): https://archive.org/details/Programming_the_65816
- 6502.org: http://www.6502.org/
