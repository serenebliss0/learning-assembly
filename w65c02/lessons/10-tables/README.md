# Lesson 10: Tables and Lookup - Data-Driven Programming

Master table-based techniques - one of the most powerful programming patterns in 6502 assembly!

## Learning Objectives

By the end of this lesson, you'll:
- Understand how to use lookup tables effectively
- Master jump tables for computed branches
- Know how to work with multi-dimensional data
- Implement string handling routines
- Create efficient data structures

## Why Tables?

**Tables replace complex code with simple lookups:**

Instead of this:
```asm
; Multiply by 10 (slow)
    STA temp
    ASL A
    ASL A
    ASL A
    CLC
    ADC temp
    ADC temp
```

Use this:
```asm
; Multiply by 10 (fast)
    TAX
    LDA mul10_table,X  ; One lookup!
```

**Benefits:**
- **Speed:** Lookup is faster than calculation
- **Simplicity:** Less code, fewer bugs
- **Flexibility:** Easy to modify data
- **Predictability:** Constant time access

## Simple Lookup Tables

### Example: Hex to ASCII

Convert hex digit (0-15) to ASCII character:

```asm
; hex_to_ascii.s - Convert hex to ASCII using table

.segment "CODE"
.org $8000

reset:
    LDX #$00
    
print_hex:
    TXA
    TAY
    LDA hex_table,Y    ; Lookup ASCII character
    STA $6000          ; Output
    
    INX
    CPX #$10
    BNE print_hex
    
done:
    JMP done

; Lookup table: hex digit → ASCII
hex_table:
    .byte "0123456789ABCDEF"

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: "0123456789ABCDEF"

### Example: Sine Table

Precomputed sine values (scaled to 0-255):

```asm
; sine_table.s - Sine wave using lookup table

.segment "CODE"
.org $8000

reset:
    LDX #$00
    
wave_loop:
    LDA sine_table,X   ; Get sine value
    STA $6000          ; Output to display/DAC
    
    INX
    CPX #$40           ; 64 samples (0-63)
    BNE wave_loop
    
done:
    JMP done

; Sine table: 64 samples, 0-255 range
; sin(x) scaled and shifted to 0-255
sine_table:
    .byte 128, 140, 152, 164, 176, 187, 198, 208
    .byte 218, 226, 234, 241, 247, 252, 255, 258
    .byte 255, 252, 247, 241, 234, 226, 218, 208
    .byte 198, 187, 176, 164, 152, 140, 128, 115
    .byte 103,  91,  79,  68,  57,  47,  37,  29
    .byte  21,  14,   8,   3,   0,   0,   0,   3
    .byte   8,  14,  21,  29,  37,  47,  57,  68
    .byte  79,  91, 103, 115, 127, 140, 152, 164

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Two-Dimensional Tables

Access tables with rows and columns:

```asm
; multiplication_table.s - 10×10 multiplication table

.segment "CODE"
.org $8000

reset:
    ; Calculate 3 × 4
    LDA #$03           ; Row
    STA row
    LDA #$04           ; Column
    STA col
    
    JSR multiply
    ; A = 12
    
    CLC
    ADC #$30
    STA $6000          ; Output (would be '<', ASCII 60)
    
done:
    JMP done

; Subroutine: multiply
; Input: row, col (0-9)
; Output: A = row × col
; Uses: X
multiply:
    ; Calculate offset: row × 10 + col
    LDA row
    ASL A              ; × 2
    STA temp
    ASL A              ; × 4
    ASL A              ; × 8
    CLC
    ADC temp           ; × 8 + × 2 = × 10
    ADC col            ; Add column
    
    TAX
    LDA mul_table,X    ; Lookup result
    RTS

row:  .byte 0
col:  .byte 0
temp: .byte 0

; 10×10 multiplication table (100 bytes)
mul_table:
    ; Row 0
    .byte  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    ; Row 1
    .byte  0,  1,  2,  3,  4,  5,  6,  7,  8,  9
    ; Row 2
    .byte  0,  2,  4,  6,  8, 10, 12, 14, 16, 18
    ; Row 3
    .byte  0,  3,  6,  9, 12, 15, 18, 21, 24, 27
    ; Row 4
    .byte  0,  4,  8, 12, 16, 20, 24, 28, 32, 36
    ; Row 5
    .byte  0,  5, 10, 15, 20, 25, 30, 35, 40, 45
    ; Row 6
    .byte  0,  6, 12, 18, 24, 30, 36, 42, 48, 54
    ; Row 7
    .byte  0,  7, 14, 21, 28, 35, 42, 49, 56, 63
    ; Row 8
    .byte  0,  8, 16, 24, 32, 40, 48, 56, 64, 72
    ; Row 9
    .byte  0,  9, 18, 27, 36, 45, 54, 63, 72, 81

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Jump Tables - Computed GOTOs

**Jump tables** let you jump to different code based on a value:

```asm
; jump_table.s - Menu system using jump tables

