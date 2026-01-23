# W65C02 Addressing Modes Reference

Complete guide to all 13 addressing modes on the W65C02 processor.

## Quick Reference Table

| Mode | Syntax | Example | Bytes | Description | Typical Cycles |
|------|--------|---------|-------|-------------|----------------|
| Implied | INX | INX | 1 | No operand needed | 2 |
| Accumulator | ASL A | ASL A | 1 | Operates on accumulator | 2 |
| Immediate | LDA #$44 | LDA #$44 | 2 | Literal value | 2 |
| Zero Page | LDA $44 | LDA $44 | 2 | Address $0000-$00FF | 3 |
| Zero Page,X | LDA $44,X | LDA $44,X | 2 | ZP + X register | 4 |
| Zero Page,Y | LDX $44,Y | LDX $44,Y | 2 | ZP + Y register | 4 |
| Absolute | LDA $4400 | LDA $4400 | 3 | 16-bit address | 4 |
| Absolute,X | LDA $4400,X | LDA $4400,X | 3 | Absolute + X | 4-5 |
| Absolute,Y | LDA $4400,Y | LDA $4400,Y | 3 | Absolute + Y | 4-5 |
| Relative | BEQ label | BEQ $10 | 2 | PC + signed offset | 2-4 |
| Indirect | JMP ($4400) | JMP ($4400) | 3 | Jump via pointer | 5-6 |
| (Indirect,X) | LDA ($44,X) | LDA ($44,X) | 2 | Indexed indirect | 6 |
| (Indirect),Y | LDA ($44),Y | LDA ($44),Y | 2 | Indirect indexed | 5-6 |
| (Indirect)† | LDA ($44) | LDA ($44) | 2 | Zero page indirect | 5 |

† W65C02 enhancement (not available on original 6502)

---

## Detailed Mode Descriptions

### 1. Implied Addressing

**Syntax:** `MNEMONIC`  
**Example:** `INX`, `DEX`, `NOP`, `RTS`  
**Bytes:** 1  
**Cycles:** 2 (typically)

The instruction operates on a specific register or has no operand. The operation is implied by the opcode.

**Use Cases:**
- Register operations: INX, INY, DEX, DEY
- Register transfers: TAX, TAY, TXA, TYA, TSX, TXS
- Stack operations: RTS, RTI
- Flag operations: CLC, SEC, CLD, SED, CLI, SEI, CLV
- Control: NOP

**Example:**
```asm
    INX        ; Increment X register
    CLC        ; Clear carry flag
    RTS        ; Return from subroutine
```

**Memory Access:** None (register or flag only)

---

### 2. Accumulator Addressing

**Syntax:** `MNEMONIC A`  
**Example:** `ASL A`, `LSR A`, `ROL A`, `ROR A`  
**Bytes:** 1  
**Cycles:** 2

The instruction operates directly on the accumulator register. Some assemblers allow omitting the 'A'.

**Use Cases:**
- Shift/rotate operations on accumulator
- INC/DEC accumulator (W65C02 only)

**Example:**
```asm
    ASL A      ; Shift accumulator left
    ROR A      ; Rotate accumulator right
    INC A      ; Increment accumulator (W65C02)
    ; Or simply:
    ASL        ; Many assemblers accept this
```

**Memory Access:** None (accumulator only)

---

### 3. Immediate Addressing

**Syntax:** `MNEMONIC #$value`  
**Example:** `LDA #$42`  
**Bytes:** 2  
**Cycles:** 2

The operand is a literal 8-bit value specified in the instruction. The `#` symbol indicates immediate mode.

**Use Cases:**
- Loading constant values
- Comparing against known values
- Arithmetic with constants
- Bit masking

**Example:**
```asm
    LDA #$00   ; Load accumulator with 0
    LDX #$FF   ; Load X with 255
    ADC #$10   ; Add 16 to accumulator
    CMP #$20   ; Compare A with 32
    AND #$0F   ; Mask lower 4 bits
```

**Memory Access:** None (value embedded in code)

**Note:** Use `#` prefix - without it, you're accessing memory!
```asm
    LDA #$44   ; Load the VALUE $44 (68 decimal)
    LDA $44    ; Load from MEMORY ADDRESS $44
```

---

### 4. Zero Page Addressing

**Syntax:** `MNEMONIC $nn`  
**Example:** `LDA $44`  
**Bytes:** 2  
**Cycles:** 3

Accesses memory in the zero page ($0000-$00FF) using an 8-bit address. Faster and more compact than absolute addressing.

