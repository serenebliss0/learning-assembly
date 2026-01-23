# Lesson 04: Arithmetic Operations - Math on the 6502

The 6502 may be simple, but it can handle complex arithmetic! In this lesson, we'll explore addition, subtraction, increment/decrement, and multi-byte math.

## Learning Objectives

By the end of this lesson, you'll:
- Master ADC and SBC with carry flag handling
- Understand multi-byte arithmetic
- Know how to use INC, DEC, INX, INY, DEX, DEY
- Implement multiplication and division
- Work with BCD (Binary Coded Decimal) mode
- Handle signed and unsigned arithmetic

## The Arithmetic Instructions

The 6502 has a minimal but powerful instruction set for math:

**Addition & Subtraction:**
- `ADC` - Add with Carry
- `SBC` - Subtract with Carry

**Increment & Decrement:**
- `INC` - Increment memory
- `DEC` - Decrement memory
- `INX` - Increment X
- `INY` - Increment Y
- `DEX` - Decrement X
- `DEY` - Decrement Y

**No multiplication or division!** We'll build those ourselves.

## The Code

Create a file called `arithmetic.s`:

```asm
; arithmetic.s - Exploring arithmetic operations

.segment "CODE"
.org $8000

reset:
    ; === ADDITION (ADC) ===
    ; Always CLC before ADC!
    CLC
    LDA #$05
    ADC #$03            ; A = $05 + $03 = $08
    STA $0200
    
    ; Addition with carry
    CLC
    LDA #$FF
    ADC #$01            ; $FF + $01 = $100
    STA $0201           ; A = $00, Carry = 1
    
    ; === SUBTRACTION (SBC) ===
    ; Always SEC before SBC!
    SEC
    LDA #$10
    SBC #$07            ; A = $10 - $07 = $09
    STA $0202
    
    ; Subtraction with borrow
    SEC
    LDA #$05
    SBC #$08            ; $05 - $08 = -$03 = $FD
    STA $0203           ; A = $FD (253 unsigned, -3 signed)
    
    ; === INCREMENT & DECREMENT ===
    LDA #$10
    STA $0204
    INC $0204           ; Memory $0204 = $11
    INC $0204           ; Memory $0204 = $12
    
    LDA #$20
    STA $0205
    DEC $0205           ; Memory $0205 = $1F
    DEC $0205           ; Memory $0205 = $1E
    
    ; Register increment/decrement
    LDX #$00
    INX                 ; X = $01
    INX                 ; X = $02
    DEX                 ; X = $01
    
    LDY #$FF
    INY                 ; Y = $00 (wraps around)
    
    ; === 16-BIT ADDITION ===
    ; Add $1234 + $0567 = $179B
    
    ; Low bytes
    CLC
    LDA #$34            ; Low byte of $1234
    ADC #$67            ; Low byte of $0567
    STA $10             ; Result low byte: $9B
    
    ; High bytes (with carry)
    LDA #$12            ; High byte of $1234
    ADC #$05            ; High byte of $0567 + carry
    STA $11             ; Result high byte: $17
    ; Result: $179B in $10-$11
    
    ; === 16-BIT SUBTRACTION ===
    ; Subtract $1234 - $0567 = $0CCD
    
    ; Low bytes
    SEC
    LDA #$34            ; Low byte of $1234
    SBC #$67            ; Low byte of $0567
    STA $12             ; Result low byte: $CD
    
    ; High bytes (with borrow)
    LDA #$12            ; High byte of $1234
    SBC #$05            ; High byte of $0567 - borrow
    STA $13             ; Result high byte: $0C
    ; Result: $0CCD in $12-$13
    
    ; === COMPARISON ===
    LDA #$10
    CMP #$10            ; Equal: Z=1, C=1
    
    LDA #$20
    CMP #$10            ; Greater: Z=0, C=1
    
    LDA #$05
    CMP #$10            ; Less: Z=0, C=0

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Addition with ADC

```asm
CLC                 ; Clear carry (MUST DO!)
LDA #$05
ADC #$03            ; A = A + $03 + Carry
```

**ADC = Add with Carry**
- Adds the operand, accumulator, AND carry flag
- Result goes to A
- Sets C flag if result > 255

**Always CLC before ADC** (unless you want to add the carry from a previous operation!)

### Overflow Example

```asm
CLC
LDA #$FF            ; A = 255
ADC #$01            ; A + 1 = 256
; Result: A = $00, C = 1 (carry set!)
```

The carry flag indicates we overflowed 8 bits.

### Subtraction with SBC

```asm
SEC                 ; Set carry (MUST DO!)
LDA #$10
SBC #$07            ; A = A - $07 - NOT(Carry)
```

**SBC = Subtract with Carry**
- Subtracts operand and NOT(carry) from accumulator
- Result goes to A
- Sets C flag if NO borrow needed (result >= 0)

**Always SEC before SBC!** If carry is clear, you subtract an extra 1.

**Why NOT(carry)?** Historical design - carry clear = borrow. Confusing but it works!

### Borrow Example

```asm
SEC
LDA #$05            ; A = 5
SBC #$08            ; 5 - 8 = -3
; Result: A = $FD (253 unsigned, -3 in two's complement)
; C = 0 (borrow occurred)
```

### Increment and Decrement

```asm
LDA #$10
STA $0200
INC $0200           ; Memory $0200 = $11

LDX #$05
INX                 ; X = $06
DEX                 ; X = $05
```

- `INC/DEC` work on memory
- `INX/INY/DEX/DEY` work on registers
- All set Z and N flags
- **None affect C flag!**

**Wrap around:**
```asm
LDA #$FF
STA $0200
INC $0200           ; $0200 = $00 (wraps), Z = 1
```

### 16-bit Addition

```asm
; Add $1234 + $0567

CLC
LDA #$34            ; Low byte of first number
ADC #$67            ; Add low byte of second number
STA $10             ; Store result low byte ($9B)

LDA #$12            ; High byte of first number
ADC #$05            ; Add high byte + any carry
STA $11             ; Store result high byte ($17)

; Result: $179B in $10-$11
```

The carry from the low byte automatically adds to the high byte!

### 16-bit Subtraction

```asm
; Subtract $1234 - $0567

SEC
LDA #$34            ; Low byte of first number
SBC #$67            ; Subtract low byte of second number
STA $12             ; Store result low byte ($CD)

LDA #$12            ; High byte of first number
SBC #$05            ; Subtract high byte - any borrow
STA $13             ; Store result high byte ($0C)

; Result: $0CCD in $12-$13
```

The borrow from the low byte automatically subtracts from the high byte!

### Comparison with CMP

```asm
LDA #$20
CMP #$10            ; Compare A with $10
```

**CMP = Compare (A - operand, don't store result)**
- Performs subtraction but doesn't save result
- Only sets flags
- Use for conditional branching

**Results:**
- **A = operand:** Z=1, C=1
- **A > operand:** Z=0, C=1  
- **A < operand:** Z=0, C=0

```asm
LDA #$20
CMP #$10
BEQ equal           ; Branch if equal (Z=1)
BCS greater_equal   ; Branch if >= (C=1)
BCC less            ; Branch if < (C=0)
```

## Practical Example: 16-bit Counter

```asm
; counter.s - Count from 0 to 1000 ($03E8)

.segment "CODE"
.org $8000

reset:
    ; Initialize 16-bit counter at $10-$11
    LDA #$00
    STA $10             ; Low byte = 0
    STA $11             ; High byte = 0

loop:
    ; Increment 16-bit counter
    INC $10             ; Increment low byte
    BNE skip_high       ; If no wrap, skip high byte
    INC $11             ; Wrapped, increment high byte
    
skip_high:
    ; Compare with 1000 ($03E8)
    ; Check high byte first
    LDA $11
    CMP #$03
    BCC loop            ; If high < 3, continue
    BNE done            ; If high > 3, done
    
    ; High byte equals 3, check low byte
    LDA $10
    CMP #$E8
    BCC loop            ; If low < $E8, continue

done:
    ; Counter reached 1000!
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Practical Example: Multiplication

The 6502 has no multiply instruction! We implement it with addition:

```asm
; multiply.s - Multiply two 8-bit numbers

.segment "CODE"
.org $8000

reset:
    ; Multiply 7 * 13 = 91 ($5B)
    LDA #$07
    STA $10             ; Multiplicand
    LDA #$0D
    STA $11             ; Multiplier
    
    ; Result will be 16-bit in $12-$13
    LDA #$00
    STA $12             ; Clear result low
    STA $13             ; Clear result high
    
    LDX $11             ; X = multiplier (loop counter)
    BEQ done            ; If zero, done

mult_loop:
    ; Add multiplicand to result
    CLC
    LDA $12
    ADC $10
    STA $12
    
    LDA $13
    ADC #$00            ; Add carry
    STA $13
    
    DEX
    BNE mult_loop

done:
    ; Result in $12-$13 ($005B = 91)
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

**Algorithm:** Multiply by repeated addition
- 7 × 13 = 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7

This is slow but works! Better algorithms exist (shift-and-add).

## Practical Example: Division

Division is also not built-in! We implement with repeated subtraction:

```asm
; divide.s - Divide 8-bit number by 8-bit number

.segment "CODE"
.org $8000

reset:
    ; Divide 91 / 7 = 13 remainder 0
    LDA #$5B            ; Dividend (91)
    STA $10
    LDA #$07            ; Divisor (7)
    STA $11
    
    LDA #$00
    STA $12             ; Quotient = 0

div_loop:
    ; Subtract divisor from dividend
    SEC
    LDA $10
    SBC $11
    BCC done            ; If borrow, we're done
    
    STA $10             ; Update dividend
    INC $12             ; Increment quotient
    JMP div_loop

done:
    ; Quotient in $12 ($0D = 13)
    ; Remainder in $10 ($00 = 0)
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

**Algorithm:** Divide by repeated subtraction
- Count how many times we can subtract divisor from dividend

## Signed Arithmetic

The 6502 can work with signed numbers using two's complement:

**8-bit signed range:**
- $00-$7F = 0 to 127 (positive)
- $80-$FF = -128 to -1 (negative)

```asm
; Add -5 + 3 = -2
CLC
LDA #$FB            ; -5 in two's complement
ADC #$03            ; +3
; Result: $FE (-2 in two's complement)
```

**The V flag** (overflow) indicates signed overflow:

```asm
CLC
LDA #$7F            ; +127
ADC #$01            ; +1
; Result: $80 (-128), V flag SET (overflow!)
```

Use `BVS` (Branch if Overflow Set) and `BVC` (Branch if Overflow Clear) for signed comparisons.

## BCD Mode (Decimal Mode)

The 6502 can do arithmetic in BCD (Binary Coded Decimal):

```asm
SED                 ; Set Decimal mode
CLC
LDA #$09            ; 9 in BCD
ADC #$01            ; Add 1
; Result: $10 (10 in BCD, not $0A!)

CLD                 ; Clear Decimal mode (back to binary)
```

**BCD format:** Each nibble (4 bits) is 0-9
- $00-$99 represents 0-99
- Invalid: $0A-$0F, $A0-$FF

**Use:** Financial calculations, score displays

**Warning:** BCD affects ADC and SBC only! Not INC, DEC, etc.

## Experiments

### Experiment 1: Carry Flag Behavior

```asm
; What happens without CLC?
LDA #$05
ADC #$03            ; C might be set from before!
```

Try this after different operations. The carry persists!

### Experiment 2: Increment vs Add

```asm
; Which is faster?
INC $0200           ; 5 cycles
; vs
CLC
LDA $0200
ADC #$01
STA $0200           ; 3+2+4 = 9 cycles
```

INC is much faster!

### Experiment 3: Overflow Detection

```asm
CLC
LDA #$7F            ; 127
ADC #$01            ; +1
; A = $80 (-128 in signed!), V flag set

CLC  
LDA #$80            ; -128
ADC #$FF            ; -1
; A = $7F (127 in signed!), V flag set
```

The V flag detects when signed arithmetic goes wrong.

## Exercises

**Exercise 1:** Write a program that adds two 16-bit numbers stored in $10-$11 and $12-$13, storing result in $14-$15.

<details>
<summary>Solution to Exercise 1</summary>

```asm
.segment "CODE"
.org $8000

reset:
    ; First number: $1234
    LDA #$34
    STA $10
    LDA #$12
    STA $11
    
    ; Second number: $5678
    LDA #$78
    STA $12
    LDA #$56
    STA $13
    
    ; Add them
    CLC
    LDA $10             ; Low byte
    ADC $12
    STA $14
    
    LDA $11             ; High byte
    ADC $13
    STA $15
    
    ; Result: $68AC in $14-$15

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 2:** Implement a function that multiplies an 8-bit number by 10. Use the fact that 10 = 8 + 2 = 2³ + 2¹.

Hint: Use shifts (ASL) to multiply by powers of 2.

<details>
<summary>Solution to Exercise 2</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDA #$07            ; Multiply 7 * 10 = 70
    
    STA $10             ; Save original
    
    ; Multiply by 8 (shift left 3 times)
    ASL A               ; A * 2
    ASL A               ; A * 4
    ASL A               ; A * 8
    STA $11             ; Save A * 8
    
    ; Multiply by 2 (shift left 1 time)
    LDA $10             ; Reload original
    ASL A               ; A * 2
    
    ; Add them: (A * 8) + (A * 2) = A * 10
    CLC
    ADC $11
    STA $0200           ; Result: $46 (70)

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 3:** Write a program that computes the factorial of 5 (5! = 120). Store intermediate results as 16-bit values.

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

reset:
    ; Compute 5! = 5 * 4 * 3 * 2 * 1 = 120
    
    ; Result starts at 1
    LDA #$01
    STA $10             ; Low byte
    LDA #$00
    STA $11             ; High byte
    
    ; Counter starts at 5
    LDX #$05

fact_loop:
    ; Multiply result by X
    ; Save X
    STX $12
    
    ; Multiply 16-bit result by 8-bit X
    LDA #$00
    STA $14             ; Temp result low
    STA $15             ; Temp result high
    
mult_loop:
    ; Add $10-$11 to $14-$15
    CLC
    LDA $14
    ADC $10
    STA $14
    LDA $15
    ADC $11
    STA $15
    
    ; Decrement counter
    DEC $12
    BNE mult_loop
    
    ; Copy temp result back
    LDA $14
    STA $10
    LDA $15
    STA $11
    
    ; Next factorial term
    DEX
    CPX #$01
    BNE fact_loop

done:
    ; Result: $0078 (120) in $10-$11
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: Why ADC/SBC Include Carry?

Including carry in addition seems odd. Why?

**Multi-byte arithmetic!** The carry chains through bytes:

```asm
; Add $12345678 + $9ABCDEF0 (32-bit)
CLC
LDA #$78
ADC #$F0            ; Byte 0: carry out = 1
STA result

LDA #$56
ADC #$DE            ; Byte 1: adds carry from byte 0
STA result+1

LDA #$34
ADC #$BC            ; Byte 2: adds carry from byte 1
STA result+2

LDA #$12
ADC #$9A            ; Byte 3: adds carry from byte 2
STA result+3
```

The carry automatically propagates! Brilliant design.

## Deep Dive: Fast Multiplication

Our multiplication was slow (O(n)). Better algorithm using shifts:

```asm
; Multiply A * X (8x8 = 16-bit result)
; Result in $10-$11

multiply:
    STA $20             ; Multiplicand
    STX $21             ; Multiplier
    
    LDA #$00
    STA $10             ; Result low = 0
    STA $11             ; Result high = 0
    
    LDX #$08            ; 8 bits

mult_loop:
    LSR $21             ; Shift multiplier right
    BCC skip_add        ; If bit was 0, skip add
    
    ; Bit was 1, add multiplicand to result
    CLC
    LDA $10
    ADC $20
    STA $10
    LDA $11
    ADC #$00
    STA $11

skip_add:
    ; Shift multiplicand left (double it)
    ASL $20
    ROL $11             ; Carry into high byte
    
    DEX
    BNE mult_loop
    
    RTS
```

This is O(8) = constant time! Much faster for large numbers.

## Deep Dive: The V Flag

The V (overflow) flag is complex. It's set when:
- Two positive numbers add to negative
- Two negative numbers add to positive  
- Positive minus negative = negative
- Negative minus positive = positive

**Formula:** V = (M⁷ ⊕ R⁷) ∧ (N⁷ ⊕ R⁷)

Where M = operand bit 7, N = accumulator bit 7, R = result bit 7

**Use:** Signed arithmetic error detection

```asm
CLC
LDA #$7F            ; 127
ADC #$01            ; +1 = should be 128
; Result: $80 (interpreted as -128!), V=1

BVS overflow_error  ; Handle signed overflow
```

## Common Errors

### Error: Forgetting CLC/SEC

```asm
; WRONG:
LDA #$05
ADC #$03            ; Carry might be set!

; CORRECT:
CLC
LDA #$05
ADC #$03
```

### Error: Using INC when ADC is needed

```asm
; WRONG: Increment 16-bit value
INC $10
INC $11             ; Always increments high byte!

; CORRECT:
INC $10
BNE skip
INC $11
skip:
```

### Error: Confusing CMP results

```asm
LDA #$05
CMP #$10
BCS greater         ; WRONG! $05 < $10 but C=0

BCC less            ; CORRECT!
```

Remember: CMP sets C=1 if A >= operand!

## Key Takeaways

✅ **Always CLC before ADC, SEC before SBC**

✅ **ADC/SBC include carry** - essential for multi-byte math

✅ **INC/DEC are fast** - use instead of ADC/SBC when possible

✅ **No multiply/divide** - implement with loops or shifts

✅ **Multi-byte arithmetic** - process low to high, carry chains automatically

✅ **CMP for comparisons** - doesn't change A, only sets flags

✅ **V flag for signed** overflow detection

✅ **BCD mode** available with SED/CLD

## Next Lesson

Ready to control program flow?
**[Lesson 05: Control Flow →](../05-control-flow/)**

Or practice more arithmetic first!

---

## Quick Reference

**Arithmetic Instructions:**
```
ADC  - Add with carry (A = A + M + C)
SBC  - Subtract with carry (A = A - M - !C)
INC  - Increment memory
DEC  - Decrement memory
INX/INY/DEX/DEY - Increment/decrement registers
CMP  - Compare with A (A - M, set flags)
CPX  - Compare with X
CPY  - Compare with Y
```

**Before Arithmetic:**
```
CLC  - Clear carry (before ADC)
SEC  - Set carry (before SBC)
```

**Flags:**
```
C - Carry (addition overflow, subtraction borrow)
Z - Zero (result is zero)
N - Negative (bit 7 of result)
V - Overflow (signed arithmetic error)
```

**Comparisons:**
```
CMP #$10
BEQ equal       ; Z=1
BNE not_equal   ; Z=0
BCS >=          ; C=1
BCC <           ; C=0
```

**16-bit Addition:**
```asm
CLC
LDA low1
ADC low2
STA result_low
LDA high1
ADC high2
STA result_high
```

---

*You now know how to do math on the 6502!* 🧮
