# Lesson 07: Working with Memory - Efficient Memory Usage

Learn how to organize and efficiently use the 6502's memory, with special focus on the powerful zero page!

## Learning Objectives

By the end of this lesson, you'll:
- Understand 6502 memory layout and organization
- Master zero page addressing for faster, smaller code
- Know how to efficiently organize data in memory
- Use indirect addressing modes
- Implement simple data structures

## The 6502 Memory Map

The 6502 has a 16-bit address bus: **64KB of addressable memory** ($0000-$FFFF)

```
$FFFF  ┌─────────────────┐
       │  Vectors        │  $FFFA-$FFFF (6 bytes)
$FFF9  ├─────────────────┤
       │                 │
       │  ROM/Program    │  $8000-$FFF9 (typical)
       │                 │
$8000  ├─────────────────┤
       │                 │
       │  RAM            │  $0200-$7FFF
       │                 │
$0200  ├─────────────────┤
       │  Stack          │  $0100-$01FF (256 bytes)
$0100  ├─────────────────┤
       │  Zero Page      │  $0000-$00FF (256 bytes)
$0000  └─────────────────┘
```

### Key Regions

**Zero Page ($0000-$00FF):**
- First 256 bytes of memory
- **SPECIAL:** Faster access, smaller instructions
- Use for frequently accessed variables
- Perfect for pointers and temporary storage

**Stack ($0100-$01FF):**
- 256 bytes for the hardware stack
- Grows downward (high to low addresses)
- Used by JSR/RTS, PHA/PLA, interrupts

**General RAM ($0200-$7FFF):**
- Free for your use
- Store data, arrays, buffers
- Typical systems have 32K RAM ($0000-$7FFF)

**Program ROM ($8000-$FFFF):**
- Where your code lives
- Read-only (in actual hardware)
- Also store constant data here

## Zero Page - Your Best Friend

Zero page is **special** on the 6502:

### Speed Advantage

```asm
LDA $80           ; Zero page: 3 cycles, 2 bytes
LDA $1234         ; Absolute: 4 cycles, 3 bytes
```

**Zero page is faster and smaller!**

### More Addressing Modes

Zero page enables special addressing modes:

```asm
LDA ($80),Y       ; Indirect indexed - ONLY works with zero page!
LDA ($80,X)       ; Indexed indirect - ONLY works with zero page!
```

### The Code - Zero Page Demo

```asm
; zero_page_demo.s - Demonstrating zero page usage

.segment "CODE"
.org $8000

; Zero page variables
counter    = $10
temp       = $11
ptr_lo     = $12   ; Pointer low byte
ptr_hi     = $13   ; Pointer high byte
result     = $14

reset:
    ; Initialize counter
    LDA #$00
    STA counter
    
    ; Count from 0 to 9
count_loop:
    LDA counter
    CLC
    ADC #$30           ; Convert to ASCII
    STA $6000          ; Output
    
    INC counter
    LDA counter
    CMP #$0A           ; Compare with 10
    BNE count_loop
    
    ; Use pointer to access data
    LDA #<message      ; Low byte of message address
    STA ptr_lo
    LDA #>message      ; High byte of message address
    STA ptr_hi
    
    JSR print_string
    
done:
    JMP done

; Subroutine: print_string
; Input: ptr_lo:ptr_hi points to null-terminated string
; Modifies: A, Y
print_string:
    LDY #$00
    
.loop:
    LDA (ptr_lo),Y     ; Indirect indexed addressing!
    BEQ .done
    STA $6000
    INY
    JMP .loop
    
.done:
    RTS

message:
    .byte " Done!", $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Zero Page Variables

```asm
counter    = $10
temp       = $11
ptr_lo     = $12
ptr_hi     = $13
```

We assign zero page addresses to meaningful names:
- Makes code readable
- Easy to change locations
- No storage allocated - just aliases

### Accessing Zero Page

```asm
LDA counter        ; Load from zero page $10
STA temp           ; Store to zero page $11
INC counter        ; Increment zero page $10
```

**Syntax is the same as absolute addressing** - the assembler knows it's zero page because address < $100!

### Zero Page Indexed

```asm
LDX #$05
LDA $10,X          ; Loads from $15 (zero page $10 + X)
```

If result exceeds $FF, it wraps:
```asm
LDX #$F0
LDA $20,X          ; Loads from $10 (wraps: $20 + $F0 = $110 -> $10)
```

## Indirect Addressing - Pointers!

The 6502 supports pointers through indirect addressing:

### Indirect Indexed - (ptr),Y

```asm
LDA ($12),Y        ; Load from address stored at $12-$13, plus Y
```

**How it works:**
1. Read 16-bit address from $12 (low) and $13 (high)
2. Add Y to that address
3. Load from the resulting address

**Example:**
```asm
; Set pointer to $2000
LDA #$00
STA $12            ; Low byte
LDA #$20
STA $13            ; High byte