**Use Cases:**
- Fast variable access
- Temporary storage
- Frequently accessed data
- Indirect addressing base pointers

**Example:**
```asm
    LDA $10    ; Load from $0010
    STA $20    ; Store to $0020
    INC $30    ; Increment value at $0030
    STZ $40    ; Store zero to $0040 (W65C02)
```

**Memory Access:** $00nn (where nn is the operand)

**Advantages:**
- 1 byte shorter than absolute addressing
- 1 cycle faster than absolute addressing
- Critical for performance-sensitive code

**Best Practices:**
- Reserve zero page for most frequently used variables
- Use for loop counters, temporary values, pointers
- Typical allocation: $00-$7F for user, $80-$FF for system

---

### 5. Zero Page,X Addressing

**Syntax:** `MNEMONIC $nn,X`  
**Example:** `LDA $44,X`  
**Bytes:** 2  
**Cycles:** 4

Adds the X register to a zero page address. Wraps within zero page (e.g., $FF,X where X=$02 = $01).

**Use Cases:**
- Array access in zero page
- Table lookups
- Indexed variable access
- Parameter passing

**Example:**
```asm
    LDX #$05      ; X = 5
    LDA $40,X     ; Load from $0045
    STA $50,X     ; Store to $0055
    
    ; Array access
    LDX #$00
loop:
    LDA $80,X     ; Access array at $80
    ; ... process ...
    INX
    CPX #$10
    BNE loop
```

**Memory Access:** ($nn + X) & $FF (wraps at zero page boundary)

**Wrapping Example (Common Bug!):**
```asm
    LDX #$10
    LDA $F8,X     ; Accesses $08, not $108!
                  ; Zero page wraps at $FF boundary
                  ; This is 8-bit addition: ($F8 + $10) & $FF = $08
```

**Important:** Zero page wrapping is a frequent source of bugs. Always ensure your indexed calculations stay within zero page boundaries.

---

### 6. Zero Page,Y Addressing

**Syntax:** `MNEMONIC $nn,Y`  
**Example:** `LDX $44,Y`, `STX $44,Y`  
**Bytes:** 2  
**Cycles:** 4

Adds the Y register to a zero page address. Similar to Zero Page,X but less commonly available.

**Available Instructions:** LDX, STX only

**Use Cases:**
- Limited to X register operations
- Complementary to Zero Page,X

**Example:**
```asm
    LDY #$03
    LDX $40,Y     ; Load X from $0043
    STX $50,Y     ; Store X to $0053
```

**Memory Access:** ($nn + Y) & $FF (wraps at zero page boundary)

---

### 7. Absolute Addressing

**Syntax:** `MNEMONIC $nnnn`  
**Example:** `LDA $4400`  
**Bytes:** 3  
**Cycles:** 4

Accesses any memory location using a full 16-bit address.

**Use Cases:**
- Accessing RAM beyond zero page
- ROM data access
- I/O device registers
- Large data structures
- Jump/call destinations

**Example:**
```asm
    LDA $2000     ; Load from $2000
    STA $4000     ; Store to $4000
    JMP $8000     ; Jump to $8000
    JSR $C000     ; Call subroutine at $C000
    INC $3000     ; Increment memory at $3000
```

**Memory Access:** $nnnn (full 16-bit address)

**Note:** Some assemblers automatically choose zero page mode if address < $100:
```asm
    LDA $0044     ; Assembler may use zero page mode
    LDA $4400     ; Must use absolute mode
```

---

### 8. Absolute,X Addressing

**Syntax:** `MNEMONIC $nnnn,X`  
**Example:** `LDA $4400,X`  
**Bytes:** 3  
**Cycles:** 4 (5 if page boundary crossed)

Adds X register to a 16-bit base address.

**Use Cases:**
- Array and table access
- Screen buffer manipulation
- Data structure traversal
- Sprite processing

**Example:**
```asm
    LDX #$00
loop:
    LDA data,X      ; Load from array
    STA $2000,X     ; Store to screen
    INX
    CPX #$100       ; Can access 256 bytes
    BNE loop

data:
    .byte $01, $02, $03, $04
```

**Memory Access:** $nnnn + X (full 16-bit addition)

**Page Boundary Crossing:**
- If (base & $FF) + X >= $100, add 1 cycle
- Example: $20FF,X where X=$02 → $2101 (page crossed, +1 cycle)
- Write instructions always take the extra cycle

