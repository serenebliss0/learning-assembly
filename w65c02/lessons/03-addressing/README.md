# Lesson 03: Addressing Modes - How the CPU Accesses Memory

The 6502's power lies in its flexible addressing modes. These determine HOW an instruction accesses memory. Mastering addressing modes is essential for efficient 6502 programming.

## Learning Objectives

By the end of this lesson, you'll:
- Understand all W65C02 addressing modes
- Know when to use each addressing mode
- Understand the speed and size tradeoffs
- Be able to work with arrays and data structures
- Master indirect addressing for pointers

## What Are Addressing Modes?

An addressing mode specifies where an operand comes from or goes to. Consider `LDA`:

```asm
LDA #$42        ; Load the VALUE $42
LDA $42         ; Load FROM address $42
LDA $1234       ; Load FROM address $1234
LDA ($42)       ; Load FROM address stored AT $42
```

Same instruction, different meanings! The addressing mode changes everything.

## The W65C02 Addressing Modes

The W65C02 has 13 addressing modes:

1. **Immediate** - Use a literal value
2. **Absolute** - Use a 16-bit address
3. **Zero Page** - Use an 8-bit address (page 0)
4. **Implied** - No operand needed
5. **Accumulator** - Operate on A register
6. **Absolute,X** - Absolute address + X
7. **Absolute,Y** - Absolute address + Y
8. **Zero Page,X** - Zero page address + X
9. **Zero Page,Y** - Zero page address + Y (rare)
10. **Indirect** - Address contains address
11. **Indexed Indirect (,X)** - Zero page pointer + X
12. **Indirect Indexed (,Y)** - Zero page pointer, then + Y
13. **Relative** - PC-relative (for branches)

Let's explore each!

## The Code

Create a file called `addressing.s`:

```asm
; addressing.s - Demonstrating all addressing modes

.segment "CODE"
.org $8000

reset:
    ; === 1. IMMEDIATE MODE ===
    ; Format: #value
    ; Use: Load a constant
    LDA #$42            ; Load literal value $42 into A
    LDX #$10            ; Load literal value $10 into X
    LDY #$20            ; Load literal value $20 into Y
    
    ; === 2. ZERO PAGE MODE ===
    ; Format: address (00-FF)
    ; Use: Fast access to first 256 bytes
    STA $50             ; Store A to address $0050
    LDA $50             ; Load from address $0050
    
    LDX #$99
    STX $51             ; Store X to address $0051
    
    ; === 3. ABSOLUTE MODE ===
    ; Format: address (0000-FFFF)
    ; Use: Access any memory location
    STA $0200           ; Store A to address $0200
    LDA $0200           ; Load from address $0200
    
    ; === 4. IMPLIED MODE ===
    ; Format: (no operand)
    ; Use: Operations with implicit operands
    TAX                 ; Transfer A to X (implied)
    INX                 ; Increment X (implied)
    CLC                 ; Clear carry (implied)
    NOP                 ; No operation (implied)
    
    ; === 5. ACCUMULATOR MODE ===
    ; Format: A
    ; Use: Operate directly on accumulator
    LDA #$0F
    ASL A               ; Shift A left (A = $1E)
    LSR A               ; Shift A right (A = $0F)
    ROL A               ; Rotate A left
    ROR A               ; Rotate A right
    
    ; === 6. ZERO PAGE,X MODE ===
    ; Format: address,X
    ; Use: Fast indexed access in zero page
    LDX #$05
    LDA #$AA
    STA $50,X           ; Store to $0050 + $05 = $0055
    
    LDX #$00
loop1:
    TXA
    STA $60,X           ; Store X value to $60+X
    INX
    CPX #$10
    BNE loop1
    
    ; === 7. ZERO PAGE,Y MODE ===
    ; Format: address,Y
    ; Use: Like ZP,X but with Y (only STX/LDX use this)
    LDY #$03
    LDX #$77
    STX $70,Y           ; Store X to $0070 + $03 = $0073
    
    ; === 8. ABSOLUTE,X MODE ===
    ; Format: address,X
    ; Use: Indexed access anywhere in memory
    LDX #$05
    LDA #$BB
    STA $0300,X         ; Store to $0300 + $05 = $0305
    
    ; Array processing example
    LDX #$00
loop2:
    LDA array,X         ; Load from array + X
    STA $0400,X         ; Copy to $0400 + X
    INX
    CPX #$08            ; 8 bytes
    BNE loop2
    
    ; === 9. ABSOLUTE,Y MODE ===
    ; Format: address,Y
    ; Use: Like Absolute,X but with Y
    LDY #$03
    LDA #$CC
    STA $0500,Y         ; Store to $0500 + $03 = $0503
    
    ; === 10. INDIRECT MODE ===
    ; Format: (address)
    ; Use: Jump through pointer (JMP only)
    LDA #$00
    STA $80             ; Store low byte of address
    LDA #$82
    STA $81             ; Store high byte of address
    ; Now $80-$81 contains $8200
    JMP ($0080)         ; Jump to address stored at $80-$81
    
continue:
    ; === 11. INDEXED INDIRECT (,X) MODE ===
    ; Format: (address,X)
    ; Use: Pointer table in zero page
    
    ; Set up pointer at $40-$41
    LDA #$00
    STA $40             ; Low byte
    LDA #$06
    STA $41             ; High byte (pointer to $0600)
    
    LDX #$00
    LDA #$DD
    STA ($40,X)         ; Store via pointer at ($40+0)
    
    ; === 12. INDIRECT INDEXED (,Y) MODE ===
    ; Format: (address),Y
    ; Use: Process array via pointer
    
    ; Set up pointer at $42-$43
    LDA #$00
    STA $42             ; Low byte
    LDA #$07
    STA $43             ; High byte (pointer to $0700)
    
    LDY #$00
loop3:
    TYA
    STA ($42),Y         ; Store via pointer + Y offset
    INY
    CPY #$10
    BNE loop3

done:
    JMP done

; === Data ===
array:
    .byte $01, $02, $03, $04, $05, $06, $07, $08

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### 1. Immediate Mode (#value)

```asm
LDA #$42            ; A = $42
```

- Fastest mode (value is right there)
- 2 bytes: opcode + value
- Use for: Constants, initialization

**Syntax:** Always use `#` prefix!

