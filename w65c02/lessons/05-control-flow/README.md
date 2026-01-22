# Lesson 05: Control Flow - Directing Program Execution

Now that you can do arithmetic and access memory, it's time to control where your program goes! Branches, jumps, and subroutines let you build complex logic.

## Learning Objectives

By the end of this lesson, you'll:
- Master all 6502 branch instructions
- Understand conditional vs unconditional jumps
- Know how to write loops and if-statements
- Use subroutines with JSR/RTS
- Understand the difference between JMP and JSR
- Build complex control structures

## Control Flow Instructions

The 6502 has three types of control flow:

**Branches (Conditional):**
- 8 flag-based branch instructions
- Short range (-128 to +127 bytes)
- 2-4 cycles

**Jumps (Unconditional):**
- `JMP` - Jump to address
- 3 cycles

**Subroutines:**
- `JSR` - Jump to Subroutine
- `RTS` - Return from Subroutine
- 6 cycles / 6 cycles

## The Branch Instructions

All branches test a flag and jump if true:

| Instruction | Meaning | Tests | Use Case |
|-------------|---------|-------|----------|
| `BEQ` | Branch if Equal | Z=1 | After CMP, if equal |
| `BNE` | Branch if Not Equal | Z=0 | After CMP, if not equal |
| `BCS` | Branch if Carry Set | C=1 | After CMP, if >= |
| `BCC` | Branch if Carry Clear | C=0 | After CMP, if < |
| `BMI` | Branch if Minus | N=1 | If negative |
| `BPL` | Branch if Plus | N=0 | If positive |
| `BVS` | Branch if Overflow Set | V=1 | Signed overflow |
| `BVC` | Branch if Overflow Clear | V=0 | No signed overflow |

## The Code

Create a file called `control.s`:

```asm
; control.s - Exploring control flow

.segment "CODE"
.org $8000

reset:
    ; === SIMPLE LOOP ===
    LDX #$00
simple_loop:
    TXA
    STA $0200,X         ; Store 0-9 to memory
    INX
    CPX #$0A            ; Compare X to 10
    BNE simple_loop     ; Branch if not equal
    
    ; === IF-THEN-ELSE ===
    LDA #$07
    CMP #$05
    BCC less_than       ; Branch if < 5
    
    ; Greater than or equal to 5
    LDA #$FF
    STA $0300
    JMP endif
    
less_than:
    LDA #$00
    STA $0300
    
endif:
    
    ; === NESTED LOOPS ===
    ; Fill 16x16 grid at $0400
    LDX #$00            ; Outer loop counter
outer_loop:
    LDY #$00            ; Inner loop counter
inner_loop:
    TXA
    STA $0400,Y         ; Store X value
    INY
    CPY #$10            ; 16 columns
    BNE inner_loop
    
    INX
    CPX #$10            ; 16 rows
    BNE outer_loop
    
    ; === SUBROUTINE CALL ===
    LDA #$42
    JSR double          ; Call subroutine
    STA $0500           ; Store result ($84)
    
    ; === WHILE LOOP ===
    LDA #$00
    STA $10             ; Counter
while_loop:
    LDA $10
    CMP #$0F            ; While counter < 15
    BCS end_while       ; Branch if >= 15
    
    ; Loop body
    INC $10
    JMP while_loop
    
end_while:
    
    ; === DO-WHILE LOOP ===
    LDA #$00
    STA $11
do_loop:
    ; Loop body executes at least once
    INC $11
    
    LDA $11
    CMP #$05            ; Until counter == 5
    BNE do_loop

done:
    JMP done

; === SUBROUTINE: Double a number ===
; Input: A = number to double
; Output: A = doubled number
; Modifies: A
double:
    ASL A               ; Shift left = multiply by 2
    RTS                 ; Return

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Simple Loop

```asm
LDX #$00
loop:
    ; ... body ...
    INX
    CPX #$0A            ; Compare with 10
    BNE loop            ; Continue if not equal