.segment "CODE"
.org $8000

reset:
    ; Simulate user selecting menu option 2
    LDA #$02
    JSR execute_menu_option
    
done:
    JMP done

; Subroutine: execute_menu_option
; Input: A = menu option (0-3)
; Jumps to appropriate handler
execute_menu_option:
    ; Multiply by 2 (addresses are 16-bit)
    ASL A
    TAX
    
    ; Jump through table
    ; Low byte
    LDA jump_table,X
    STA jump_ptr
    ; High byte
    LDA jump_table+1,X
    STA jump_ptr+1
    
    JMP (jump_ptr)     ; Indirect jump!

jump_ptr: .word 0

; Jump table (array of addresses)
jump_table:
    .word option_0
    .word option_1
    .word option_2
    .word option_3

; Menu option handlers
option_0:
    LDA #$30           ; '0'
    STA $6000
    RTS

option_1:
    LDA #$31           ; '1'
    STA $6000
    RTS

option_2:
    LDA #$32           ; '2'
    STA $6000
    RTS

option_3:
    LDA #$33           ; '3'
    STA $6000
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: "2"

### Jump Table with RTS Trick

Clever technique using RTS:

```asm
; Instead of jumping, push address and RTS
execute_option:
    ASL A              ; × 2
    TAX
    
    LDA jump_table+1,X ; High byte
    PHA                ; Push high
    LDA jump_table,X   ; Low byte
    PHA                ; Push low
    
    RTS                ; "Returns" to option handler!

; Handler must RTS back to caller
option_0:
    ; Do work
    RTS                ; Returns to original caller
```

This is more compact but trickier!

## String Tables

Arrays of strings (pointer tables):

```asm
; string_table.s - Array of strings

.segment "CODE"
.org $8000

reset:
    ; Print all messages
    LDX #$00
    
print_loop:
    CPX #$04           ; 4 messages
    BEQ done
    
    JSR print_message  ; Print message X
    
    INX
    JMP print_loop

done:
    JMP done

; Subroutine: print_message
; Input: X = message number (0-3)
; Prints the message
print_message:
    ; Get pointer to string
    TXA
    ASL A              ; × 2 (16-bit pointers)
    TAX
    
    LDA string_table,X
    STA string_ptr
    LDA string_table+1,X
    STA string_ptr+1
    
    ; Print string
    LDY #$00
.loop:
    LDA (string_ptr),Y
    BEQ .done
    STA $6000
    INY
    JMP .loop
    
.done:
    RTS

string_ptr: .word 0

; Table of pointers to strings
string_table:
    .word msg_0
    .word msg_1
    .word msg_2
    .word msg_3

; String data
msg_0: .byte "Hello ", $00
msg_1: .byte "World ", $00
msg_2: .byte "From ", $00
msg_3: .byte "6502!", $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: "Hello World From 6502!"

## Practical Example: Character Map

Map keyboard scancodes to ASCII:

```asm
; keyboard_map.s - Scancode to ASCII translation

