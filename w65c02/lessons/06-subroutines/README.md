# Lesson 06: Subroutines - Structuring Your Code

Learn how to break your programs into reusable pieces using subroutines - the foundation of structured programming!

## Learning Objectives

By the end of this lesson, you'll:
- Understand how JSR and RTS work with the stack
- Know how to pass parameters to subroutines
- Be able to return values from subroutines
- Master nested subroutine calls
- Write reusable, modular code

## What Are Subroutines?

A **subroutine** is a reusable block of code you can call from anywhere in your program. Think of them as functions in high-level languages.

**Benefits:**
- **Reusability** - Write once, use many times
- **Organization** - Break complex tasks into smaller pieces
- **Maintenance** - Fix bugs in one place
- **Readability** - Name meaningful operations

## The Instructions

### JSR - Jump to Subroutine

```asm
JSR address        ; Call subroutine at address
```

What happens:
1. Push return address onto stack (PC + 2)
2. Jump to subroutine address

### RTS - Return from Subroutine

```asm
RTS                ; Return from subroutine
```

What happens:
1. Pull return address from stack
2. Jump to that address + 1

## The Code

Create a file called `subroutines.s`:

```asm
; subroutines.s - Demonstrating subroutines
; This program uses subroutines to print a message multiple times

.segment "CODE"
.org $8000

reset:
    LDX #$03           ; Print message 3 times

main_loop:
    JSR print_hello    ; Call subroutine
    DEX                ; Decrement counter
    BNE main_loop      ; Continue if not zero
    
    ; Now print a different message
    JSR print_done
    
done:
    JMP done

; Subroutine: print_hello
; Prints "Hello!" to output
; Modifies: A, X
print_hello:
    LDX #$00           ; Initialize index

.loop:
    LDA hello_msg,X    ; Load character
    BEQ .exit          ; Exit if null
    STA $6000          ; Output character
    INX                ; Next character
    JMP .loop

.exit:
    RTS                ; Return to caller

; Subroutine: print_done
; Prints "Done!" to output
; Modifies: A, X
print_done:
    LDX #$00

.loop:
    LDA done_msg,X
    BEQ .exit
    STA $6000
    INX
    JMP .loop

.exit:
    RTS

; Data
hello_msg:
    .byte "Hello! ", $00

done_msg:
    .byte "Done!", $00

; Reset vector
.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Calling a Subroutine

```asm
JSR print_hello    ; Call subroutine
```

**What happens internally:**
1. Current PC is $8006 (address of JSR instruction + 3)
2. Push $8006 to stack (high byte first, then low byte)
3. Set PC to address of print_hello
4. Continue execution at print_hello

### Inside the Subroutine

```asm
print_hello:
    LDX #$00
    ; ... do work ...
    RTS
```

The subroutine:
- Has a label for calling
- Does its work
- Uses RTS to return

**Important:** When RTS executes, it pulls the return address from stack and jumps back!

### Local Labels

```asm
print_hello:
.loop:
    ; ...
    JMP .loop
.exit:
    RTS
```

Labels starting with `.` are **local** to the previous global label. This prevents name conflicts:
- `print_hello.loop` is different from `print_done.loop`
- You can reuse `.loop` in each subroutine!

## Parameter Passing

Subroutines often need input. Here are common techniques:

### Method 1: Through Registers

```asm
; Subroutine: multiply_by_10
; Input: A = number
; Output: A = number * 10
; Preserves: X, Y
multiply_by_10:
    STA temp           ; Save original
    ASL A              ; A = A * 2
    ASL A              ; A = A * 4
    ASL A              ; A = A * 8
    CLC
    ADC temp           ; A = A * 8 + original
    ADC temp           ; A = A * 8 + 2 * original = 10 * original
    RTS

temp: .byte 0
```

Usage:
```asm
    LDA #$05           ; Input: 5
    JSR multiply_by_10
    ; A now contains 50
```

### Method 2: Through Zero Page

```asm
; Parameters in zero page
param1 = $10
param2 = $11
result = $12

