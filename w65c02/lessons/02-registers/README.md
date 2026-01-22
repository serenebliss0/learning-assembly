# Lesson 02: Registers and Flags - The CPU's Internal State

Now that you've written your first program, let's explore the 6502's internal architecture: its registers and status flags. Understanding these is crucial for mastering assembly programming.

## Learning Objectives

By the end of this lesson, you'll:
- Understand all W65C02 registers and their purposes
- Know how to use and manipulate status flags
- Master register transfer operations
- Understand the stack and stack pointer
- Be able to work with the processor status register

## The W65C02 Register Set

The W65C02 has a minimal, elegant register set:

**General Purpose:**
- **A** (Accumulator) - 8-bit, main working register
- **X** (Index Register) - 8-bit, for indexing and counting
- **Y** (Index Register) - 8-bit, for indexing and counting

**Special Purpose:**
- **PC** (Program Counter) - 16-bit, points to next instruction
- **S** (Stack Pointer) - 8-bit, points to top of stack (page $01)
- **P** (Processor Status) - 8-bit, contains status flags

## The Status Flags (P Register)

The P register contains 8 flags that track the CPU state:

```
7  6  5  4  3  2  1  0
N  V  -  B  D  I  Z  C
```

- **N** (Negative) - Set if bit 7 of result is 1 (negative in signed arithmetic)
- **V** (Overflow) - Set if signed overflow occurred
- **-** (Unused) - Always 1
- **B** (Break) - Set when BRK instruction is executed
- **D** (Decimal) - Set for BCD (Binary Coded Decimal) mode
- **I** (Interrupt Disable) - Set to disable IRQ interrupts
- **Z** (Zero) - Set if result is zero
- **C** (Carry) - Set on carry/borrow in arithmetic

## The Code

Create a file called `registers.s`:

```asm
; registers.s - Exploring registers and flags
; This program demonstrates register operations and flag behavior

.segment "CODE"
.org $8000

reset:
    ; === Accumulator Operations ===
    LDA #$42            ; Load $42 into A
    STA $0200           ; Store to memory
    
    ; === X Register Operations ===
    LDX #$10            ; Load $10 into X
    STX $0201           ; Store X to memory
    
    ; === Y Register Operations ===
    LDY #$20            ; Load $20 into Y
    STY $0202           ; Store Y to memory
    
    ; === Register Transfers ===
    LDA #$FF            ; Load $FF into A
    TAX                 ; Transfer A to X (X = $FF)
    TAY                 ; Transfer A to Y (Y = $FF)
    
    LDA #$00            ; Clear A
    TXA                 ; Transfer X to A (A = $FF again)
    
    ; === Testing the Zero Flag ===
    LDA #$00            ; Load zero - sets Z flag
    STA $0203           ; Store result
    
    LDA #$01            ; Load non-zero - clears Z flag
    STA $0204           ; Store result
    
    ; === Testing the Negative Flag ===
    LDA #$80            ; Load $80 (bit 7 set) - sets N flag
    STA $0205           ; Store result
    
    LDA #$7F            ; Load $7F (bit 7 clear) - clears N flag
    STA $0206           ; Store result
    
    ; === Stack Operations ===
    LDA #$55            ; Load test value
    PHA                 ; Push A onto stack
    LDA #$00            ; Clear A
    PLA                 ; Pull from stack back to A (A = $55 again)
    
    ; === Flag Manipulation ===
    SEC                 ; Set Carry flag
    CLC                 ; Clear Carry flag
    
    SEI                 ; Set Interrupt disable
    CLI                 ; Clear Interrupt disable
    
    SED                 ; Set Decimal mode
    CLD                 ; Clear Decimal mode
    
    CLV                 ; Clear Overflow flag

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Loading and Storing Registers

```asm
LDA #$42            ; Load immediate value into A
STA $0200           ; Store A to memory address $0200
```

Each register has its own load/store instructions:
- **A**: `LDA` (load), `STA` (store)
- **X**: `LDX` (load), `STX` (store)
- **Y**: `LDY` (load), `STY` (store)

### Register Transfer Instructions

```asm
TAX                 ; Transfer A to X
TAY                 ; Transfer A to Y
TXA                 ; Transfer X to A
TYA                 ; Transfer Y to A
TSX                 ; Transfer Stack pointer to X
TXS                 ; Transfer X to Stack pointer
```

**Important:** Transfers set the N and Z flags based on the value transferred!

```asm
LDA #$00
TAX                 ; X = 0, sets Z flag
TAY                 ; Y = 0, sets Z flag (still set)