.segment "CODE"
.org $8000

; Keyboard scancodes (simplified)
KEY_A = $1C
KEY_B = $32
KEY_C = $21
KEY_ESC = $01
KEY_SPACE = $39

reset:
    ; Simulate key presses
    LDA #KEY_A
    JSR translate_key
    STA $6000          ; Output 'A'
    
    LDA #KEY_SPACE
    JSR translate_key
    STA $6000          ; Output ' '
    
done:
    JMP done

; Subroutine: translate_key
; Input: A = scancode
; Output: A = ASCII character (or $00 if invalid)
translate_key:
    CMP #$60           ; Check if in range
    BCS .invalid
    
    TAX
    LDA scancode_table,X
    RTS
    
.invalid:
    LDA #$00
    RTS

; Scancode to ASCII table (96 entries)
; Most entries are $00 (unmapped)
scancode_table:
    .byte $00           ; $00
    .byte $1B           ; $01 - ESC
    .byte "1234567890"  ; $02-$0B
    .byte "-=", $08     ; $0C-$0E (backspace)
    .byte $09           ; $0F - Tab
    .byte "QWERTYUIOP"  ; $10-$19
    .byte "[]", $0D     ; $1A-$1C (enter)
    .byte $00           ; $1D - Ctrl
    .byte "ASDFGHJKL"   ; $1E-$26
    .byte ";'`", $00    ; $27-$2A (left shift)
    .byte "\\ZXCVBNM"   ; $2B-$33
    .byte ",./", $00    ; $34-$37 (right shift)
    .byte "*", $00      ; $38-$39 (alt)
    .byte " "           ; $39 - Space
    ; ... rest filled with $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Practical Example: State Machine

Use tables to implement state machine:

```asm
; state_machine.s - Traffic light controller

.segment "CODE"
.org $8000

; States
STATE_GREEN  = 0
STATE_YELLOW = 1
STATE_RED    = 2

current_state: .byte STATE_GREEN

reset:
    ; Cycle through states
    LDX #$00
    
state_loop:
    CPX #$10           ; 16 iterations
    BEQ done
    
    JSR process_state
    JSR next_state
    
    INX
    JMP state_loop

done:
    JMP done

; Process current state
process_state:
    LDX current_state
    LDA state_output_table,X
    STA $6000          ; Output state character
    RTS

; Transition to next state
next_state:
    LDX current_state
    LDA state_next_table,X
    STA current_state
    RTS

; Output for each state
state_output_table:
    .byte "G"          ; Green
    .byte "Y"          ; Yellow
    .byte "R"          ; Red

; Next state transition table
state_next_table:
    .byte STATE_YELLOW ; Green → Yellow
    .byte STATE_RED    ; Yellow → Red
    .byte STATE_GREEN  ; Red → Green

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: "GYRGYRGYRGYRGYRG" (cycles through states)

## Advanced: Sparse Tables

For large key spaces, use sparse tables:

```asm
; Instead of 256-entry table, use key-value pairs
lookup_sparse:
    LDX #$00
    
.loop:
    ; Check if end of table
    LDA key_table,X
    CMP #$FF           ; $FF marks end
    BEQ .not_found
    
    ; Check if matches
    CMP search_key
    BEQ .found
    
    INX
    JMP .loop
    
.found:
    LDA value_table,X
    SEC                ; Signal found
    RTS
    
.not_found:
    CLC                ; Signal not found
    RTS

search_key: .byte 0

; Key-value pairs
key_table:
    .byte $05, $12, $27, $4A, $FF  ; Keys (FF = end)
value_table:
    .byte $41, $42, $43, $44       ; Values
```

## Data Structures: Arrays of Structs

Treat table as array of structures:

```asm
; Sprite data structure
; Each sprite: X pos (1 byte), Y pos (1 byte), Tile (1 byte)
; Total: 3 bytes per sprite

