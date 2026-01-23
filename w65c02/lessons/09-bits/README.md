# Lesson 09: Bit Manipulation - Working with Bits

Master the art of manipulating individual bits and bytes - essential for graphics, hardware control, and optimization!

## Learning Objectives

By the end of this lesson, you'll:
- Understand bitwise logic operations (AND, ORA, EOR)
- Master bit shifting (ASL, LSR, ROL, ROR)
- Know how to test and manipulate individual bits
- Use bit masking effectively
- Implement efficient bit-based algorithms

## Why Bit Manipulation?

**Bits are fundamental:**
- **Hardware control:** Setting pins, reading switches
- **Graphics:** Manipulating pixels, sprites
- **Compression:** Packing multiple values in one byte
- **Flags:** Storing multiple booleans efficiently
- **Math:** Fast multiplication/division by powers of 2

## Bitwise Logic Operations

### AND - Bitwise AND

```asm
AND operand        ; A = A & operand
```

**Truth table:**
```
A  operand  Result
0    0       0
0    1       0
1    0       0
1    1       1
```

**Example:**
```asm
    LDA #%11001100     ; A = 11001100
    AND #%11110000     ; A = 11000000
```

### ORA - Bitwise OR (Inclusive OR)

```asm
ORA operand        ; A = A | operand
```

**Truth table:**
```
A  operand  Result
0    0       0
0    1       1
1    0       1
1    1       1
```

**Example:**
```asm
    LDA #%11001100     ; A = 11001100
    ORA #%00110011     ; A = 11111111
```

### EOR - Bitwise Exclusive OR (XOR)

```asm
EOR operand        ; A = A ^ operand
```

**Truth table:**
```
A  operand  Result
0    0       0
0    1       1
1    0       1
1    1       0
```

**Example:**
```asm
    LDA #%11001100     ; A = 11001100
    EOR #%11110000     ; A = 00111100
```

## The Code

Create a file called `bit_ops.s`:

```asm
; bit_ops.s - Demonstrating bitwise operations

.segment "CODE"
.org $8000

reset:
    ; AND - Masking out bits
    LDA #%11111111     ; All bits on
    AND #%00001111     ; Keep only lower 4 bits
    ; A = 00001111
    STA $6000
    
    ; ORA - Setting bits
    LDA #%00000000     ; All bits off
    ORA #%10000001     ; Set bits 7 and 0
    ; A = 10000001
    STA $6001
    
    ; EOR - Toggling bits
    LDA #%11001100
    EOR #%11110000     ; Flip upper 4 bits
    ; A = 00111100
    STA $6002
    
    ; EOR again - toggles back!
    EOR #%11110000
    ; A = 11001100 (original value)
    STA $6003
    
done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### AND - Bit Masking

**Use case:** Extract specific bits

```asm
; Get lower 4 bits of A
    AND #%00001111     ; Mask keeps bits 0-3, clears 4-7
```

**Example:** Extract color value (4 bits) from sprite byte:
```asm
sprite_byte = $80      ; Format: CCCCSSSS (Color, Size)

    LDA sprite_byte
    AND #%00001111     ; Extract size (lower 4 bits)
    STA size
    
    LDA sprite_byte
    AND #%11110000     ; Extract color (upper 4 bits)
    LSR A              ; Shift to lower nibble
    LSR A
    LSR A
    LSR A
    STA color
```

### ORA - Setting Bits

**Use case:** Turn specific bits ON without affecting others

```asm
; Set bit 7 (sign bit)
    ORA #%10000000     ; Sets bit 7, keeps others unchanged
```

**Example:** Enable features in a status byte:
```asm
status = $20
PLAYER_ALIVE = %00000001
PLAYER_INVINCIBLE = %00000010
PLAYER_POWERED_UP = %00000100

    ; Enable invincibility
    LDA status
    ORA #PLAYER_INVINCIBLE
    STA status
```

### EOR - Toggling Bits

**Use case:** Flip specific bits

```asm
; Toggle bit 0 (invert it)
    EOR #%00000001     ; If was 0, becomes 1; if was 1, becomes 0