LDY #$05
LDA ($12),Y        ; Loads from $2005
```

This is perfect for arrays and strings!

### Indexed Indirect - (ptr,X)

```asm
LDA ($12,X)        ; Add X to $12, then use that as pointer
```

**How it works:**
1. Add X to $12 (wraps in zero page)
2. Read 16-bit address from result
3. Load from that address

**Example:**
```asm
; Array of pointers at $10, $12, $14
; Each pointer is 2 bytes
LDX #$02           ; Select pointer at $12
LDA ($10,X)        ; Load from address stored at $12-$13
```

This is perfect for pointer arrays!

## Practical Example: Array Sum

```asm
; array_sum.s - Sum elements of an array

.segment "CODE"
.org $8000

array_ptr_lo = $10
array_ptr_hi = $11
sum          = $12

reset:
    ; Point to array
    LDA #<array
    STA array_ptr_lo
    LDA #>array
    STA array_ptr_hi
    
    ; Clear sum
    LDA #$00
    STA sum
    
    ; Sum array elements
    LDY #$00
    
sum_loop:
    LDA (array_ptr_lo),Y   ; Load array[Y]
    BEQ done_sum           ; Zero marks end
    
    CLC
    ADC sum                ; Add to sum
    STA sum
    
    INY
    JMP sum_loop

done_sum:
    ; Display result
    LDA sum
    CLC
    ADC #$30               ; Convert to ASCII
    STA $6000
    
done:
    JMP done

; Array in ROM
array:
    .byte 1, 2, 3, 4, 5, 0 ; Sum = 15

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: '/' (ASCII 47 = 15 + 30)

## Memory Organization Strategies

### Strategy 1: Group Related Data

```asm
; Player data structure
player_x      = $20
player_y      = $21
player_health = $22
player_score  = $23

; Enemy data structure
enemy_x       = $30
enemy_y       = $31
enemy_health  = $32
enemy_type    = $33
```

### Strategy 2: Use Tables

```asm
; Instead of many variables:
sprite_x_0 = $40
sprite_x_1 = $41
sprite_x_2 = $42
; ... etc

; Use a table:
sprite_x = $40         ; Base address
; sprite_x[0] = $40
; sprite_x[1] = $41
; sprite_x[2] = $42

; Access with:
LDX sprite_num
LDA sprite_x,X         ; Load sprite_x[sprite_num]
```

### Strategy 3: Reserve Zero Page Carefully

```asm
; Memory map for your program
; Zero page: $00-$0F - System (reserved)
; Zero page: $10-$1F - Temporary variables
; Zero page: $20-$3F - Pointers (16 pointers)
; Zero page: $40-$7F - Game state
; Zero page: $80-$FF - Sprite data
```

Document your zero page usage!

## Advanced: 16-bit Operations

Working with 16-bit values in 8-bit registers:

### 16-bit Load

```asm
value_lo = $10
value_hi = $11

load_16bit:
    LDA #$34           ; Low byte
    STA value_lo
    LDA #$12           ; High byte
    STA value_hi
    ; value = $1234
```

### 16-bit Add

```asm
num1_lo = $10
num1_hi = $11
num2_lo = $12
num2_hi = $13
result_lo = $14
result_hi = $15

add_16bit:
    CLC                ; Clear carry
    LDA num1_lo
    ADC num2_lo        ; Add low bytes
    STA result_lo
    
    LDA num1_hi
    ADC num2_hi        ; Add high bytes (with carry!)
    STA result_hi
    RTS
```

### 16-bit Compare

```asm
; Compare value1 with value2 (both 16-bit)
; Returns: Z=1 if equal, C=1 if value1 >= value2
compare_16bit:
    LDA value1_hi
    CMP value2_hi
    BNE .done          ; If high bytes differ, we're done
    
    LDA value1_lo
    CMP value2_lo      ; Compare low bytes
    
.done:
    RTS
```

## Practical Example: Copy Memory Block