### 2. Zero Page ($00-$FF)

```asm
LDA $50             ; Load from address $0050
STA $50             ; Store to address $0050
```

- Fast (3 cycles vs 4 for absolute)
- 2 bytes: opcode + zero page address
- Use for: Variables, temporary storage

**Why faster?** Only need to specify 8 bits, not 16!

### 3. Absolute ($0000-$FFFF)

```asm
LDA $0200           ; Load from address $0200
STA $1234           ; Store to address $1234
```

- Access any address in memory
- 3 bytes: opcode + low byte + high byte
- Use for: General memory access, arrays, I/O

### 4. Implied

```asm
TAX                 ; Transfer A to X
INX                 ; Increment X
CLC                 ; Clear carry
```

- No operand needed
- 1 byte: just opcode
- Use for: Register operations, flag operations

### 5. Accumulator

```asm
ASL A               ; Shift A left
LSR A               ; Shift A right
ROL A               ; Rotate A left
```

- Operate on accumulator
- 1 byte: just opcode
- Use for: Bit shifting, rotation

Some assemblers let you write just `ASL` (without the `A`).

### 6. Zero Page,X ($00,X)

```asm
LDX #$05
LDA $50,X           ; Load from $0050 + $05 = $0055
```

- Fast indexed access (4 cycles)
- Wraps around: $FF,X with X=$02 = $01 (not $101!)
- Use for: Small arrays, lookup tables

**Example: Processing array in zero page**

```asm
LDX #$00
loop:
    LDA $80,X       ; Process bytes at $80-$8F
    ; ... do something ...
    INX
    CPX #$10
    BNE loop
```

### 7. Zero Page,Y ($00,Y)

```asm
LDY #$03
LDX #$77
STX $70,Y           ; Store X to $0070 + $03 = $0073
```

- Like ZP,X but with Y
- **Only STX and LDX** use this mode!
- Rarely needed

### 8. Absolute,X ($0000,X)