LDA #$80
TAX                 ; X = $80, sets N flag (bit 7 is 1)
```

### The Zero Flag (Z)

The Z flag is set whenever an operation produces zero:

```asm
LDA #$00            ; Z flag SET (result is zero)
LDA #$01            ; Z flag CLEAR (result is non-zero)

LDA #$05
SBC #$05            ; Subtract 5 from 5 = 0, Z flag SET

LDX #$00            ; Z flag SET
INX                 ; X = 1, Z flag CLEAR
DEX                 ; X = 0, Z flag SET
```

We use Z flag for branching:
- `BEQ` - Branch if Equal (if Z = 1)
- `BNE` - Branch if Not Equal (if Z = 0)

### The Negative Flag (N)

The N flag mirrors bit 7 of the result:

```asm
LDA #$7F            ; %01111111 - N flag CLEAR (bit 7 = 0)
LDA #$80            ; %10000000 - N flag SET (bit 7 = 1)
LDA #$FF            ; %11111111 - N flag SET (bit 7 = 1)
```

In signed arithmetic, bit 7 = 1 means negative:
- `$00-$7F` = 0 to 127 (positive)
- `$80-$FF` = -128 to -1 (negative)

Branching with N flag:
- `BMI` - Branch if Minus (if N = 1)
- `BPL` - Branch if Plus (if N = 0)

### The Carry Flag (C)

The carry flag tracks overflow in addition and borrow in subtraction:

```asm
CLC                 ; Clear Carry (always do before ADC)
LDA #$FF
ADC #$02            ; $FF + $02 = $101, A = $01, C flag SET

SEC                 ; Set Carry (always do before SBC)
LDA #$05
SBC #$03            ; $05 - $03 = $02, A = $02, C flag SET (no borrow)

SEC
LDA #$03
SBC #$05            ; $03 - $05 = -$02 = $FE, C flag CLEAR (borrow)
```

Branching with C flag:
- `BCS` - Branch if Carry Set
- `BCC` - Branch if Carry Clear

### The Stack

The stack grows **downward** from $01FF to $0100 (page $01):

```asm
LDA #$42
PHA                 ; Push A to stack (S decreases)
LDA #$99            ; Change A
PLA                 ; Pull from stack to A (A = $42, S increases)

PHP                 ; Push P (status flags) to stack
PLP                 ; Pull from stack to P
```

Stack pointer starts at $FF (pointing to $01FF) and decreases with each push.

**Common use:** Save/restore registers in subroutines:

```asm
subroutine:
    PHA                 ; Save A
    TXA
    PHA                 ; Save X
    
    ; ... do work ...
    
    PLA
    TAX                 ; Restore X
    PLA                 ; Restore A
    RTS
```

## Practical Example: Finding Maximum Value

Let's write a program that finds the maximum of two numbers:

```asm
; max.s - Find the maximum of two numbers

.segment "CODE"
.org $8000

reset:
    LDA #$42            ; First number
    LDX #$37            ; Second number
    
    ; Compare A with X
    STX $00             ; Store X temporarily
    CMP $00             ; Compare A with memory
    BCS a_is_bigger     ; Branch if A >= X (C set)
    
    ; X is bigger
    TXA                 ; Move X to A
    JMP store_result
    