```asm
; memcopy.s - Copy a block of memory

.segment "CODE"
.org $8000

src_ptr_lo  = $10      ; Source pointer
src_ptr_hi  = $11
dst_ptr_lo  = $12      ; Destination pointer
dst_ptr_hi  = $13
count       = $14      ; Bytes to copy

reset:
    ; Set up source
    LDA #<source_data
    STA src_ptr_lo
    LDA #>source_data
    STA src_ptr_hi
    
    ; Set up destination
    LDA #$00
    STA dst_ptr_lo
    LDA #$20           ; Destination: $2000
    STA dst_ptr_hi
    
    ; Set count
    LDA #$10           ; Copy 16 bytes
    STA count
    
    JSR memcopy
    
done:
    JMP done

; Subroutine: memcopy
; Copies count bytes from src_ptr to dst_ptr
; Modifies: A, Y, count
memcopy:
    LDY #$00
    
.loop:
    LDA count
    BEQ .done          ; If count=0, done
    
    LDA (src_ptr_lo),Y ; Load from source
    STA (dst_ptr_lo),Y ; Store to destination
    
    ; Increment pointers
    INC src_ptr_lo
    BNE .no_carry1
    INC src_ptr_hi
    
.no_carry1:
    INC dst_ptr_lo
    BNE .no_carry2
    INC dst_ptr_hi
    
.no_carry2:
    DEC count
    JMP .loop
    
.done:
    RTS

source_data:
    .byte "Hello, Memory! ", $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Experiments

### Experiment 1: Zero Page Speed Test

Compare speeds:

```asm
; Zero page (faster)
    LDX #$00
loop1:
    LDA $10
    STA $11
    INX
    BNE loop1

; Absolute addressing (slower)
    LDX #$00
loop2:
    LDA $2010
    STA $2011
    INX
    BNE loop2
```

Count cycles for each loop.

### Experiment 2: Pointer Arithmetic

Increment a 16-bit pointer:

```asm
ptr_lo = $10
ptr_hi = $11

increment_ptr:
    INC ptr_lo
    BNE .done
    INC ptr_hi        ; Carry into high byte
.done:
```

### Experiment 3: Array Access Patterns

Compare different ways to access arrays:

```asm
; Method 1: Indexed
    LDX #$00
    LDA array,X

; Method 2: Indirect indexed
    LDA #<array
    STA ptr_lo
    LDA #>array
    STA ptr_hi
    LDY #$00
    LDA (ptr_lo),Y
```

## Exercises

**Exercise 1:** Write a routine to clear a block of memory.
- Input: ptr_lo:ptr_hi = start address, count = bytes to clear
- Set all bytes to $00

<details>
<summary>Solution to Exercise 1</summary>

```asm
ptr_lo = $10
ptr_hi = $11
count  = $12

; clear_memory
; Clears count bytes starting at ptr
clear_memory:
    LDA count
    BEQ .done          ; Nothing to clear
    
    LDA #$00           ; Value to store
    LDY #$00
    
.loop:
    STA (ptr_lo),Y     ; Store zero
    
    ; Increment pointer
    INC ptr_lo
    BNE .no_carry
    INC ptr_hi
    
.no_carry:
    DEC count
    BNE .loop
    
.done:
    RTS
```
</details>

**Exercise 2:** Write a routine to reverse a string in place.
- Input: ptr_lo:ptr_hi points to null-terminated string
- Reverse the order of characters

<details>
<summary>Solution to Exercise 2</summary>

```asm
ptr_lo = $10
ptr_hi = $11
length = $12
left   = $13
right  = $14
temp   = $15

reverse_string:
    ; First, find length
    LDY #$00
.find_length:
    LDA (ptr_lo),Y
    BEQ .found_length
    INY
    JMP .find_length
    
.found_length:
    TYA
    STA length
    BEQ .done          ; Empty string
    
    ; Set up indices
    LDA #$00
    STA left
    LDA length
    SEC
    SBC #$01
    STA right
    
.swap_loop:
    ; Check if left >= right
    LDA left
    CMP right
    BCS .done          ; Done swapping
    
    ; Swap characters
    LDY left
    LDA (ptr_lo),Y
    STA temp
    
    LDY right
    LDA (ptr_lo),Y
    LDY left
    STA (ptr_lo),Y
    
    LDA temp
    LDY right
    STA (ptr_lo),Y
    
    ; Move indices
    INC left
    DEC right
    JMP .swap_loop
    
.done:
    RTS
```
</details>

**Exercise 3:** Write a routine to find a byte in memory.
- Input: ptr_lo:ptr_hi = search start, count = bytes to search, value = byte to find
- Output: C=1 if found, Y = offset where found; C=0 if not found

<details>
<summary>Solution to Exercise 3</summary>

```asm
ptr_lo = $10
ptr_hi = $11
count  = $12
value  = $13

; find_byte
; Returns: C=1 if found (Y=offset), C=0 if not found
find_byte:
    LDY #$00
    