; Subroutine: add_numbers
; Input: param1, param2 (zero page $10, $11)
; Output: result (zero page $12)
add_numbers:
    CLC
    LDA param1
    ADC param2
    STA result
    RTS
```

Usage:
```asm
    LDA #$20
    STA param1
    LDA #$15
    STA param2
    JSR add_numbers
    LDA result         ; Contains $35
```

### Method 3: Through Stack (Advanced)

```asm
; Subroutine: add_from_stack
; Stack layout (after JSR):
;   S+3: param1
;   S+2: param2
;   S+1: return address high
;   S+0: return address low
add_from_stack:
    TSX                ; X = stack pointer
    LDA $0103,X        ; Get param1 (S+3)
    CLC
    ADC $0102,X        ; Add param2 (S+2)
    RTS
```

**Note:** This is complex! Usually use registers or zero page.

## Return Values

### Method 1: Through Accumulator

```asm
; Subroutine: is_even
; Input: A = number
; Output: A = 1 if even, 0 if odd
is_even:
    AND #$01           ; Check bit 0
    EOR #$01           ; Flip it (0->1, 1->0)
    RTS
```

### Method 2: Through Flags

```asm
; Subroutine: is_zero
; Input: A = number
; Output: Z flag set if zero
is_zero:
    CMP #$00           ; Sets Z flag if A=0
    RTS

; Usage:
    LDA value
    JSR is_zero
    BEQ handle_zero    ; Branch if it was zero
```

### Method 3: Through Memory

```asm
result_hi = $20
result_lo = $21

; Subroutine: get_16bit_value
; Output: result_hi:result_lo = 16-bit value
get_16bit_value:
    LDA #$12
    STA result_hi
    LDA #$34
    STA result_lo
    RTS
```

## Nested Subroutines

Subroutines can call other subroutines!

```asm
; subroutine_nesting.s

.segment "CODE"
.org $8000

reset:
    JSR level1         ; Call first level
    JMP done

level1:
    LDA #$01
    STA $6000          ; Output '1'
    JSR level2         ; Call second level
    RTS

level2:
    LDA #$02
    STA $6000          ; Output '2'
    JSR level3         ; Call third level
    RTS

level3:
    LDA #$03
    STA $6000          ; Output '3'
    RTS

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

**Stack grows like this:**
1. Call level1: Stack has [level1 return address]
2. Call level2: Stack has [level1 return, level2 return]
3. Call level3: Stack has [level1 return, level2 return, level3 return]
4. RTS from level3: Stack has [level1 return, level2 return]
5. RTS from level2: Stack has [level1 return]
6. RTS from level1: Stack is empty (back to main)

## Practical Example: String Length

```asm
; string_length.s - Calculate length of a string

.segment "CODE"
.org $8000

string_ptr = $10       ; Pointer to string (low byte)
string_ptr_hi = $11    ; Pointer to string (high byte)

reset:
    ; Set up pointer to our string
    LDA #<message      ; Low byte of address
    STA string_ptr
    LDA #>message      ; High byte of address
    STA string_ptr_hi
    
    ; Call string length
    JSR strlen
    ; A now contains length
    
    CLC
    ADC #$30           ; Convert to ASCII
    STA $6000          ; Display it
    
done:
    JMP done

; Subroutine: strlen
; Input: string_ptr points to null-terminated string
; Output: A = length of string
; Modifies: A, Y
strlen:
    LDY #$00           ; Counter
    
.loop:
    LDA (string_ptr),Y ; Load character using indirect indexed
    BEQ .done          ; If null, we're done
    INY                ; Count this character
    BNE .loop          ; Continue (max 255 chars)
    
.done:
    TYA                ; Transfer count to A
    RTS

message:
    .byte "Hello", $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: '5' (the length of "Hello")

## Preserving Registers

Sometimes you need to preserve register values:

```asm
; Subroutine that preserves X and Y
safe_subroutine:
    ; Save registers
    TXA                ; Transfer X to A
    PHA                ; Push A (saving X)
    TYA                ; Transfer Y to A
    PHA                ; Push A (saving Y)
    
    ; Do work that modifies X and Y
    LDX #$00
    LDY #$FF
    ; ...
    
    ; Restore registers
    PLA                ; Pull A (Y value)
    TAY                ; Transfer A to Y
    PLA                ; Pull A (X value)
    TAX                ; Transfer A to X
    
    RTS