---

### 9. Absolute,Y Addressing

**Syntax:** `MNEMONIC $nnnn,Y`  
**Example:** `LDA $4400,Y`  
**Bytes:** 3  
**Cycles:** 4 (5 if page boundary crossed)

Adds Y register to a 16-bit base address. Identical to Absolute,X but uses Y.

**Use Cases:**
- Two-dimensional arrays (X for one axis, Y for other)
- Row/column based access
- Alternative indexing to X

**Example:**
```asm
    ; 2D array: X=column, Y=row (40 columns)
    LDX #$05          ; Column 5
    LDY #$03          ; Row 3
    LDA $2000,X       ; Or use Y for rows
    
    ; String processing
    LDY #$00
read_loop:
    LDA message,Y
    BEQ done
    JSR print_char
    INY
    BNE read_loop
done:
```

**Memory Access:** $nnnn + Y (full 16-bit addition)

---

### 10. Relative Addressing

**Syntax:** `MNEMONIC label` (assembler calculates offset)  
**Example:** `BEQ loop`, `BNE skip`  
**Bytes:** 2  
**Cycles:** 2 (not taken), 3 (taken), 4 (page boundary crossed)

Uses a signed 8-bit offset (-128 to +127) from the instruction after the branch.

**Available Instructions:** All branches (BCC, BCS, BEQ, BNE, BMI, BPL, BVC, BVS, BRA)

**Use Cases:**
- All conditional branching
- Loops
- If/then/else structures
- Short jumps

**Example:**
```asm
    LDA counter
    CMP #$10
    BEQ equal       ; Branch if A = $10
    BNE not_equal   ; Branch if A ≠ $10
    
loop:
    INX
    CPX #$0A
    BNE loop        ; Loop while X ≠ $0A
    
equal:
    ; Code here
    BRA done        ; Unconditional (W65C02)
    
not_equal:
    ; Code here
    
done:
```

**Memory Access:** None (affects program counter only)

**Offset Calculation:**
```
Offset = Target Address - (PC + 2)
```

**Range Limitations:**
- Can branch -128 to +127 bytes from the instruction after branch
- If target is too far, use JMP instead
- Assembler usually errors if out of range

**Branch Timing:**
- 2 cycles: Branch not taken
- 3 cycles: Branch taken, same page
- 4 cycles: Branch taken, page boundary crossed

---

### 11. Indirect Addressing

**Syntax:** `JMP ($nnnn)`  
**Example:** `JMP ($2000)`  
**Bytes:** 3  
**Cycles:** 5 (6 for indexed)

Loads the target address from memory. Used only with JMP.

**Use Cases:**
- Jump tables
- Function pointers
- Dynamic dispatch
- Vectored execution

**Example:**
```asm
    ; Jump table
    LDX function_id
    LDA jump_table_lo,X
    STA vector
    LDA jump_table_hi,X
    STA vector+1
    JMP (vector)        ; Jump through pointer
    
    ; Or with W65C02:
    JMP (jump_table,X)  ; Indexed indirect
    
jump_table:
    .word func1, func2, func3
```

**Memory Access:**
```
Target = MEMORY[$nnnn] | (MEMORY[$nnnn+1] << 8)
```

**6502 Bug (FIXED in W65C02):**
- Original 6502: JMP ($20FF) reads from $20FF and $2000 (not $2100)
- W65C02: Correctly reads from $20FF and $2100

**W65C02 Enhancement:**
```asm
    JMP ($4400,X)   ; Indexed indirect jump
                    ; Address = ($4400 + X)
```

---

### 12. Indexed Indirect (Indirect,X)

**Syntax:** `MNEMONIC ($nn,X)`  
**Example:** `LDA ($44,X)`  
**Bytes:** 2  
**Cycles:** 6

Adds X to zero page address, then reads a 16-bit pointer from that location.

**Use Cases:**
- Pointer arrays in zero page
- Multiple data structure access
- Table-driven operations

**Memory Access:**
```
Pointer = $nn + X (wraps in zero page)
Address = MEMORY[Pointer] | (MEMORY[Pointer+1] << 8)
```

**Example:**
```asm
    ; Array of pointers at $80
    ; Pointer 0: $80-$81
    ; Pointer 1: $82-$83
    ; Pointer 2: $84-$85
    
    LDX #$04            ; Select pointer 2 (index 2 × 2 = 4)
    LDA ($80,X)         ; Load through pointer at $84-$85
    
    ; Setup:
setup:
    LDA #<string1
    STA $80
    LDA #>string1
    STA $81
    
    LDA #<string2
    STA $82
    LDA #>string2
    STA $83
```