```

**Example:** Blink cursor by toggling visibility:
```asm
    LDA cursor_state
    EOR #%10000000     ; Toggle bit 7 (visible flag)
    STA cursor_state
```

**Cool property:** EOR with same value twice = original value!
```asm
    LDA value
    EOR #$42           ; Encrypt
    EOR #$42           ; Decrypt - back to original!
```

## BIT - Test Bits

Special instruction that tests bits without modifying A:

```asm
BIT operand        ; Test A & operand, set flags, don't change A
```

**Flags affected:**
- **N flag** = bit 7 of operand
- **V flag** = bit 6 of operand  
- **Z flag** = set if (A & operand) = 0

**Example:**
```asm
status = $20

    LDA #%00000001     ; Test bit 0
    BIT status         ; Z flag = 0 if status bit 0 is set
    BEQ bit_is_clear
    ; Bit is set
```

### BIT for Hardware

Common pattern for reading hardware status:

```asm
DEVICE_STATUS = $8000
READY_FLAG = %10000000     ; Bit 7

wait_ready:
    BIT DEVICE_STATUS      ; Test status
    BPL wait_ready         ; Branch if Plus (N=0, bit 7 clear)
    ; Device is ready!
```

This is faster than LDA + AND + CMP!

## Bit Shifting

### ASL - Arithmetic Shift Left

```asm
ASL                ; Shift A left (multiply by 2)
ASL address        ; Shift memory left
```

**What happens:**
```
Before: C ← [7 6 5 4 3 2 1 0] ← 0
After:      [6 5 4 3 2 1 0 0] → C
```

**Example:**
```asm
    LDA #%00001111     ; A = 15
    ASL A              ; A = 30 (15 × 2)
    ; Carry = 0
    
    LDA #%10000000     ; A = 128
    ASL A              ; A = 0
    ; Carry = 1 (bit 7 shifted into carry)
```

### LSR - Logical Shift Right

```asm
LSR                ; Shift A right (divide by 2)
LSR address        ; Shift memory right
```

**What happens:**
```
Before: 0 → [7 6 5 4 3 2 1 0] → C
After:  C ← [0 7 6 5 4 3 2 1]
```

**Example:**
```asm
    LDA #%00001111     ; A = 15
    LSR A              ; A = 7 (15 ÷ 2, rounded down)
    ; Carry = 1 (bit 0 shifted into carry)
```

### ROL - Rotate Left

```asm
ROL                ; Rotate A left through carry
ROL address        ; Rotate memory left through carry
```

**What happens:**
```
Before: [C] ← [7 6 5 4 3 2 1 0]
After:       [7 6 5 4 3 2 1 0] ← [C]
```

The carry bit rotates into bit 0!

**Example:**
```asm
    CLC                ; C = 0
    LDA #%10000001     ; A = 10000001
    ROL A              ; A = 00000010, C = 1
    ROL A              ; A = 00000101, C = 0
```

### ROR - Rotate Right

```asm
ROR                ; Rotate A right through carry
ROR address        ; Rotate memory right through carry
```

**What happens:**
```
Before: [7 6 5 4 3 2 1 0] → [C]
After:  [C] → [7 6 5 4 3 2 1 0]
```

**Example:**
```asm
    SEC                ; C = 1
    LDA #%10000001     ; A = 10000001
    ROR A              ; A = 11000000, C = 1
    ROR A              ; A = 11100000, C = 0
```

## Practical Example: Multiply by 10

```asm
; multiply_by_10.s - Fast multiplication using shifts

.segment "CODE"
.org $8000

reset:
    LDA #$05           ; Multiply 5 by 10
    JSR multiply_by_10
    ; A = 50
    
    CLC
    ADC #$30           ; Convert to ASCII
    STA $6000          ; Output '2'
    
done:
    JMP done

; Subroutine: multiply_by_10
; Input: A = number
; Output: A = number × 10
; Algorithm: n × 10 = n × 8 + n × 2 = (n << 3) + (n << 1)
multiply_by_10:
    STA temp           ; Save original
    
    ; Calculate n × 8
    ASL A              ; A × 2
    ASL A              ; A × 4
    ASL A              ; A × 8
    STA result
    
    ; Calculate n × 2
    LDA temp
    ASL A              ; A × 2
    
    ; Add them
    CLC
    ADC result
    RTS