SPRITE_SIZE = 3
SPRITE_X_OFFSET = 0
SPRITE_Y_OFFSET = 1
SPRITE_TILE_OFFSET = 2

; Get sprite X position
; Input: A = sprite number
get_sprite_x:
    ; Calculate offset: sprite_num × 3 + 0
    STA temp
    ASL A              ; × 2
    CLC
    ADC temp           ; × 2 + × 1 = × 3
    TAX
    LDA sprite_data,X  ; Get X position
    RTS

; Set sprite Y position
; Input: A = sprite number, Y = new Y position
set_sprite_y:
    STA temp
    ASL A
    CLC
    ADC temp           ; × 3
    CLC
    ADC #SPRITE_Y_OFFSET  ; Add Y offset
    TAX
    TYA
    STA sprite_data,X  ; Set Y position
    RTS

temp: .byte 0

; Sprite data table
sprite_data:
    ; Sprite 0: X, Y, Tile
    .byte 10, 20, $41
    ; Sprite 1
    .byte 30, 40, $42
    ; Sprite 2
    .byte 50, 60, $43
    ; ... etc
```

## Experiments

### Experiment 1: Generate Table

Generate multiplication table at runtime:

```asm
generate_mul_table:
    LDX #$00           ; Multiplicand
    
.outer:
    LDY #$00           ; Multiplier
    
.inner:
    TXA
    JSR multiply_slow  ; Calculate X × Y
    STA mul_table,Y
    
    INY
    CPY #$10
    BNE .inner
    
    INX
    CPX #$10
    BNE .outer
    
    RTS
```

### Experiment 2: Compression

Use RLE (Run-Length Encoding) table:

```asm
; Format: count, value, count, value, ..., 0 (end)
compressed:
    .byte 5, $00       ; 5 zeros
    .byte 3, $FF       ; 3 FFs
    .byte 10, $42      ; 10 $42s
    .byte 0            ; End

decompress:
    LDX #$00           ; Source index
    LDY #$00           ; Dest index
    
.loop:
    LDA compressed,X   ; Get count
    BEQ .done          ; 0 = end
    STA count
    
    INX
    LDA compressed,X   ; Get value
    STA value
    
.inner:
    LDA value
    STA decompressed,Y
    INY
    DEC count
    BNE .inner
    
    INX
    JMP .loop
    
.done:
    RTS
```

### Experiment 3: Binary Search

Search sorted table efficiently:

```asm
binary_search:
    LDA #$00
    STA low
    LDA #table_size
    STA high
    
.loop:
    ; Check if low >= high
    LDA low
    CMP high
    BCS .not_found
    
    ; Calculate mid = (low + high) / 2
    LDA low
    CLC
    ADC high
    ROR A              ; Divide by 2
    STA mid
    
    ; Compare with search key
    TAX
    LDA table,X
    CMP search_key
    BEQ .found         ; Found it!
    BCC .search_high   ; table[mid] < key
    
    ; Search lower half
    LDA mid
    STA high
    JMP .loop
    
.search_high:
    LDA mid
    CLC
    ADC #$01
    STA low
    JMP .loop
    
.found:
    SEC                ; Signal found
    LDA mid            ; Return index
    RTS
    
.not_found:
    CLC
    RTS
```

## Exercises

**Exercise 1:** Create a days-in-month table and write a routine to get days for a given month.
- Input: A = month (1-12)
- Output: A = days in that month
- Assume non-leap year

<details>
<summary>Solution to Exercise 1</summary>

```asm
; days_in_month
; Input: A = month (1-12)
; Output: A = days in month
days_in_month:
    ; Validate month
    CMP #$01
    BCC .invalid
    CMP #$0D
    BCS .invalid
    
    ; Subtract 1 for 0-based index
    SEC
    SBC #$01
    TAX
    
    LDA month_days_table,X
    RTS
    