.loop:
    LDA count
    BEQ .not_found     ; Searched all bytes
    
    LDA (ptr_lo),Y     ; Load byte
    CMP value          ; Compare with search value
    BEQ .found
    
    ; Move to next byte
    INC ptr_lo
    BNE .no_carry
    INC ptr_hi
.no_carry:
    
    DEC count
    INY
    JMP .loop
    
.found:
    SEC                ; Signal found
    RTS
    
.not_found:
    CLC                ; Signal not found
    RTS
```
</details>

## Deep Dive: Why Zero Page is Fast

### Hardware Reason

Zero page addressing uses only **1 address byte** instead of 2:

```
LDA $80            ; Opcode: A5 80 (2 bytes)
LDA $1234          ; Opcode: AD 34 12 (3 bytes)
```

The CPU:
1. Fetches opcode (1 cycle)
2. Fetches address byte(s) (1-2 cycles)
3. Reads from that address (1 cycle)

Zero page saves 1 cycle by fetching fewer bytes!

### Practical Impact

In a tight loop:
```asm
; Zero page version: 7 cycles/iteration
loop1:
    LDA $80        ; 3 cycles
    STA $81        ; 3 cycles
    JMP loop1      ; 3 cycles (Total: 9, but JMP is shared)

; Absolute version: 8 cycles/iteration
loop2:
    LDA $1234      ; 4 cycles
    STA $1235      ; 4 cycles
    JMP loop2      ; 3 cycles
```

Over 10,000 iterations: **10,000 cycles saved** (~10ms at 1MHz)!

## Deep Dive: Pointer Best Practices

### 1. Always Initialize Pointers

```asm
; BAD: Uninitialized pointer
    LDA (ptr_lo),Y     ; Reads from random location!

; GOOD: Initialize first
    LDA #$00
    STA ptr_lo
    LDA #$20
    STA ptr_hi
    LDA (ptr_lo),Y     ; Reads from $2000
```

### 2. Check for Page Crossings

When incrementing:
```asm
; Simple increment (might overflow)
    INC ptr_lo

; Safe increment (handles carry)
    INC ptr_lo
    BNE .no_carry
    INC ptr_hi
.no_carry:
```

### 3. Use Macros for Common Operations

```asm
; Macro to set 16-bit pointer
.macro SET_PTR ptr_lo, ptr_hi, address
    LDA #<address
    STA ptr_lo
    LDA #>address
    STA ptr_hi
.endmacro

; Usage:
SET_PTR $10, $11, message
```

## Common Errors

### Using Absolute Instead of Zero Page

```asm
counter = $0010        ; BAD: Forces absolute addressing

counter = $10          ; GOOD: Uses zero page
```

**Why?** Leading zero makes it $0010 (absolute), not $10 (zero page)!

### Forgetting High Byte of Pointer

```asm
LDA #<message
STA ptr_lo
; Forgot to set ptr_hi!
LDA (ptr_lo),Y         ; Reads from wrong address
```

### Page Boundary Issues

```asm
; If ptr_lo = $FF
INC ptr_lo             ; Now $00, but ptr_hi unchanged!
LDA (ptr_lo),Y         ; Reading from wrong page!
```

**Fix:** Always handle carry to high byte.

## Key Takeaways

✅ **Zero page** ($00-$FF) is faster and enables special addressing modes

✅ Use zero page for **frequently accessed variables** and **pointers**

✅ **Indirect indexed** `(ptr),Y` is perfect for arrays and strings

✅ Always initialize **both bytes** of 16-bit pointers

✅ Handle **page boundary crossings** when incrementing pointers

✅ **Organize memory** logically - document your memory map

✅ Use **16-bit operations** carefully - handle carry between bytes

✅ Zero page is **limited** - only 256 bytes, use wisely!

## Next Lesson

Ready for more? Continue to:
**[Lesson 08: Stack Operations →](../08-stack/)**

Master the stack and learn advanced state management!

---

## Quick Reference

**Zero page addressing:**
```asm
LDA $10            ; Load from zero page $10
STA $20            ; Store to zero page $20
INC $30            ; Increment zero page $30
```

**Indirect indexed:**
```asm
LDA ($10),Y        ; Load from (address at $10-$11) + Y
```

**Indexed indirect:**
```asm
LDA ($10,X)        ; Load from address at ($10+X)
```

**Set 16-bit pointer:**
```asm
LDA #<address      ; Low byte
STA ptr_lo
LDA #>address      ; High byte
STA ptr_hi
```

**Increment 16-bit pointer:**
```asm
INC ptr_lo
BNE .done
INC ptr_hi
.done:
```

---

*You're now a memory management expert!* 🧠