**Diagram:**
```
Memory:
$80: $00  ←┐
$81: $30  ─┤ Pointer 0 ($3000)
$82: $00  ←┼─┐
$83: $31  ─┤ │ Pointer 1 ($3100)
$84: $00  ←┼─┼─┐
$85: $32  ─┤ │ │ Pointer 2 ($3200)
          └─┘ │
              │
X = $02 → Use pointer at $82-$83 ($3100)
X = $04 → Use pointer at $84-$85 ($3200)
```

**Why X register?** Allows selecting which pointer to use.

---

### 13. Indirect Indexed (Indirect),Y

**Syntax:** `MNEMONIC ($nn),Y`  
**Example:** `LDA ($44),Y`  
**Bytes:** 2  
**Cycles:** 5 (6 if page boundary crossed)

Reads a 16-bit pointer from zero page, then adds Y to it.

**Use Cases:**
- Most common indirect mode
- String/array processing through pointers
- Data structure traversal
- Character/sprite access

**Memory Access:**
```
Pointer = MEMORY[$nn] | (MEMORY[$nn+1] << 8)
Address = Pointer + Y
```

**Example:**
```asm
    ; Process a string
    LDA #<string
    STA $80
    LDA #>string
    STA $81
    
    LDY #$00
loop:
    LDA ($80),Y     ; Load character
    BEQ done        ; Null terminator?
    JSR print_char
    INY
    BNE loop        ; Max 256 bytes
done:

string:
    .byte "Hello, World!", $00
```

**Diagram:**
```
Zero Page:
$80: $00  ←┐
$81: $30  ─┤ Pointer = $3000
          └─┘
           │
           └→ $3000 + Y = Final Address

Y = $00 → Access $3000
Y = $01 → Access $3001
Y = $10 → Access $3010
```

**Page Boundary:** If Pointer + Y crosses page boundary, add 1 cycle (read ops).

**Common Pattern:**
```asm
    ; 16-bit pointer increment
inc_pointer:
    INC $80         ; Low byte
    BNE :+          ; If no carry, done
    INC $81         ; High byte
:   RTS
```

---

### 14. Zero Page Indirect (W65C02)

**Syntax:** `MNEMONIC ($nn)`  
**Example:** `LDA ($44)`  
**Bytes:** 2  
**Cycles:** 5

Reads a 16-bit pointer from zero page and accesses that address. No indexing.

**Use Cases:**
- Simpler pointer dereferencing
- When Y offset not needed
- Cleaner code for pointer access

**Memory Access:**
```
Address = MEMORY[$nn] | (MEMORY[$nn+1] << 8)
```

**Example:**
```asm
    ; Simple pointer dereference
    LDA #<data
    STA $80
    LDA #>data
    STA $81
    
    LDA ($80)       ; Load from address in pointer
    STA ($80)       ; Store to address in pointer
    CMP ($80)       ; Compare with data at pointer
    
    ; Before W65C02, needed:
    LDY #$00
    LDA ($80),Y     ; Awkward!
```

**Advantage:** Cleaner syntax when no offset needed.

---

## Addressing Mode Selection Guide

### Performance Considerations

| Speed | Mode | Why |
|-------|------|-----|
| Fastest | Implied, Accumulator, Immediate | No memory access |
| Very Fast | Zero Page, Zero Page,X/Y | 8-bit address, fast access |
| Fast | Absolute, Absolute,X/Y | Direct addressing |
| Slower | Indirect modes | Multiple memory accesses |

### Space Considerations

| Size | Modes | Bytes |
|------|-------|-------|
| Smallest | Implied, Accumulator | 1 |
| Small | Immediate, Zero Page, Relative | 2 |
| Larger | Absolute | 3 |

### Choosing the Right Mode

**For Constants:**
- Use Immediate mode: `LDA #$42`

**For Variables:**
- If address < $100: Use Zero Page: `LDA $80`
- If address >= $100: Use Absolute: `LDA $2000`

**For Arrays:**
- Small arrays: Zero Page,X: `LDA $80,X`
- Large arrays: Absolute,X/Y: `LDA $2000,X`

**For Indirect Access:**
- Fixed offset: (Indirect),Y: `LDA ($80),Y`
- Multiple pointers: (Indirect,X): `LDA ($80,X)`
- Simple pointer (W65C02): (Indirect): `LDA ($80)`