```

This is the most common pattern:
1. Initialize counter
2. Execute body
3. Increment counter
4. Compare with limit
5. Branch if not done

**C equivalent:**
```c
for (x = 0; x < 10; x++) {
    // body
}
```

### Counting Down

```asm
LDX #$0A
loop:
    ; ... body ...
    DEX
    BNE loop            ; Continue while not zero
```

Counting down is slightly more efficient - no CMP needed!

**Why?** DEX sets Z flag automatically when X reaches 0.

### IF-THEN-ELSE

```asm
LDA value
CMP #$05
BCC less_than       ; if (value < 5)

; Then clause
LDA #$FF
STA result
JMP endif

less_than:
; Else clause
LDA #$00
STA result

endif:
```

**Pattern:**
1. Compare
2. Branch to else clause
3. Then clause + JMP past else
4. Else clause
5. Label after both

**C equivalent:**
```c
if (value < 5) {
    result = 0x00;
} else {
    result = 0xFF;
}
```

### WHILE Loop

```asm
while_loop:
    LDA counter
    CMP #$0F
    BCS end_while       ; Exit if >= 15
    
    ; Loop body
    INC counter
    JMP while_loop
    
end_while:
```

**Pattern:**
1. Test condition at start
2. Branch out if false
3. Execute body
4. Jump back to test

**C equivalent:**
```c
while (counter < 15) {
    counter++;
}
```

### DO-WHILE Loop

```asm
do_loop:
    ; Loop body executes first
    INC counter
    
    LDA counter
    CMP #$05
    BNE do_loop         ; Continue if not 5
```

**Pattern:**
1. Execute body
2. Test condition
3. Branch back if true

**C equivalent:**
```c
do {
    counter++;
} while (counter != 5);
```

### Nested Loops

```asm
LDX #$00            ; Outer counter
outer:
    LDY #$00        ; Inner counter
inner:
    ; Body uses X and Y
    INY
    CPY #$10
    BNE inner
    
    INX
    CPX #$10
    BNE outer
```

**Use:** Processing 2D arrays, nested iterations

**C equivalent:**
```c
for (x = 0; x < 16; x++) {
    for (y = 0; y < 16; y++) {
        // body
    }
}
```

### Subroutines (JSR/RTS)

```asm
; Call subroutine
LDA #$42
JSR double          ; Jump to subroutine
STA result          ; A now contains result

; Subroutine definition
double:
    ASL A           ; Double the value in A
    RTS             ; Return
```

**JSR (Jump to Subroutine):**
1. Push return address (PC+2) onto stack
2. Jump to subroutine

**RTS (Return from Subroutine):**
1. Pop return address from stack
2. Jump there (actually PC+1, but JSR pushes PC+2)

**Stack layout after JSR:**
```
[PC high byte]  <- SP
[PC low byte]
```

### JMP vs JSR

```asm
; JMP - Unconditional jump (no return)
JMP somewhere       ; Just go there

; JSR - Call subroutine (expects RTS)
JSR subroutine      ; Go there and come back
```

**When to use:**
- `JMP` - Infinite loops, if-then-else, switch
- `JSR` - Functions, reusable code

## Branch Range Limitation

Branches use **relative addressing** - 8-bit signed offset:

**Range: -128 to +127 bytes from branch instruction**

```asm
    BEQ target      ; If target is too far, error!
```

**Solution:** Use JMP for long distances:

```asm
    BEQ near_label
    JMP far_label
near_label:
```

Or:
```asm
    BNE skip
    JMP far_label
skip:
```

## Practical Example: Find Maximum in Array

```asm
; max_array.s - Find maximum value in array

.segment "CODE"
.org $8000

reset:
    ; Find max in array
    LDX #$00
    LDA array,X         ; Start with first element as max
    STA max_value
    INX                 ; Move to second element

find_max_loop:
    LDA array,X         ; Load current element
    CMP max_value       ; Compare with current max
    BCC not_bigger      ; Branch if < max
    BCS is_bigger       ; Branch if >= max
    
is_bigger:
    STA max_value       ; Update max
    