temp:   .byte 0
result: .byte 0

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Practical Example: Bit Flags

```asm
; bit_flags.s - Using bits as boolean flags

.segment "CODE"
.org $8000

; Bit positions
FLAG_ALIVE      = %00000001    ; Bit 0
FLAG_INVINCIBLE = %00000010    ; Bit 1
FLAG_POWERED_UP = %00000100    ; Bit 2
FLAG_HAS_KEY    = %00001000    ; Bit 3

player_flags: .byte 0

reset:
    ; Start alive
    LDA #FLAG_ALIVE
    STA player_flags
    
    ; Pick up power-up
    JSR pickup_powerup
    
    ; Test if powered up
    LDA #FLAG_POWERED_UP
    BIT player_flags
    BNE is_powered_up
    
    ; Not powered up
    JMP done
    
is_powered_up:
    LDA #$59           ; 'Y'
    STA $6000
    JMP done

pickup_powerup:
    LDA player_flags
    ORA #FLAG_POWERED_UP
    STA player_flags
    RTS

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Practical Example: 16-bit Rotate

```asm
; Rotate 16-bit value left
; value_hi:value_lo

rotate_16bit_left:
    ASL value_lo       ; Shift low byte, bit 7 → carry
    ROL value_hi       ; Rotate high byte, carry → bit 0
    RTS

; Rotate 16-bit value right
rotate_16bit_right:
    LSR value_hi       ; Shift high byte, bit 0 → carry
    ROR value_lo       ; Rotate low byte, carry → bit 7
    RTS

value_lo: .byte 0
value_hi: .byte 0
```

## Bit Masking Patterns

### Extract Bit Field

```asm
; Extract bits 3-5 from A
    AND #%00111000     ; Mask bits 3-5
    LSR A              ; Shift to bits 0-2
    LSR A
    LSR A
```

### Set Specific Bit

```asm
; Set bit N in variable (N = 0-7)
bit_n = 3

    LDA variable
    ORA #(1 << bit_n)  ; Set bit 3
    STA variable
```

### Clear Specific Bit

```asm
; Clear bit N in variable
bit_n = 3

    LDA variable
    AND #(.NOT(1 << bit_n))  ; Clear bit 3
    STA variable
```

Or more simply:
```asm
    LDA variable
    AND #%11110111     ; Clear bit 3
    STA variable
```

### Toggle Specific Bit

```asm
; Toggle bit N in variable
bit_n = 3

    LDA variable
    EOR #(1 << bit_n)  ; Toggle bit 3
    STA variable
```

### Test Specific Bit

```asm
; Test bit N in variable
bit_n = 3

    LDA variable
    AND #(1 << bit_n)  ; Isolate bit 3
    BEQ bit_is_clear   ; Z=1 if bit was 0
```

## Advanced: Bit Counting

Count how many bits are set in a byte:

```asm
; popcount.s - Count set bits (population count)

.segment "CODE"
.org $8000

reset:
    LDA #%10110101     ; 5 bits set
    JSR count_bits
    ; A = 5
    
    CLC
    ADC #$30
    STA $6000          ; Output '5'
    
done:
    JMP done

; Subroutine: count_bits
; Input: A = byte to count
; Output: A = number of set bits (0-8)
count_bits:
    STA temp
    LDA #$00           ; Count = 0
    STA count
    LDX #$08           ; 8 bits to check
    
.loop:
    LSR temp           ; Shift bit into carry
    BCC .bit_clear     ; If carry clear, bit was 0
    
    INC count          ; Bit was 1, increment count
    
.bit_clear:
    DEX
    BNE .loop
    
    LDA count
    RTS

temp:  .byte 0
count: .byte 0

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Experiments

### Experiment 1: XOR Encryption

Encrypt and decrypt a message:

```asm
key = $42

encrypt:
    LDX #$00
.loop:
    LDA message,X
    BEQ .done
    EOR #key           ; Encrypt
    STA encrypted,X
    INX
    JMP .loop
.done:
    RTS

decrypt:
    LDX #$00
.loop:
    LDA encrypted,X
    BEQ .done
    EOR #key           ; Decrypt (same operation!)
    STA decrypted,X
    INX
    JMP .loop
.done:
    RTS
```

### Experiment 2: Fast Multiply/Divide

Use shifts for powers of 2:

```asm
; Multiply by 16 (2^4)
    ASL A              ; × 2
    ASL A              ; × 4
    ASL A              ; × 8
    ASL A              ; × 16

; Divide by 8 (2^3)
    LSR A              ; ÷ 2
    LSR A              ; ÷ 4
    LSR A              ; ÷ 8
```

### Experiment 3: Bit Reversal

Reverse the bits in a byte:

```asm
reverse_bits:
    STA source
    LDA #$00
    STA result
    LDX #$08
    
.loop:
    LSR source         ; Shift source right
    ROL result         ; Rotate into result left
    DEX
    BNE .loop
    
    LDA result
    RTS
```

## Exercises

**Exercise 1:** Write a routine to swap nibbles (4-bit halves) of a byte.
- Input: A = $F3
- Output: A = $3F

<details>
<summary>Solution to Exercise 1</summary>

```asm
; swap_nibbles
; Input: A = byte
; Output: A = byte with nibbles swapped
swap_nibbles:
    STA temp           ; Save original
    
    AND #%00001111     ; Get lower nibble
    ASL A              ; Shift to upper nibble
    ASL A
    ASL A
    ASL A
    STA result         ; Save it
    
    LDA temp
    AND #%11110000     ; Get upper nibble
    LSR A              ; Shift to lower nibble
    LSR A
    LSR A
    LSR A
    
    ORA result         ; Combine
    RTS

temp:   .byte 0
result: .byte 0
```

Shorter version:
```asm
swap_nibbles:
    STA temp
    ASL A
    ASL A
    ASL A
    ASL A
    STA result
    LDA temp
    LSR A
    LSR A
    LSR A
    LSR A
    ORA result
    RTS
```
</details>

**Exercise 2:** Write a routine to check if a number is a power of 2.
- Input: A = number
- Output: C=1 if power of 2, C=0 otherwise
- Hint: A power of 2 has exactly one bit set

<details>
<summary>Solution to Exercise 2</summary>

```asm
; is_power_of_2
; Input: A = number
; Output: C=1 if power of 2, C=0 otherwise
is_power_of_2:
    ; Special case: 0 is not a power of 2
    CMP #$00
    BEQ .not_power
    
    ; Count bits - should be exactly 1
    JSR count_bits     ; (From earlier example)
    CMP #$01
    BEQ .is_power
    
.not_power:
    CLC
    RTS
    
.is_power:
    SEC
    RTS
```

Clever trick (A & (A-1)) = 0 for powers of 2:
```asm
is_power_of_2:
    CMP #$00
    BEQ .not_power
    
    STA temp
    SEC
    SBC #$01           ; A = A - 1
    AND temp           ; A & (A-1)
    BEQ .is_power      ; If 0, is power of 2
    
.not_power:
    CLC
    RTS
    
.is_power:
    SEC
    RTS

temp: .byte 0
```
</details>

**Exercise 3:** Write a routine to extract RGB values from a 24-bit color.
- Input: $20-$22 contains RRGGBB (3 bytes)
- Output: red=$23, green=$24, blue=$25

<details>
<summary>Solution to Exercise 3</summary>

```asm
color_r = $20
color_g = $21
color_b = $22
red     = $23
green   = $24
blue    = $25

; extract_rgb
; Input: color_r:color_g:color_b = 24-bit color
; Output: red, green, blue (8-bit each)
extract_rgb:
    LDA color_r
    STA red
    
    LDA color_g
    STA green
    
    LDA color_b
    STA blue
    
    RTS
```

This is trivial since they're already separated! Here's a more realistic version where color is packed:

```asm
; Format: RRRGGGBB (8-bit, 3:3:2)
color = $20

extract_rgb_332:
    ; Extract red (bits 5-7)
    LDA color
    AND #%11100000
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    STA red            ; 0-7
    
    ; Extract green (bits 2-4)
    LDA color
    AND #%00011100
    LSR A
    LSR A
    STA green          ; 0-7
    
    ; Extract blue (bits 0-1)
    LDA color
    AND #%00000011
    STA blue           ; 0-3
    
    RTS
```
</details>

## Deep Dive: Carry Flag in Shifts

Understanding how carry interacts with shifts:

### ASL - Carry catches overflow

```asm
    LDA #$80           ; 10000000
    CLC                ; C = 0
    ASL A              ; A = 00000000, C = 1
    
    ; Carry tells you if bit 7 was set!
```

### Multi-byte Shifts

Shift a 16-bit value:

```asm
; Shift 16-bit value left (multiply by 2)
shift_left_16:
    ASL value_lo       ; Shift low byte
    ROL value_hi       ; Rotate high byte (gets carry from low)
    RTS

; Example:
; Before: value = $8234 (bits: 1000001000110100)
; After:  value = $0468 (bits: 0000010001101000)
;         Carry = 1 (bit 15 shifted out)
```

Shift a 32-bit value:

```asm
shift_left_32:
    ASL value_byte0    ; Lowest byte
    ROL value_byte1
    ROL value_byte2
    ROL value_byte3    ; Highest byte
    RTS
```

## Deep Dive: BIT vs AND

Why use BIT instead of AND?

```asm
; Using AND (modifies A)
    LDA value
    AND #$80           ; A is now destroyed
    BEQ bit_clear
    LDA value          ; Need to reload!

; Using BIT (doesn't modify A)
    LDA value
    BIT mask           ; A is preserved
    BEQ bit_clear
    ; Can use A immediately
```

BIT is faster when you need to preserve A!

## Common Errors

### Forgetting to Set/Clear Carry

```asm
; BAD: Carry might be set from previous operation
    ASL A              ; Includes previous carry!

; GOOD: Clear carry first
    CLC
    ASL A
```

### Confusing ASL and ROL

```asm
; ASL: 0 shifts into bit 0
    CLC
    ASL A              ; Bit 0 = 0, always

; ROL: Carry shifts into bit 0
    SEC
    ROL A              ; Bit 0 = 1 (from carry)
```

### Wrong Bit Mask

```asm
; Want to clear bit 3
    AND #%00001000     ; WRONG: Keeps ONLY bit 3

    AND #%11110111     ; CORRECT: Clears bit 3, keeps others
```

## Key Takeaways

✅ **AND** clears bits (masking), **ORA** sets bits, **EOR** toggles bits

✅ **BIT** tests bits without modifying A

✅ **ASL/LSR** shift bits left/right, multiplying/dividing by 2

✅ **ROL/ROR** rotate bits through carry flag

✅ Bit operations are **fast and powerful** for many tasks

✅ Use bit flags to store multiple booleans in one byte

✅ **Carry flag** is crucial in multi-byte operations

✅ Bit manipulation is essential for **graphics, hardware, and optimization**

## Next Lesson

Ready for more? Continue to:
**[Lesson 10: Tables and Lookup →](../10-tables/)**

Learn powerful table-based techniques and data structures!

---

## Quick Reference

**Logic operations:**
```asm
AND #%11110000     ; Clear lower 4 bits
ORA #%00001111     ; Set lower 4 bits
EOR #%11111111     ; Invert all bits
BIT operand        ; Test without modifying A
```

**Shifts:**
```asm
ASL A              ; Shift left (× 2)
LSR A              ; Shift right (÷ 2)
ROL A              ; Rotate left through carry
ROR A              ; Rotate right through carry
```

**Common masks:**
```asm
#%00001111         ; Lower nibble (bits 0-3)
#%11110000         ; Upper nibble (bits 4-7)
#%10000000         ; Bit 7 (sign bit)
#%00000001         ; Bit 0 (LSB)
```

---

*You're now a bit manipulation master!* 🔢