.invalid:
    LDA #$00           ; Return 0 for invalid
    RTS

; Days in each month (non-leap year)
month_days_table:
    .byte 31  ; January
    .byte 28  ; February
    .byte 31  ; March
    .byte 30  ; April
    .byte 31  ; May
    .byte 30  ; June
    .byte 31  ; July
    .byte 31  ; August
    .byte 30  ; September
    .byte 31  ; October
    .byte 30  ; November
    .byte 31  ; December
```
</details>

**Exercise 2:** Implement a simple hash table for string lookup.
- 16-entry hash table
- Hash function: sum of characters mod 16
- Handle collisions with linear probing

<details>
<summary>Solution to Exercise 2</summary>

```asm
HASH_SIZE = 16

; Hash function: sum all characters mod 16
hash_string:
    LDY #$00
    LDA #$00
    
.loop:
    CLC
    ADC (string_ptr),Y
    INY
    LDA (string_ptr),Y
    BNE .loop
    
    AND #$0F           ; Mod 16
    RTS

; Insert into hash table
; Input: string_ptr points to string
hash_insert:
    JSR hash_string    ; Get hash
    TAX                ; X = hash index
    
.find_slot:
    LDA hash_table_hi,X
    BNE .collision     ; Slot occupied
    
    ; Empty slot, insert here
    LDA string_ptr
    STA hash_table_lo,X
    LDA string_ptr+1
    STA hash_table_hi,X
    RTS
    
.collision:
    ; Linear probing
    INX
    TXA
    AND #$0F           ; Wrap around
    TAX
    JMP .find_slot

; Lookup in hash table
; Input: string_ptr points to search string
; Output: C=1 if found
hash_lookup:
    JSR hash_string
    TAX
    
.check_slot:
    LDA hash_table_hi,X
    BEQ .not_found     ; Empty slot
    
    ; Compare strings
    JSR compare_strings
    BEQ .found
    
    ; Try next slot
    INX
    TXA
    AND #$0F
    TAX
    JMP .check_slot
    
.found:
    SEC
    RTS
    
.not_found:
    CLC
    RTS

string_ptr: .word 0

; Hash table (16 entries, 16-bit pointers)
hash_table_lo: .res 16
hash_table_hi: .res 16
```
</details>

**Exercise 3:** Create a jump table for a calculator that supports +, -, *, /.
- Input: A = operand1, X = operand2, Y = operation (0=add, 1=sub, 2=mul, 3=div)
- Output: A = result

<details>
<summary>Solution to Exercise 3</summary>

```asm
; calculator
; Input: A = operand1, X = operand2, Y = operation
; Output: A = result
calculator:
    STA operand1
    STX operand2
    
    ; Jump through table
    TYA
    ASL A              ; × 2 (16-bit addresses)
    TAY
    
    LDA calc_table,Y
    STA jump_ptr
    LDA calc_table+1,Y
    STA jump_ptr+1
    
    LDA operand1
    LDX operand2
    JMP (jump_ptr)

operand1: .byte 0
operand2: .byte 0
jump_ptr: .word 0

calc_table:
    .word calc_add
    .word calc_sub
    .word calc_mul
    .word calc_div

calc_add:
    CLC
    ADC operand2
    RTS

calc_sub:
    SEC
    SBC operand2
    RTS

calc_mul:
    ; Simple repeated addition
    LDY operand2
    LDA #$00
.loop:
    CPY #$00
    BEQ .done
    CLC
    ADC operand1
    DEY
    JMP .loop
.done:
    RTS

calc_div:
    ; Simple repeated subtraction
    LDY #$00           ; Quotient
.loop:
    CMP operand2
    BCC .done          ; A < divisor
    SEC
    SBC operand2
    INY
    JMP .loop
.done:
    TYA                ; Return quotient
    RTS
```
</details>

## Deep Dive: Table Size vs Speed

**Trade-off:** Memory vs Computation

### Small Table, Compute Rest

```asm
; 16-entry square table, compute larger values
square_table:
    .byte 0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225