not_bigger:
    INX
    CPX #array_size     ; Check if done
    BNE find_max_loop

done:
    ; max_value contains the maximum
    LDA max_value
    STA $0200
    JMP done

max_value:
    .byte $00

array:
    .byte $23, $15, $87, $42, $91, $33, $56, $12
array_size = * - array  ; Calculate array size

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Practical Example: Binary Search

```asm
; binary_search.s - Search sorted array

.segment "CODE"
.org $8000

; Search for value in A, return index in X or $FF if not found
search:
    STA search_value
    
    LDA #$00
    STA low             ; Low = 0
    LDA #array_size-1
    STA high            ; High = size - 1

search_loop:
    ; Check if low > high
    LDA low
    CMP high
    BEQ check_last      ; Equal, check this element
    BCS not_found       ; Greater, not found
    
    ; Calculate mid = (low + high) / 2
    CLC
    LDA low
    ADC high
    ROR A               ; Divide by 2
    STA mid
    
    ; Compare array[mid] with search value
    TAX
    LDA sorted_array,X
    CMP search_value
    BEQ found           ; Equal, found it!
    BCC search_right    ; Array[mid] < value, search right
    
search_left:
    ; mid - 1 -> high
    LDA mid
    SEC
    SBC #$01
    STA high
    JMP search_loop
    
search_right:
    ; mid + 1 -> low
    LDA mid
    CLC
    ADC #$01
    STA low
    JMP search_loop

check_last:
    ; Check the last remaining element
    LDX low
    LDA sorted_array,X
    CMP search_value
    BEQ found
    
not_found:
    LDX #$FF            ; Not found indicator
    RTS

found:
    LDX mid             ; Return index in X
    RTS

reset:
    LDA #$42            ; Search for $42
    JSR search
    STX $0200           ; Store result index

done:
    JMP done

; Variables
search_value: .byte $00
low:          .byte $00
high:         .byte $00
mid:          .byte $00

; Sorted array
sorted_array:
    .byte $10, $23, $35, $42, $56, $67, $78, $89
array_size = * - sorted_array

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Practical Example: Switch Statement

```asm
; switch.s - Implement switch/case

.segment "CODE"
.org $8000

reset:
    LDA #$02            ; Test value (case 2)
    JSR handle_case

done:
    JMP done

; Handle cases based on A
handle_case:
    ; Compare with case values
    CMP #$00
    BEQ case_0
    CMP #$01
    BEQ case_1
    CMP #$02
    BEQ case_2
    CMP #$03
    BEQ case_3
    JMP case_default

case_0:
    LDA #$A0
    STA $0200
    RTS

case_1:
    LDA #$A1
    STA $0200
    RTS

case_2:
    LDA #$A2
    STA $0200
    RTS

case_3:
    LDA #$A3
    STA $0200
    RTS

case_default:
    LDA #$FF
    STA $0200
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

**Better approach with jump table:**

```asm
; Switch using jump table
handle_case:
    ; Bounds check
    CMP #$04
    BCS case_default
    
    ; Multiply by 2 (addresses are 2 bytes)
    ASL A
    TAX
    
    ; Load address from jump table
    LDA jump_table+1,X  ; High byte
    PHA
    LDA jump_table,X    ; Low byte
    PHA
    RTS                 ; "Return" to address on stack!

jump_table:
    .word case_0-1      ; -1 because RTS adds 1
    .word case_1-1
    .word case_2-1
    .word case_3-1

case_0:
    LDA #$A0
    STA $0200
    RTS
; ... etc
```

## Experiments

### Experiment 1: Branch Timing

```asm
    LDA #$05
    CMP #$03
    BEQ target      ; Not taken: 2 cycles
                    ; Taken: 3 cycles (+1)
                    ; Cross page: 4 cycles (+2)
target:
```

Branches take different cycles depending on whether they're taken and if they cross pages!

### Experiment 2: Infinite Loop Variations