```

We'll learn more about stack operations in Lesson 8!

## Experiments

### Experiment 1: Count Calls

Add a counter to track how many times a subroutine is called:

```asm
call_count: .byte 0

my_subroutine:
    INC call_count     ; Increment counter
    ; ... rest of subroutine
    RTS
```

### Experiment 2: Recursive Calls

Try calling a subroutine from itself (recursion):

```asm
; WARNING: This will overflow the stack!
recursive:
    JSR recursive      ; Calls itself forever
    RTS
```

**Why dangerous?** Each call pushes return address to stack. Stack is only 256 bytes!

### Experiment 3: Subroutine Chain

Create a chain where A calls B, B calls C, C calls D:

```asm
sub_a:
    LDA #$41           ; 'A'
    STA $6000
    JSR sub_b
    RTS

sub_b:
    LDA #$42           ; 'B'
    STA $6000
    JSR sub_c
    RTS

sub_c:
    LDA #$43           ; 'C'
    STA $6000
    JSR sub_d
    RTS

sub_d:
    LDA #$44           ; 'D'
    STA $6000
    RTS
```

What gets printed? "ABCD"

## Exercises

**Exercise 1:** Write a subroutine that converts lowercase to uppercase.
- Input: A = ASCII character
- Output: A = uppercase version (if it was lowercase)
- Hint: Check if A >= 'a' and A <= 'z', then subtract 32

<details>
<summary>Solution to Exercise 1</summary>

```asm
; to_uppercase
; Input: A = character
; Output: A = uppercase version
to_uppercase:
    CMP #$61           ; 'a'
    BCC .not_lower     ; If less than 'a', not lowercase
    CMP #$7B           ; 'z' + 1
    BCS .not_lower     ; If greater than 'z', not lowercase
    
    SEC
    SBC #$20           ; Subtract 32 to convert to uppercase
    
.not_lower:
    RTS
```
</details>

**Exercise 2:** Write a subroutine that adds two 16-bit numbers.
- Input: $10-$11 (num1), $12-$13 (num2)
- Output: $14-$15 (result)
- Remember: Add low bytes first, then high bytes with carry!

<details>
<summary>Solution to Exercise 2</summary>

```asm
num1_lo = $10
num1_hi = $11
num2_lo = $12
num2_hi = $13
result_lo = $14
result_hi = $15

; add_16bit
; Adds num1 + num2, stores in result
add_16bit:
    CLC                ; Clear carry
    LDA num1_lo        ; Load low byte of num1
    ADC num2_lo        ; Add low byte of num2
    STA result_lo      ; Store result low byte
    
    LDA num1_hi        ; Load high byte of num1
    ADC num2_hi        ; Add high byte of num2 (with carry)
    STA result_hi      ; Store result high byte
    
    RTS
```
</details>

**Exercise 3:** Write a subroutine that finds the maximum of two numbers.
- Input: A and X contain two numbers
- Output: A contains the larger number

<details>
<summary>Solution to Exercise 3</summary>

```asm
; max
; Input: A and X = two numbers
; Output: A = maximum
; Preserves: X
max:
    CMP temp           ; Compare A with X
    BCS .a_is_larger   ; If A >= X, A is max
    
    TXA                ; X is larger, transfer X to A
    
.a_is_larger:
    RTS
```

Better version that preserves X:
```asm
max:
    STX temp           ; Save X
    CMP temp           ; Compare A with X
    BCS .done          ; If A >= X, keep A
    
    LDX temp           ; Otherwise, load X
    TXA                ; Transfer to A
    LDX temp           ; Restore X
    
.done:
    RTS

temp: .byte 0
```
</details>

## Deep Dive: The Stack and JSR

Understanding what JSR does internally helps debug problems.

### JSR Detailed Operation

```asm
    JSR $8100          ; At address $8000
