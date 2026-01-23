# W65C02 Reference Documentation

Quick-lookup reference guides for W65C02 assembly programming.

## Reference Files

### 📘 [Instructions Reference](instructions.md)
Complete instruction set reference for the W65C02 processor.

**Contains:**
- All 80+ W65C02 instructions
- Quick reference table with flags
- Detailed descriptions with addressing modes
- Cycle counts and opcodes
- W65C02 enhancements highlighted
- Organized by category (Data Movement, Arithmetic, Logic, etc.)

**Use when:** Looking up instruction syntax, opcodes, cycle timing, or flag effects.

---

### 📗 [Addressing Modes Reference](addressing-modes.md)
Complete guide to all 13 W65C02 addressing modes.

**Contains:**
- Detailed explanation of each mode
- Syntax and examples
- Cycle timing information
- Memory access patterns
- Use cases and best practices
- Quick reference comparison table

**Use when:** Understanding how to access memory, choosing the right addressing mode, or optimizing code size/speed.

---

### 📙 [Memory Map Reference](memory-map.md)
Standard memory organization for W65C02 systems.

**Contains:**
- Zero Page ($0000-$00FF) organization
- Stack ($0100-$01FF) usage
- Main RAM layout
- ROM organization
- Hardware vectors ($FFFA-$FFFF)
- I/O space conventions
- Memory planning worksheets
- Platform-specific examples

**Use when:** Planning memory layout, understanding system architecture, or organizing program data.

---

### 📕 [Pinout Reference](pins.md)
Complete W65C02S 40-pin DIP pinout and connection guide.

**Contains:**
- Complete pinout diagram
- Detailed pin descriptions
- Electrical characteristics
- Breadboard connection guide
- Minimal working circuit
- Interface examples (ROM, RAM, VIA)
- Troubleshooting guide

**Use when:** Building hardware, connecting peripherals, or debugging circuit issues.

---

## Quick Navigation

**New to W65C02?**
→ Start with [Memory Map](memory-map.md) to understand the architecture  
→ Then [Addressing Modes](addressing-modes.md) to learn how to access memory  
→ Then [Instructions](instructions.md) to learn what you can do

**Writing code?**
→ [Instructions](instructions.md) for instruction lookup  
→ [Addressing Modes](addressing-modes.md) for syntax help

**Building hardware?**
→ [Pinout](pins.md) for connections  
→ [Memory Map](memory-map.md) for system design

**Optimizing?**
→ [Addressing Modes](addressing-modes.md) for cycle counts  
→ [Instructions](instructions.md) for instruction timing  
→ [Memory Map](memory-map.md) for zero page usage

---

## Key Features

### W65C02 Enhancements Over 6502

The W65C02 adds these improvements over the original NMOS 6502:

**New Instructions:**
- `BRA` - Branch Always (unconditional relative branch)
- `PHX`, `PLX` - Push/Pull X Register
- `PHY`, `PLY` - Push/Pull Y Register
- `STZ` - Store Zero
- `TRB`, `TSB` - Test and Reset/Set Bits

**Extended Instructions:**
- `BIT` with immediate and indexed modes
- `INC A`, `DEC A` - Accumulator increment/decrement
- `JMP (addr,X)` - Indexed indirect jump

**New Addressing Mode:**
- `(ZP)` - Zero page indirect (e.g., `LDA ($80)`)

**Bug Fixes:**
- Fixed JMP indirect page boundary bug
- Fixed ROR decimal mode bug
- Correct flags in decimal mode

**Other Improvements:**
- All undefined opcodes are NOPs
- Lower power consumption (CMOS)
- Faster maximum clock speed (up to 14 MHz)

---

## Quick Reference Cards

### Registers
```
A   - Accumulator (8-bit)
X   - X Index Register (8-bit)
Y   - Y Index Register (8-bit)
SP  - Stack Pointer (8-bit, always in page $01)
PC  - Program Counter (16-bit)
P   - Processor Status (8-bit flags: NV-BDIZC)
```

### Status Flags (P Register)
```
N - Negative (bit 7 of result)
V - Overflow (signed arithmetic)
- - (always 1)
B - Break flag
D - Decimal mode
I - Interrupt disable
Z - Zero result
C - Carry
```

### Memory Areas
```
$0000-$00FF - Zero Page (fast access)
$0100-$01FF - Stack (hardware)
$0200-$7FFF - RAM (typical)
$8000-$FFFF - ROM (typical)
$FFFA-$FFFB - NMI vector
$FFFC-$FFFD - RESET vector
$FFFE-$FFFF - IRQ/BRK vector
```

### Common Patterns

**16-bit Addition:**
```asm
    CLC
    LDA num1_lo
    ADC num2_lo
    STA result_lo
    LDA num1_hi
    ADC num2_hi
    STA result_hi
```

**Zero Page Pointer:**
```asm
    LDA #<data
    STA ptr
    LDA #>data
    STA ptr+1
    
    LDY #0
    LDA (ptr),Y     ; Access through pointer
```

**Loop Pattern:**
```asm
    LDX #0
loop:
    LDA data,X
    ; ... process ...
    INX
    CPX #10
    BNE loop
```

---

## Additional Resources

### Official Documentation
- [WDC W65C02S Datasheet](https://www.westerndesigncenter.com/) - Official specifications
- [WDC Programming Manual](https://www.westerndesigncenter.com/) - Complete programming guide

### Community Resources
- [6502.org](http://www.6502.org/) - Forums, projects, documentation
- [Visual 6502](http://www.visual6502.org/) - Interactive chip simulation
- [Easy 6502](https://skilldrick.github.io/easy6502/) - Interactive tutorial

### Tools
- [cc65](https://cc65.github.io/) - C compiler and assembler suite
- [VICE](https://vice-emu.sourceforge.io/) - Versatile Commodore Emulator
- [Py65](https://github.com/mnaberez/py65) - Python-based simulator

---

## Reference Conventions

### Number Formats
```
$XX or $XXXX  - Hexadecimal (e.g., $FF, $2000)
#$XX          - Immediate value
%XXXXXXXX     - Binary (sometimes)
XXX           - Decimal (when obvious)
```

### Addressing Mode Notation
```
#$44          - Immediate
$44           - Zero Page
$44,X         - Zero Page,X
$4400         - Absolute
$4400,X       - Absolute,X
($44,X)       - Indexed Indirect
($44),Y       - Indirect Indexed
($44)         - Zero Page Indirect (W65C02)
```

### Timing Notation
```
+     - Add 1 cycle if page boundary crossed
†     - See notes for special timing
*     - W65C02 only (not in original 6502)
```

---

## Document Format

These reference documents are:
- **Concise** - Quick to scan and find information
- **Complete** - All information in one place
- **Accurate** - Based on official WDC documentation
- **Practical** - Real-world examples and use cases
- **Organized** - Logical structure with tables and sections

They are **not** tutorials. For learning materials, see the [lessons](../lessons/) directory.

---

## Contributing

Found an error or want to add clarification? These reference documents should remain:
1. Accurate to the W65C02S hardware
2. Concise and scannable
3. Focused on reference (not tutorial content)
4. Well-organized with clear examples

---

## Version

Reference documentation for **W65C02S** (WDC 65C02, CMOS version).

Not applicable to:
- Original NMOS 6502
- Other 65C02 variants (different manufacturers may vary slightly)
- 65816/65802 (16-bit extensions)

---

**Quick Links:**
[Instructions](instructions.md) | [Addressing Modes](addressing-modes.md) | [Memory Map](memory-map.md) | [Pinout](pins.md)