```asm
; Method 1: JMP to self
done:
    JMP done        ; 3 cycles per loop

; Method 2: BEQ to self (after setting Z)
    LDA #$00        ; Set Z flag
loop:
    BEQ loop        ; 3 cycles per loop (always taken)

; Method 3: BRA (W65C02 only)
loop:
    BRA loop        ; 2 cycles (unconditional branch)
```

### Experiment 3: Deep Nesting

How many levels can you nest? The stack limits this:

```asm
level1:
    JSR level2
    RTS

level2:
    JSR level3
    RTS

level3:
    JSR level4
    RTS
; ... etc
```

Each JSR uses 2 bytes of stack. Stack is 256 bytes. Max depth ≈ 128.

## Exercises

**Exercise 1:** Write a function that returns the absolute value of a signed 8-bit number in A.

Hint: Check if negative (BMI), if so negate it.

<details>
<summary>Solution to Exercise 1</summary>

```asm
; absolute_value.s
.segment "CODE"
.org $8000

reset:
    LDA #$FB            ; -5 in signed
    JSR absolute
    STA $0200           ; Result: $05

done:
    JMP done

; Absolute value of A
; Input: A (signed)
; Output: A (unsigned, absolute value)
absolute:
    BPL already_positive    ; Branch if positive (N=0)
    
    ; Negative, negate it (two's complement)
    EOR #$FF            ; Flip bits
    CLC
    ADC #$01            ; Add 1
    
already_positive:
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 2:** Implement a function that counts from A down to 0, storing each value to consecutive memory locations starting at $0300.

<details>
<summary>Solution to Exercise 2</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDA #$0F            ; Count from 15 down to 0
    JSR countdown

done:
    JMP done

; Countdown from A to 0
; Input: A (starting value)
; Output: Values stored at $0300+
countdown:
    LDX #$00            ; Index into memory

countdown_loop:
    STA $0300,X         ; Store current value
    TAY                 ; Save A in Y
    INX                 ; Next memory location
    TYA                 ; Restore A
    SEC
    SBC #$01            ; Decrement A
    BCS countdown_loop  ; Continue if didn't wrap (>= 0)
    
    ; Store final 0
    LDA #$00
    STA $0300,X
    
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

**Exercise 3:** Write a function that determines if a number is prime. Return 1 in A if prime, 0 if not.

Hint: Check if any number from 2 to N-1 divides N evenly.

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDA #$11            ; Check if 17 is prime
    JSR is_prime
    STA $0200           ; Result: 1 (yes, prime)

done:
    JMP done

; Check if A is prime
; Input: A (number to check)
; Output: A (1 if prime, 0 if not)
is_prime:
    ; Handle special cases
    CMP #$02
    BCC not_prime       ; 0 and 1 are not prime
    BEQ is_prime_yes    ; 2 is prime
    
    STA number
    LDA #$02
    STA divisor         ; Start with divisor = 2

check_divisor_loop:
    ; If divisor >= number, it's prime
    LDA divisor
    CMP number
    BCS is_prime_yes
    
    ; Check if number % divisor == 0
    LDA number
    STA dividend
    
divide_loop:
    ; Subtract divisor from dividend
    SEC
    LDA dividend
    SBC divisor
    BCC next_divisor    ; Borrow = dividend < divisor, no division
    STA dividend
    BEQ not_prime       ; Remainder = 0, divisible!
    JMP divide_loop

next_divisor:
    INC divisor
    JMP check_divisor_loop

is_prime_yes:
    LDA #$01
    RTS

not_prime:
    LDA #$00
    RTS

number:   .byte $00
divisor:  .byte $00
dividend: .byte $00

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: Branch vs JMP Performance

**Branch (when taken, same page):**
- 2 bytes
- 3 cycles

**JMP:**
- 3 bytes
- 3 cycles

For simple loops, branches are smaller! But limited range.

**Best practice:** Use branches for loops, JMP for long distances.

## Deep Dive: Structured Programming

You can implement any control structure:

**IF-THEN:**
```asm
    test
    BCC else
    ; then
    JMP endif
else:
    ; else clause
endif:
```

**WHILE:**
```asm
while:
    test
    BCC endwhile
    ; body
    JMP while