a_is_bigger:
    ; A is already the bigger value
    
store_result:
    STA $0200           ; Store result (the maximum)

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

The `CMP` instruction subtracts without storing the result - only sets flags!

## Experiments

### Experiment 1: Trace the Flags

Step through this code and watch the flags:

```asm
LDA #$00            ; Z=1, N=0
LDA #$80            ; Z=0, N=1
LDA #$7F            ; Z=0, N=0

CLC
LDA #$FF
ADC #$01            ; What are the flags now?
```

Use `registers` command in py65mon to see flags after each instruction.

### Experiment 2: Stack Underflow

What happens if you do:

```asm
LDA #$42
PHA                 ; S = $FE
PLA                 ; S = $FF
PLA                 ; S = $00 (wraps around!)
PLA                 ; S = $FF (wraps again!)
```

The stack pointer wraps! This can cause bugs if you pop more than you push.

### Experiment 3: Register Juggling

Move a value from X to Y without using A:

```asm
LDX #$42            ; X = $42
; How to get this to Y without using A or memory?
```

**Spoiler:** You can't directly! Must use `TXA` then `TAY`, or use memory. This shows the importance of the accumulator.

## Exercises

**Exercise 1:** Write a program that swaps the values in A and X.

Hint: You'll need to use the stack or a memory location.

<details>
<summary>Solution to Exercise 1</summary>

```asm
; Using the stack
LDA #$42
LDX #$99
PHA                 ; Push A
TXA                 ; A = X
TAX                 ; X = old A (on stack)
PLA                 ; A = old X
TAX                 ; X = old X (wait, this doesn't work!)

; Correct solution with stack:
LDA #$42
LDX #$99
PHA                 ; Save A on stack
TXA                 ; A = X (A now has X's value)
TAY                 ; Y = X (temporary save)
PLA                 ; A = original A
TAX                 ; X = original A
TYA                 ; A = original X

; Or simpler with memory:
LDA #$42
LDX #$99
STA $00             ; Save A to memory
TXA                 ; A = X
LDX $00             ; X = old A
```
</details>

**Exercise 2:** Write a program that counts from 0 to 10 using X, storing each value to memory locations $0200-$020A.

<details>
<summary>Solution to Exercise 2</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDX #$00            ; Counter = 0
    
loop:
    TXA                 ; Transfer count to A
    STA $0200,X         ; Store to $0200 + X
    INX                 ; Increment counter
    CPX #$0B            ; Compare with 11
    BNE loop            ; Continue if not 11

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 3:** Implement absolute value. If A contains $80-$FF (negative), convert it to positive. If A contains $00-$7F (positive), leave it unchanged.