```asm
LDX #$05
LDA $0300,X         ; Load from $0300 + $05 = $0305
```

- Indexed access anywhere in memory
- 4 cycles (5 if crosses page boundary)
- Use for: Large arrays, tables

**Page boundary:** If $0300 + X crosses into next page ($0400), takes extra cycle.

### 9. Absolute,Y ($0000,Y)

```asm
LDY #$03
LDA $0500,Y         ; Load from $0500 + $03 = $0503
```

- Like Absolute,X but with Y
- Same timing rules
- Use for: 2D arrays, when X is busy

### 10. Indirect (address)

```asm
JMP ($0080)         ; Jump to address stored at $80-$81
```

- **Only works with JMP!**
- Reads 16-bit address from memory, jumps there
- Use for: Jump tables, function pointers

**Example: Jump table**

```asm
; Jump table
.org $0080
.word routine1      ; $80-$81
.word routine2      ; $82-$83
.word routine3      ; $84-$85

; Select routine
LDA #$02            ; Index = 2
ASL A               ; Multiply by 2 (each pointer is 2 bytes)
TAX
JMP ($0080,X)       ; Jump to routine 2 (wait, can't do this!)

; Actually need:
LDA #$02
ASL A               ; A = $04
CLC
ADC #$80
STA $00             ; Store $84 to $00
LDA #$00
STA $01             ; Store $00 to $01
JMP ($00)           ; Jump through pointer
```

**Warning:** 6502 bug! If address is $xxFF, high byte reads from $xx00, not $xx00+$100!

### 11. Indexed Indirect (($00,X))

```asm
LDX #$00
LDA ($40,X)         ; Load from address stored at ($40+X)
```

This is complex:
1. Add X to zero page address: $40 + X
2. Read 16-bit pointer from that location
3. Load from that pointer

**Example:**

```asm
; Set up pointer at $40-$41
LDA #$00
STA $40             ; Low byte
LDA #$05
STA $41             ; High byte ($0500)

LDX #$00
LDA ($40,X)         ; Load from address at $40+0 = $40-$41 = $0500
```

Use for: Pointer tables in zero page

### 12. Indirect Indexed (($00),Y)

```asm
LDY #$05
LDA ($42),Y         ; Load from (address at $42) + Y
```

This is also complex:
1. Read 16-bit pointer from zero page address
2. Add Y to that pointer
3. Load from result

**Example:**

```asm
; Set up pointer at $42-$43
LDA #$00
STA $42             ; Low byte
LDA #$06
STA $43             ; High byte ($0600)

LDY #$05
LDA ($42),Y         ; Load from $0600 + $05 = $0605
```

Use for: Processing arrays via pointer

### 13. Relative (branches)

```asm
BEQ label           ; Branch if equal
```

- Adds signed 8-bit offset to PC
- Range: -128 to +127 bytes
- Use for: All branch instructions

**Only works with branch instructions:**
- `BEQ`, `BNE`, `BCS`, `BCC`, `BMI`, `BPL`, `BVS`, `BVC`

The assembler calculates the offset automatically!

## Indexed Indirect vs Indirect Indexed

These are confusing! Here's the difference:

### Indexed Indirect: (zp,X)

```
1. Start with zero page address
2. Add X
3. Read pointer from that location
4. Access memory there

Example: ($40,X) with X=$02
→ Read pointer from $42-$43
→ Access that address
```

**Use:** Pointer table (array of pointers)

### Indirect Indexed: (zp),Y

```
1. Start with zero page address
2. Read pointer from that location
3. Add Y
4. Access memory there

Example: ($40),Y with Y=$05
→ Read pointer from $40-$41
→ Add $05 to that pointer
→ Access result
```

**Use:** Process array via pointer

**Mnemonic:**
- **(zp,X)** - X goes INSIDE parentheses → adjust pointer location
- **(zp),Y** - Y goes OUTSIDE parentheses → adjust final address

## Practical Example: String Copy

Let's copy a string using different addressing modes:

```asm
; strcpy.s - Copy a string using pointers

.segment "CODE"
.org $8000

reset:
    ; Set up source pointer at $40-$41
    LDA #<source        ; Low byte
    STA $40
    LDA #>source        ; High byte
    STA $41
    
    ; Set up dest pointer at $42-$43
    LDA #<dest          ; Low byte
    STA $42
    LDA #>dest          ; High byte
    STA $43
    
    ; Copy loop using indirect indexed
    LDY #$00
copy_loop:
    LDA ($40),Y         ; Load from source + Y
    STA ($42),Y         ; Store to dest + Y
    BEQ done            ; Stop if null terminator
    INY
    JMP copy_loop

done:
    JMP done

source:
    .byte "Hello!", $00

dest:
    .res 20             ; Reserve 20 bytes

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Speed and Size Comparison

| Mode | Bytes | Cycles | Example |
|------|-------|--------|---------|
| Immediate | 2 | 2 | `LDA #$42` |
| Zero Page | 2 | 3 | `LDA $50` |
| Zero Page,X | 2 | 4 | `LDA $50,X` |
| Absolute | 3 | 4 | `LDA $0200` |
| Absolute,X | 3 | 4* | `LDA $0200,X` |
| Absolute,Y | 3 | 4* | `LDA $0200,Y` |
| Indexed Indirect | 2 | 6 | `LDA ($40,X)` |
| Indirect Indexed | 2 | 5* | `LDA ($40),Y` |

\* Add 1 cycle if page boundary crossed

**Lesson:** Zero page is fast! Use it for frequently accessed variables.

## Experiments

### Experiment 1: Page Boundary Crossing

```asm
LDX #$00
LDA $01FF,X         ; 4 cycles (no crossing)

LDX #$01
LDA $01FF,X         ; 5 cycles (crosses to $0200)
```

Step through and count cycles!

### Experiment 2: Zero Page Wrap

```asm
LDX #$05
LDA $FE,X           ; Accesses $FE + $05 = $03 (wraps!)
```

Zero page,X wraps within zero page, not to $0103!

### Experiment 3: Indirect Bug

```asm
; Set up test
LDA #$00
STA $80
LDA #$90
STA $81             ; Pointer = $9000

JMP ($0080)         ; Works fine

; But:
LDA #$00
STA $FF
LDA #$90
STA $00             ; Should be high byte, but...

JMP ($00FF)         ; Bug! Reads low from $FF, high from $00 (not $100)!
```

Always avoid pointers at $xxFF!

## Exercises

**Exercise 1:** Write a program that fills memory $0200-$02FF with value $AA using Absolute,X addressing.

<details>
<summary>Solution to Exercise 1</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDX #$00
    LDA #$AA
    
loop:
    STA $0200,X
    INX
    BNE loop            ; Loop until X wraps to 0

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 2:** Implement a function that returns the length of a null-terminated string. String address is in $40-$41.

<details>
<summary>Solution to Exercise 2</summary>

```asm
.segment "CODE"
.org $8000

reset:
    ; Set up pointer to string
    LDA #<teststr
    STA $40
    LDA #>teststr
    STA $41
    
    ; Count length
    LDY #$00
count:
    LDA ($40),Y
    BEQ found_end
    INY
    JMP count
    
found_end:
    ; Y now contains length
    STY $0200           ; Store result

done:
    JMP done

teststr:
    .byte "Testing", $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 3:** Create a pointer table with 3 pointers, then use indexed indirect addressing to call different routines.

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

reset:
    ; Set up pointer table in zero page
    LDA #<routine1
    STA $40
    LDA #>routine1
    STA $41
    
    LDA #<routine2
    STA $42
    LDA #>routine2
    STA $43
    
    LDA #<routine3
    STA $44
    LDA #>routine3
    STA $45
    
    ; Select routine 1 (index 0)
    LDX #$00
    JMP ($40,X)         ; Can't do this! JMP doesn't support indexed indirect
    
    ; Actually need to use subroutine:
    LDX #$00
    JSR call_via_pointer

done:
    JMP done

call_via_pointer:
    ; This is tricky! Need to set up indirect jump
    LDA $40,X
    STA temp
    LDA $41,X
    STA temp+1
    JMP (temp)

routine1:
    LDA #$01
    STA $0200
    RTS

routine2:
    LDA #$02
    STA $0200
    RTS

routine3:
    LDA #$03
    STA $0200
    RTS

temp:
    .word $0000

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: Why So Many Modes?

Each addressing mode solves a specific problem:

- **Immediate** - Constants
- **Zero Page** - Fast variables
- **Absolute** - General memory
- **Indexed** - Arrays and strings
- **Indirect** - Pointers and tables

The 6502's designers wanted:
1. **Speed** - Zero page is fastest
2. **Flexibility** - Absolute works anywhere
3. **Power** - Indirect enables advanced techniques

The tradeoff: Complexity! But once mastered, these modes make 6502 very powerful.

## Deep Dive: Zero Page as "Registers"

Modern CPUs have many registers. The 6502 has only three (A, X, Y).

**Solution:** Treat zero page as extra "registers"!

```asm
; Zero page "registers"
temp1   = $10
temp2   = $11
counter = $12
pointer = $20           ; 2 bytes: $20-$21