endwhile:
```

**FOR:**
```asm
    LDX #$00
for:
    CPX #limit
    BCS endfor
    ; body
    INX
    JMP for
endfor:
```

**BREAK:**
```asm
loop:
    ; ...
    test
    BCC break       ; Exit loop
    ; ...
    JMP loop
break:
```

## Deep Dive: Tail Call Optimization

Instead of:
```asm
func1:
    ; ... code ...
    JSR func2
    RTS
```

Do:
```asm
func1:
    ; ... code ...
    JMP func2       ; func2 will RTS for us!
```

Saves stack space and cycles!

## Common Errors

### Error: Branch out of range

```asm
    BEQ far_away    ; Error: far_away is > 127 bytes away
```

**Solution:**
```asm
    BNE skip
    JMP far_away
skip:
```

### Error: Forgetting to initialize loop counter

```asm
loop:
    STA $0200,X
    INX
    CPX #$10
    BNE loop        ; X might not start at 0!
```

**Solution:** Always initialize:
```asm
    LDX #$00
loop:
    ; ...
```

### Error: Wrong branch instruction

```asm
    LDA value
    CMP #$10
    BCC greater     ; WRONG! BCC branches if LESS
```

**Solution:** Remember:
- `BCC` = Branch if Carry Clear = Branch if LESS
- `BCS` = Branch if Carry Set = Branch if GREATER OR EQUAL

### Error: Not preserving registers in subroutines

```asm
subroutine:
    LDX #$00        ; Destroys caller's X!
    ; ... code ...
    RTS
```

**Solution:** Save/restore on stack:
```asm
subroutine:
    TXA
    PHA             ; Save X
    
    LDX #$00
    ; ... code ...
    
    PLA
    TAX             ; Restore X
    RTS
```

## Key Takeaways

✅ **8 branch instructions** test flags and jump conditionally

✅ **Branches are short-range** (-128 to +127 bytes)

✅ **JMP for long jumps**, branches for loops

✅ **JSR/RTS** for subroutines (functions)

✅ **Count down loops are faster** - no CMP needed

✅ **IF-THEN-ELSE**: Branch to else, execute then, JMP past else

✅ **While loop**: Test first, branch out if false

✅ **Do-while**: Execute first, test and branch back if true

✅ **Preserve registers** in subroutines with PHA/PLA

## Next Steps

**Congratulations!** You've completed the fundamental lessons of W65C02 assembly!

You now know:
- ✅ Basic program structure
- ✅ Registers and flags
- ✅ All addressing modes
- ✅ Arithmetic operations
- ✅ Control flow

**What's next?**
- Advanced topics: Interrupts, timers, I/O
- Build real projects: Games, utilities, demos
- Optimize code for size and speed
- Study existing 6502 codebases

**Keep practicing!** Assembly mastery comes from experience.

---

## Quick Reference

**Branch Instructions:**
```
BEQ/BNE - Branch if Equal/Not Equal (Z flag)
BCS/BCC - Branch if Carry Set/Clear (C flag)
BMI/BPL - Branch if Minus/Plus (N flag)
BVS/BVC - Branch if Overflow Set/Clear (V flag)
```

**Jumps:**
```
JMP addr   - Jump to address
JMP (addr) - Jump to address stored at addr
JSR addr   - Jump to subroutine
RTS        - Return from subroutine
```

**Common Patterns:**
```asm
; For loop (0 to N-1)
LDX #$00
loop:
    ; body
    INX
    CPX #N
    BNE loop

; While loop
while:
    ; test condition
    Bxx exit
    ; body
    JMP while
exit:

; If-then-else
    CMP value
    Bxx else
    ; then
    JMP endif
else:
    ; else
endif:

; Subroutine
func:
    ; body
    RTS
```

**Comparisons:**
```
After CMP:
  BEQ - Equal
  BNE - Not equal
  BCS - >= (unsigned)
  BCC - < (unsigned)
```

---

*You've mastered 6502 control flow!* 🎯