**For Branches:**
- Always Relative (no choice)
- Range: -128 to +127 bytes
- Use JMP for longer distances

---

## Common Patterns

### Array Processing
```asm
    LDX #$00
loop:
    LDA data,X      ; Absolute,X
    JSR process
    INX
    CPX #$10
    BNE loop
```

### String Processing
```asm
    LDA #<string
    STA $80
    LDA #>string
    STA $81
    
    LDY #$00
loop:
    LDA ($80),Y     ; Indirect,Y
    BEQ done
    JSR print
    INY
    BNE loop
done:
```

### Jump Table
```asm
    ; W65C02
    LDA option
    ASL A           ; × 2 for word addresses
    TAX
    JMP (table,X)   ; Indexed indirect
    
table:
    .word option0, option1, option2
```

### Bitmap Graphics
```asm
    ; Y = row, X = column
    LDA #$20        ; Screen base
    STA $81
    LDA #$00
    STA $80         ; $80-$81 = row pointer
    
    LDA ($80),Y     ; Read pixel
    STA ($80),Y     ; Write pixel
```

---

## Cycle Timing Summary

| Mode | Read | Write | RMW† | Notes |
|------|------|-------|------|-------|
| Implied/Accumulator | 2 | - | 2 | - |
| Immediate | 2 | - | - | Read only |
| Zero Page | 3 | 3 | 5 | - |
| Zero Page,X/Y | 4 | 4 | 6 | - |
| Absolute | 4 | 4 | 6 | - |
| Absolute,X/Y | 4+ | 5 | 7 | +1 if page crossed (read) |
| Relative | 2+ | - | - | +1 if taken, +2 if page crossed |
| Indirect | 5-6 | - | - | JMP only |
| (Indirect,X) | 6 | 6 | - | - |
| (Indirect),Y | 5+ | 6 | - | +1 if page crossed (read) |
| (Indirect) | 5 | 5 | - | W65C02 only |

† RMW = Read-Modify-Write (INC, DEC, ASL, LSR, ROL, ROR)

---

## Addressing Mode Availability

Not all instructions support all modes. Consult the instruction reference for specific availability.

**Most Flexible:** LDA, STA, ADC, SBC, AND, ORA, EOR, CMP  
**Limited:** LDX/STX (no Indirect), LDY/STY (no Indirect)  
**Mode-Specific:** JMP (Indirect only), Branches (Relative only)  

---

## Best Practices

1. **Use Zero Page aggressively** - It's your fastest memory
2. **Reserve $00-$7F for variables** - System uses upper zero page
3. **Keep frequently accessed data in Zero Page**
4. **Use STZ** (W65C02) instead of LDA #0; STA
5. **Prefer Absolute,X over (Indirect),Y** when possible (faster)
6. **Mind page boundaries** on indexed reads for performance
7. **Use BRA** (W65C02) instead of JMP for short unconditional branches
8. **Align jump tables** to avoid page boundaries when using indirect modes

---

## Quick Memory Access Comparison

```asm
; Immediate - 2 cycles
LDA #$42        ; A = $42

; Zero Page - 3 cycles  
LDA $80         ; A = [$0080]

; Absolute - 4 cycles
LDA $2000       ; A = [$2000]

; Zero Page,X - 4 cycles
LDA $80,X       ; A = [$0080 + X]

; Absolute,X - 4-5 cycles
LDA $2000,X     ; A = [$2000 + X]

; (Indirect),Y - 5-6 cycles
LDA ($80),Y     ; A = [[$0080-$0081] + Y]

; (Indirect,X) - 6 cycles
LDA ($80,X)     ; A = [[$0080 + X]]

; (Indirect) - 5 cycles (W65C02)
LDA ($80)       ; A = [[$0080-$0081]]
```

---

## Addressing Mode Syntax Summary

| Symbol | Meaning |
|--------|---------|
| `#` | Immediate value |
| `$nn` | Zero page address (8-bit) |
| `$nnnn` | Absolute address (16-bit) |
| `,X` | Add X register |
| `,Y` | Add Y register |
| `($nnnn)` | Indirect (pointer) |
| `($nn,X)` | Indexed indirect (add X first) |
| `($nn),Y` | Indirect indexed (add Y after) |
| `($nn)` | Zero page indirect (W65C02) |

---

## References

- WDC W65C02S Datasheet
- Programming the 65816 (includes 65C02)
- 6502.org Documentation