; Use like registers
LDA temp1
CLC
ADC temp2
STA counter
```

Benefits:
- Fast (3 cycles vs 4 for absolute)
- Small (2 bytes vs 3)
- Can use indexed: `LDA pointer,X`

Many 6502 programs reserve $00-$7F for zero page variables.

## Deep Dive: The 6502 Indirect Bug

The 6502 has a famous bug in indirect JMP:

```asm
JMP ($02FF)
```

Should read:
- Low byte from $02FF
- High byte from $0300

Actually reads:
- Low byte from $02FF
- High byte from $0200 (wraps within page!)

**Workaround:** Never put pointers at $xxFF!

The W65C02 **fixes this bug** in some indirect modes, but `JMP indirect` still has it for compatibility.

## Common Errors

### Error: Forgetting # for immediate

```asm
LDA 42              ; WRONG: Loads from address $0042
LDA #42             ; CORRECT: Loads value 42
```

### Error: Using wrong indexed mode

```asm
STY $50,X           ; WRONG: STY doesn't support ZP,X
STY $50             ; CORRECT: Use zero page

LDA $50,Y           ; WRONG: No zero page,Y for LDA
LDA $50,X           ; CORRECT: Use X instead
```

### Error: Indirect with wrong instruction

```asm
LDA ($0080)         ; WRONG: LDA doesn't support simple indirect
LDA ($80,X)         ; CORRECT: Use indexed indirect
LDA ($80),Y         ; CORRECT: Or indirect indexed
```

## Key Takeaways

✅ **13 addressing modes** give the 6502 its power and flexibility

✅ **Immediate (#)** - Use for constants

✅ **Zero Page** - Fastest! Use for variables

✅ **Indexed (,X ,Y)** - Essential for arrays and loops

✅ **Indirect** - Enables pointers and advanced techniques

✅ **Page boundaries** affect timing - watch for +1 cycle

✅ **(zp,X) vs (zp),Y** - Learn the difference!

✅ **Zero page is like extra registers** - use $00-$7F for common variables

## Next Lesson

Ready to do math on the 6502?
**[Lesson 04: Arithmetic Operations →](../04-arithmetic/)**

Or practice more with addressing modes first!

---

## Quick Reference

**Basic Modes:**
```
#$42      - Immediate (literal value)
$42       - Zero page (address $0042)
$1234     - Absolute (address $1234)
A         - Accumulator
(implied) - No operand
```

**Indexed Modes:**
```
$42,X     - Zero page + X
$42,Y     - Zero page + Y (STX/LDX only)
$1234,X   - Absolute + X
$1234,Y   - Absolute + Y
```

**Indirect Modes:**
```
($1234)   - Indirect (JMP only)
($42,X)   - Indexed indirect (pointer table)
($42),Y   - Indirect indexed (array via pointer)
```

**Speed (cycles for LDA):**
```
Immediate:        2 cycles
Zero Page:        3 cycles
Zero Page,X:      4 cycles
Absolute:         4 cycles
Absolute,X/Y:     4-5 cycles (page boundary)
Indexed Indirect: 6 cycles
Indirect Indexed: 5-6 cycles (page boundary)
```

---

*You now understand how the 6502 accesses memory!* 🎯