square:
    CMP #$10
    BCC .use_table
    
    ; Compute: X² = X × X
    JSR multiply
    RTS
    
.use_table:
    TAX
    LDA square_table,X
    RTS
```

### Large Table, Fast Lookup

```asm
; 256-entry table for all possible values
square_table_full: ; 256 bytes
    .byte 0, 1, 4, 9, 16, 25, ...  ; All 256 squares

square_fast:
    TAX
    LDA square_table_full,X
    RTS
```

**Decision factors:**
- Available ROM/RAM
- Speed requirements
- Frequency of use

## Deep Dive: Code Generation

Generate tables with scripts:

**Python script:**
```python
# Generate sine table
import math

print("sine_table:")
for i in range(64):
    angle = (i / 64.0) * 2 * math.pi
    value = int((math.sin(angle) + 1.0) * 127.5)
    if i % 8 == 0:
        print("    .byte ", end="")
    print(f"{value}", end="")
    if (i + 1) % 8 == 0:
        print()
    else:
        print(", ", end="")
```

**Output:**
```asm
sine_table:
    .byte 128, 140, 152, 164, 176, 187, 198, 208
    .byte 218, 226, 234, 241, 247, 252, 255, 258
    ; ... etc
```

## Common Errors

### Index Out of Bounds

```asm
; Table has 10 entries
    LDA #$15           ; Index 21
    TAX
    LDA table,X        ; Reads past end of table!
```

**Fix:** Always validate indices!

### Forgetting to Multiply by 2

```asm
; Jump table (16-bit addresses)
    LDA option
    TAX
    LDA jump_table,X   ; WRONG: Gets half of first address
```

**Fix:**
```asm
    ASL A              ; Multiply by 2
    TAX
```

### Uninitialized Table

```asm
result_table: .res 256  ; Reserves space but doesn't initialize

; Later...
    LDA result_table,X  ; Contains garbage!
```

**Fix:** Initialize tables or generate at runtime.

## Key Takeaways

✅ **Lookup tables** trade memory for speed

✅ **Jump tables** enable computed branches (switch statements)

✅ **2D tables** store grid/matrix data efficiently

✅ **String tables** are arrays of pointers

✅ **State machines** use tables for transitions

✅ Always **validate indices** to prevent buffer overruns

✅ **Generate complex tables** with scripts

✅ Tables are the foundation of **data-driven** programming

## Congratulations! 🎉

You've completed all 10 lessons of W65C02 assembly programming!

You now know:
- Basic program structure and registers
- Memory addressing and organization
- Arithmetic and control flow
- Subroutines and code organization
- Stack operations and state management
- Bit manipulation and optimization
- Table-based programming

### Where to Go Next

**Practice Projects:**
- Text adventure game
- Simple calculator
- Sprite animation system
- Music player
- File compression utility

**Advanced Topics:**
- Interrupt handling (NMI, IRQ)
- Hardware interfaces (VIA, UART)
- Optimization techniques
- Real hardware programming

**Resources:**
- [6502.org](http://6502.org) - Community and documentation
- W65C02S Datasheet - Official reference
- Vintage computer forums

---

## Quick Reference

**Table patterns:**
```asm
; Simple lookup
    TAX
    LDA table,X

; 2D table access
    ; offset = row × width + col
    LDA row
    ; multiply by width
    TAX
    LDA table,X

; Jump table
    ASL A              ; × 2 for 16-bit addresses
    TAX
    LDA table,X
    STA ptr_lo
    LDA table+1,X
    STA ptr_hi
    JMP (ptr_lo)
```

**Defining tables:**
```asm
byte_table:
    .byte 1, 2, 3, 4, 5

string_table:
    .word str1, str2, str3

mixed_table:
    .byte $00
    .word $1234
    .byte "text", $00
```

---

*You're now a 6502 assembly master! Happy coding!* 🚀