Hint: Check the N flag after loading. If negative, negate the number using `EOR #$FF` followed by `ADC #$01` (two's complement).

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDA #$FB            ; -5 in signed representation
    
    BPL positive        ; Branch if positive (N=0)
    
    ; Number is negative, negate it
    EOR #$FF            ; Flip all bits
    CLC
    ADC #$01            ; Add 1 (two's complement)
    
positive:
    STA $0200           ; Store absolute value

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: The Processor Status Register

Each flag bit can be manipulated:

| Flag | Set | Clear | Test Branches |
|------|-----|-------|---------------|
| **C** | `SEC` | `CLC` | `BCS`, `BCC` |
| **Z** | (arithmetic) | (arithmetic) | `BEQ`, `BNE` |
| **I** | `SEI` | `CLI` | - |
| **D** | `SED` | `CLD` | - |
| **V** | (arithmetic) | `CLV` | `BVS`, `BVC` |
| **N** | (arithmetic) | (arithmetic) | `BMI`, `BPL` |

You can also:
- `PHP` - Push P to stack
- `PLP` - Pull from stack to P

The B flag only exists when P is pushed to stack (distinguishes BRK from IRQ).

## Deep Dive: Why Only 8-bit?

Modern CPUs have 32-bit or 64-bit registers. Why is the 6502 only 8-bit?

**Historical Context:** In 1975, when the 6502 was designed:
- Transistors were expensive
- 8-bit was the standard
- Simple design meant low cost ($25 vs $300 for competitors)

**Advantages:**
- Easy to understand and program
- Fast (simple = fast in hardware)
- Sufficient for most tasks at the time

**Working with 16-bit values:**

We'll use **two bytes**:
```asm
; Store 16-bit value $1234
LDA #$34            ; Low byte
STA $00
LDA #$12            ; High byte
STA $01
```

We'll explore multi-byte arithmetic in Lesson 4!

## Deep Dive: Register Usage Conventions

While there are no enforced conventions, experienced 6502 programmers often:

- **A** - Main arithmetic, function return values
- **X** - Array/string indexing, loop counters
- **Y** - Secondary indexing, loop counters
- **Zero page** ($00-$FF) - Fast temporary variables

Example:
```asm
; Process array of bytes
LDX #$00            ; X = index
loop:
    LDA array,X     ; A = load from array
    ; ... process value in A ...
    STA result,X    ; Store result
    INX
    CPX #$10        ; Processed 16 items?
    BNE loop
```

## Common Errors

### Error: Forgetting to clear/set carry

```asm
LDA #$05
ADC #$03            ; WRONG! Carry might be set from before
```

**Solution:** Always `CLC` before `ADC`, `SEC` before `SBC`:

```asm
CLC
LDA #$05
ADC #$03            ; Correct
```

### Error: Assuming transfer doesn't affect flags

```asm
LDA #$00            ; Z flag set
TAX                 ; Z flag STILL set (X = 0)
TXA                 ; Z flag STILL set (A = 0)
```

Transfers DO affect N and Z flags!

### Error: Comparing without understanding CMP

```asm
LDA #$05
CMP #$03            ; Sets flags, doesn't change A!
STA $0200           ; Stores $05, not comparison result
```

`CMP` only sets flags for branching, doesn't store a result.

## Key Takeaways

✅ **Three general registers:** A (accumulator), X, Y (indexes)

✅ **A is special:** Most operations require the accumulator

✅ **Transfers:** `TAX`, `TAY`, `TXA`, `TYA` move values between registers

✅ **Status flags:** Z (zero), N (negative), C (carry), V (overflow) track results

✅ **Stack:** Grows downward from $01FF, use `PHA`/`PLA` to save/restore

✅ **CLC before ADC, SEC before SBC** - don't forget the carry!

✅ **Transfers affect flags** - they set N and Z based on the value

## Next Lesson

Ready to explore how the 6502 accesses memory?
**[Lesson 03: Addressing Modes →](../03-addressing/)**

Or master these concepts with more experiments first!

---

## Quick Reference

**Register Operations:**
```
LDA/LDX/LDY  - Load register
STA/STX/STY  - Store register
TAX/TAY/TXA/TYA - Transfer between registers
```

**Stack Operations:**
```
PHA  - Push A to stack
PLA  - Pull from stack to A
PHP  - Push status flags
PLP  - Pull status flags
```

**Flag Operations:**
```
CLC/SEC  - Clear/Set Carry
CLI/SEI  - Clear/Set Interrupt disable
CLD/SED  - Clear/Set Decimal mode
CLV      - Clear Overflow
```

**Status Flags:**
```
N V - B D I Z C
↑ ↑   ↑ ↑ ↑ ↑ ↑
│ │   │ │ │ │ └─ Carry
│ │   │ │ │ └─── Zero
│ │   │ │ └───── Interrupt disable
│ │   │ └─────── Decimal mode
│ │   └───────── Break
│ └───────────── Overflow
└─────────────── Negative
```

---

*You now understand the 6502's internal state!* 🎯