```

Before JSR:
- PC = $8000 (address of JSR)
- S = $FF (stack pointer)

After JSR executes:
1. Calculate return address: $8000 + 3 = $8003 (but actually stores $8002!)
2. Push high byte: Stack[$01FF] = $80, S = $FE
3. Push low byte: Stack[$01FE] = $02, S = $FD
4. Set PC = $8100

**Why $8002 not $8003?** RTS adds 1 automatically!

### RTS Detailed Operation

```asm
    RTS                ; In subroutine
```

Before RTS:
- S = $FD (two bytes pushed)

After RTS executes:
1. Pull low byte: temp_lo = Stack[$01FE], S = $FE
2. Pull high byte: temp_hi = Stack[$01FF], S = $FF
3. Set PC = (temp_hi << 8 | temp_lo) + 1 = $8003

### Stack Overflow

The stack lives at $0100-$01FF (256 bytes). Each JSR uses 2 bytes.

**Maximum nesting depth:** ~100-120 levels (accounting for other stack use)

If you overflow:
- Stack wraps around (S goes $00 -> $FF)
- Corrupts stack data
- RTS returns to wrong address
- Crash!

## Deep Dive: Subroutine Conventions

Professional 6502 code follows conventions:

### 1. Document What You Modify

```asm
; subroutine_name
; Purpose: Brief description
; Input: A = input value, X = something else
; Output: A = result
; Modifies: A, X, flags
; Preserves: Y
subroutine_name:
    ; ...
    RTS
```

### 2. Use Standard Names

- `init_*` - Initialization routines
- `get_*` - Getter functions
- `set_*` - Setter functions  
- `print_*` - Output routines
- `read_*` - Input routines

### 3. Error Handling

Use carry flag for success/failure:

```asm
; Returns: C=0 if success, C=1 if error
read_file:
    ; Try to read
    ; If error:
    SEC                ; Signal error
    RTS
    
    ; If success:
    CLC                ; Signal success
    RTS
```

Usage:
```asm
    JSR read_file
    BCS handle_error   ; Branch if carry set (error)
    ; Success path
```

## Common Errors

### Forgot RTS

```asm
my_subroutine:
    LDA #$42
    STA $6000
    ; Forgot RTS!
```

**Result:** Execution continues into whatever comes next (crash or wrong behavior)

**Fix:** Always end subroutines with RTS!

### Stack Imbalance

```asm
bad_subroutine:
    PHA                ; Push A
    LDA #$00
    ; Forgot to PLA!
    RTS                ; Returns to wrong address!
```

**Result:** RTS pulls the pushed A value thinking it's the return address!

**Fix:** Make sure pushes and pulls are balanced.

### Recursion Without Base Case

```asm
factorial:
    JSR factorial      ; No stopping condition!
    RTS
```

**Result:** Stack overflow after ~120 calls.

**Fix:** Always have a base case that stops recursion.

## Key Takeaways

✅ **JSR** pushes return address and jumps to subroutine

✅ **RTS** pulls return address and returns to caller

✅ Subroutines enable **code reuse** and **organization**

✅ Pass parameters through **registers**, **zero page**, or **stack**

✅ Return values through **A register**, **flags**, or **memory**

✅ Subroutines can **nest** - calling other subroutines

✅ Always **document** inputs, outputs, and what registers are modified

✅ Be careful of **stack overflow** with deep nesting or recursion

## Next Lesson

Ready for more? Continue to:
**[Lesson 07: Working with Memory →](../07-memory/)**

Learn how to efficiently use memory and the powerful zero page!

---

## Quick Reference

**Call subroutine:**
```asm
JSR subroutine_name
```

**Return from subroutine:**
```asm
RTS
```

**Local labels:**
```asm
global_label:
.local_label:          ; Belongs to global_label
```

**Subroutine template:**
```asm
; subroutine_name
; Input: [describe inputs]
; Output: [describe outputs]
; Modifies: [list registers/memory]
subroutine_name:
    ; Do work
    RTS
```

---

*You've mastered subroutines! Your code is now modular and reusable!* 🎯
