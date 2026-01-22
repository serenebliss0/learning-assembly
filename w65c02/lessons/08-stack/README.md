# Lesson 08: Stack Operations - Managing State

Master the hardware stack - one of the most powerful features of the 6502 for saving and restoring state!

## Learning Objectives

By the end of this lesson, you'll:
- Understand how the 6502 hardware stack works
- Master PHA, PLA, PHP, and PLP instructions
- Know how to save and restore registers
- Be able to manipulate the stack pointer
- Implement complex state management

## The Hardware Stack

The 6502 has a **256-byte hardware stack** at memory addresses $0100-$01FF.

### Stack Pointer (S Register)

The **S register** (stack pointer) points to the next free location:

```
$01FF  ┌─────┐
       │     │  Empty
       ├─────┤
       │ $42 │  <- S points here ($FE)
$0100  └─────┘
```

**Key facts:**
- Stack is in page 1 ($0100-$01FF)
- Stack pointer is 8-bit (only stores low byte)
- Stack grows **downward** (high addresses to low)
- Initially S = $FF (pointing to $01FF)

### Push and Pull

**Push (store to stack):**
1. Write byte to $0100 + S
2. Decrement S

**Pull (read from stack):**
1. Increment S
2. Read byte from $0100 + S

## The Instructions

### PHA - Push Accumulator

```asm
PHA                ; Push A onto stack, S = S - 1
```

### PLA - Pull Accumulator

```asm
PLA                ; S = S + 1, Pull stack into A
```

### PHP - Push Processor Status

```asm
PHP                ; Push P (flags) onto stack
```

### PLP - Pull Processor Status

```asm
PLP                ; Pull stack into P (flags)
```

### Stack Operations in Action

```asm
; Stack operations demo
    LDA #$42
    PHA            ; Stack: [$42], S = $FE
    
    LDA #$43
    PHA            ; Stack: [$43, $42], S = $FD
    
    PLA            ; A = $43, Stack: [$42], S = $FE
    PLA            ; A = $42, Stack: [], S = $FF
```

**Important:** Stack is Last-In-First-Out (LIFO)!

## The Code

Create a file called `stack_demo.s`:

```asm
; stack_demo.s - Demonstrating stack operations

.segment "CODE"
.org $8000

reset:
    ; Save current A value
    LDA #$41           ; 'A'
    PHA                ; Save it
    
    ; Do something else with A
    LDA #$42           ; 'B'
    STA $6000          ; Output 'B'
    
    ; Restore A
    PLA                ; A = $41 again
    STA $6000          ; Output 'A'
    
    ; Stack multiple values
    LDA #$31           ; '1'
    PHA
    LDA #$32           ; '2'
    PHA
    LDA #$33           ; '3'
    PHA
    
    ; Pop in reverse order
    PLA                ; A = $33 ('3')
    STA $6000
    PLA                ; A = $32 ('2')
    STA $6000
    PLA                ; A = $31 ('1')
    STA $6000
    
done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

Output: "BA321"

## Breaking It Down

### Saving and Restoring A

```asm
    LDA #$41
    PHA                ; Save A
    
    ; Modify A here
    LDA #$00
    ; ...
    
    PLA                ; Restore A (back to $41)
```

This is the most common use - preserve A while using it for something else!

### Multiple Values

```asm
    LDA #$01
    PHA                ; Stack: [$01]
    
    LDA #$02
    PHA                ; Stack: [$02, $01]
    
    LDA #$03
    PHA                ; Stack: [$03, $02, $01]
```

Pull order is **reversed**:
```asm
    PLA                ; A = $03
    PLA                ; A = $02
    PLA                ; A = $01
```

## Saving All Registers

To preserve all registers before a subroutine:

```asm
save_registers:
    PHA                ; Save A
    TXA                ; Transfer X to A
    PHA                ; Save X (via A)
    TYA                ; Transfer Y to A
    PHA                ; Save Y (via A)
    
    ; Do work that modifies A, X, Y
    
restore_registers:
    PLA                ; Pull Y (into A)
    TAY                ; Transfer A to Y
    PLA                ; Pull X (into A)
    TAX                ; Transfer A to X
    PLA                ; Pull A
    RTS
```

**Remember:** Pull in **reverse order**!

## Saving Flags - PHP and PLP

The processor status register (P) contains all flags. You can save and restore it:

```asm
    PHP                ; Save flags
    
    ; Operations that modify flags
    CLC
    LDA #$00
    ADC #$01
    ; Now C=0, Z=0, N=0, etc.
    
    PLP                ; Restore original flags
```

### Use Case: Testing Without Side Effects

```asm
; Check if value is zero without affecting flags
check_value:
    PHP                ; Save current flags
    
    LDA value
    BEQ .is_zero       ; Check
    
    ; Not zero path
    PLP                ; Restore flags
    CLC                ; Signal not zero
    RTS
    
.is_zero:
    PLP                ; Restore flags
    SEC                ; Signal zero
    RTS
```

## Practical Example: Nested Function Calls

```asm
; nested_stack.s - Demonstrating nested calls with stack

.segment "CODE"
.org $8000

reset:
    LDA #$05
    JSR factorial      ; Calculate 5!
    ; A now contains 120 (but truncated to 8-bit)
    
done:
    JMP done

; Subroutine: factorial
; Input: A = n
; Output: A = n! (mod 256)
; Recursive implementation
factorial:
    ; Base case: if A <= 1, return 1
    CMP #$02
    BCS .recursive     ; If A >= 2, recurse
    
    LDA #$01           ; Return 1
    RTS

.recursive:
    ; Save n
    PHA
    
    ; Calculate (n-1)!
    SEC
    SBC #$01           ; A = n - 1
    JSR factorial      ; Recursive call, result in A
    
    ; Multiply by n
    STA temp           ; Save (n-1)!
    PLA                ; Restore n
    
    ; A = n, temp = (n-1)!
    ; Need to multiply
    JSR multiply_by_temp
    RTS

; Helper: multiply A by temp
multiply_by_temp:
    ; Simple multiplication by repeated addition
    ; (Simplified - real implementation would be more complex)
    PHA                ; Save multiplier
    LDA #$00           ; Result
    STA result
    PLA
    TAY                ; Y = multiplier
    
.loop:
    CPY #$00
    BEQ .done_mult
    
    CLC
    LDA result
    ADC temp
    STA result
    
    DEY
    JMP .loop
    
.done_mult:
    LDA result
    RTS

temp:   .byte 0
result: .byte 0

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Stack Pointer Manipulation

You can directly manipulate the stack pointer!

### TSX - Transfer Stack Pointer to X

```asm
TSX                ; X = S
```

### TXS - Transfer X to Stack Pointer

```asm
TXS                ; S = X
```

### Use Case: Examining Stack Contents

```asm
; Look at what's on the stack without pulling
examine_stack:
    TSX                ; X = current stack pointer
    
    LDA $0101,X        ; Look at top of stack
    ; (Note: S points to next free, so top is at S+1)
    
    RTS
```

### Use Case: Stack Reset

```asm
; Reset stack to empty
reset_stack:
    LDX #$FF
    TXS                ; S = $FF (empty stack)
    RTS
```

### Use Case: Discarding Stack Values

```asm
; Discard top 2 bytes from stack
discard_two:
    TSX
    INX                ; Skip one byte
    INX                ; Skip another
    TXS                ; Update stack pointer
    RTS
```

## Advanced: Parameter Passing via Stack

Professional technique for passing parameters:

```asm
; Call subroutine with parameters on stack
    LDA #$20           ; First parameter
    PHA
    LDA #$15           ; Second parameter
    PHA
    
    JSR add_params     ; Call
    
    ; Clean up stack (caller's responsibility)
    PLA                ; Discard param 2
    PLA                ; Discard param 1
    
    ; Result in A

; Subroutine: add_params
; Parameters on stack:
;   S+3: param1
;   S+2: param2
;   S+1: return address high
;   S+0: return address low (S points here)
add_params:
    TSX                ; X = stack pointer
    
    LDA $0103,X        ; Load param1 (S+3)
    CLC
    ADC $0102,X        ; Add param2 (S+2)
    ; Result in A
    
    RTS
```

**Note:** This is complex but very powerful for complex functions!

## Practical Example: Context Switch

```asm
; context_switch.s - Saving complete CPU state

.segment "CODE"
.org $8000

; Saved context
saved_a: .byte 0
saved_x: .byte 0
saved_y: .byte 0
saved_p: .byte 0
saved_s: .byte 0

reset:
    ; Set up some state
    LDA #$42
    LDX #$10
    LDY #$20
    
    ; Save complete state
    JSR save_context
    
    ; Change everything
    LDA #$00
    LDX #$00
    LDY #$00
    SEC
    
    ; Restore state
    JSR restore_context
    
    ; A, X, Y, and flags are back to original!
    
done:
    JMP done

; Save complete CPU context
save_context:
    STA saved_a        ; Save A
    
    TXA
    PHA                ; Save X via stack temporarily
    TYA
    PHA                ; Save Y via stack temporarily
    
    PHP                ; Save flags
    PLA
    STA saved_p
    
    TSX
    STX saved_s        ; Save stack pointer
    
    PLA                ; Restore Y
    TAY
    STA saved_y
    
    PLA                ; Restore X
    TAX
    STA saved_x
    
    RTS

; Restore complete CPU context
restore_context:
    LDA saved_s
    TAX
    TXS                ; Restore stack pointer
    
    LDA saved_p
    PHA
    PLP                ; Restore flags
    
    LDX saved_x        ; Restore X
    LDY saved_y        ; Restore Y
    LDA saved_a        ; Restore A
    
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Experiments

### Experiment 1: Stack Overflow

See what happens when you push too much:

```asm
overflow_test:
    LDX #$00
loop:
    PHA                ; Keep pushing
    INX
    BNE loop
    ; After 256 pushes, stack wraps around!
```

**Result:** Stack wraps to $01FF, overwriting data!

### Experiment 2: Unbalanced Stack

```asm
bad_subroutine:
    PHA
    PHA
    ; RTS will pull wrong address!
    RTS
```

**Result:** Returns to wrong location - crash!

### Experiment 3: Stack Inspection

Print the stack contents:

```asm
print_stack:
    TSX                ; X = stack pointer
    INX                ; Point to top value
    
.loop:
    CPX #$00           ; At top of stack page?
    BEQ .done
    
    LDA $0100,X        ; Read stack
    JSR print_hex      ; Print it
    INX
    JMP .loop
    
.done:
    RTS
```

## Exercises

**Exercise 1:** Write a subroutine that swaps A and X without using memory.
- Hint: Use the stack as temporary storage!

<details>
<summary>Solution to Exercise 1</summary>

```asm
; swap_ax
; Swaps values of A and X
swap_ax:
    PHA                ; Save A
    TXA                ; A = X
    TAY                ; Y = X (temporary)
    PLA                ; A = original A
    TAX                ; X = original A
    TYA                ; A = original X
    RTS
```

Alternative using only stack:
```asm
swap_ax:
    PHA                ; Stack: [A]
    TXA
    PHA                ; Stack: [X, A]
    
    PLA                ; A = X
    TAX                ; X = X (no-op, but clear the path)
    PLA                ; A = original X
    TAX                ; X = original A
    ; Now A=X, X=A, but we want A=original X
    
    PHA                ; Save current A
    TXA                ; A = original A (now in X)
    TAY                ; Temp save
    PLA                ; A = original X
    ; A=original X, need X=original A
    LDX temp           ; This needs memory!
```

Actually, you can't fully swap without memory or Y! Here's the best solution:
```asm
swap_ax:
    PHA                ; Save A
    TXA                ; A = X
    TAX                ; No, this doesn't work either!
```

Correct solution using Y:
```asm
swap_ax:
    TAY                ; Y = A
    TXA                ; A = X
    TAX                ; X = A (wait, no...)
    
; Actual correct solution:
swap_ax:
    PHA                ; Save A to stack
    TXA                ; A = X
    TAX                ; Useless
    
; Real solution needs temporary register:
swap_ax:
    PHA                ; Save A
    TXA
    TAY                ; Y = X
    PLA                ; A = original A
    TAX                ; X = original A
    TYA                ; A = original X
    RTS
```
</details>

**Exercise 2:** Write a subroutine that reverses the top N bytes on the stack.
- Input: X = number of bytes to reverse
- The bytes stay on the stack, just in reversed order

<details>
<summary>Solution to Exercise 2</summary>

```asm
temp_storage = $20     ; Temporary buffer

; reverse_stack
; Input: X = number of bytes to reverse
; The top X bytes on stack are reversed
reverse_stack:
    ; Pull all values into temporary storage
    STX temp_storage
    LDY #$00
    
.pull_loop:
    CPY temp_storage
    BEQ .push_phase
    PLA
    STA temp_buffer,Y
    INY
    JMP .pull_loop
    
.push_phase:
    ; Push back in same order (which reverses them)
    LDY #$00
    
.push_loop:
    CPY temp_storage
    BEQ .done
    LDA temp_buffer,Y
    PHA
    INY
    JMP .push_loop
    
.done:
    RTS

temp_buffer: .res 256  ; Reserve 256 bytes
```
</details>

**Exercise 3:** Write a subroutine that duplicates the top value on the stack.
- Before: Stack = [..., X]
- After: Stack = [..., X, X]

<details>
<summary>Solution to Exercise 3</summary>

```asm
; dup_stack
; Duplicates top value on stack
dup_stack:
    PLA                ; Pull return address low
    STA temp_lo
    PLA                ; Pull return address high
    STA temp_hi
    
    PLA                ; Pull the value to duplicate
    PHA                ; Push it back
    PHA                ; Push it again (duplicate)
    
    LDA temp_hi        ; Restore return address
    PHA
    LDA temp_lo
    PHA
    
    RTS

temp_lo: .byte 0
temp_hi: .byte 0
```

Wait, this is wrong! RTS is affected. Better solution:

```asm
; dup_stack
; Duplicates top value on stack
dup_stack:
    TSX                ; X = stack pointer
    LDA $0101,X        ; Peek at top of stack (S+1)
    PHA                ; Push copy
    RTS
```

This is much simpler!
</details>

## Deep Dive: How JSR Uses the Stack

Understanding JSR and RTS with the stack:

### JSR Execution

```asm
    JSR $8100          ; At address $8000
```

**What happens:**
1. Calculate return address: $8000 + 3 - 1 = $8002
2. Push return address high: $80 → Stack[$01FF], S = $FE
3. Push return address low: $02 → Stack[$01FE], S = $FD
4. PC = $8100

**Stack after JSR:**
```
$01FF: $80 (return address high)
$01FE: $02 (return address low) <- S points here
```

### RTS Execution

```asm
    RTS                ; In subroutine
```

**What happens:**
1. S = $FD, increment: S = $FE
2. Pull low byte: temp_lo = Stack[$01FE] = $02, S = $FE
3. Increment: S = $FF
4. Pull high byte: temp_hi = Stack[$01FF] = $80, S = $FF
5. PC = ($80 << 8) | $02 + 1 = $8003

### Stack Frame

After JSR, before subroutine executes:

```
Higher addresses
    [...other data...]
    Return address (high byte)
    Return address (low byte)  <- S points here
Lower addresses
```

If subroutine pushes local data:

```
Higher addresses
    [...other data...]
    Return address (high byte)
    Return address (low byte)
    Local variable 1
    Local variable 2           <- S points here
Lower addresses
```

RTS automatically skips the local variables if you clean them up!

## Deep Dive: Stack Limits

### Maximum Depth

Stack is 256 bytes. Each JSR uses 2 bytes.

**Without local variables:** ~128 nested calls

**With local variables:** Much less!

Example:
```asm
subroutine:
    PHA                ; 1 byte
    PHA                ; 1 byte
    PHA                ; 1 byte
    ; ... work ...
    PLA
    PLA
    PLA
    RTS
```

Each call uses 2 (return) + 3 (locals) = 5 bytes.

**Maximum depth:** 256 / 5 = ~51 calls

### Detecting Stack Overflow

```asm
check_stack:
    TSX
    CPX #$10           ; Is stack pointer < $10?
    BCC .overflow      ; Yes, we're getting full!
    
    ; Safe to continue
    RTS
    
.overflow:
    ; Handle overflow
    ; (Reset? Error message? Halt?)
    JMP error_handler
```

## Common Errors

### Forgetting to Pull

```asm
subroutine:
    PHA                ; Push
    LDA #$00
    ; Forgot PLA!
    RTS                ; Returns to wrong address!
```

**Result:** RTS uses pushed A as return address - crash!

### Pull in Wrong Order

```asm
    LDA #$01
    PHA
    LDA #$02
    PHA
    
    PLA                ; Gets $02
    TAX                ; X = $02
    PLA                ; Gets $01
    TAY                ; Y = $01
```

If you expected X=$01, Y=$02, you got them backwards!

### Modifying Stack Pointer Incorrectly

```asm
    TSX
    INX                ; Skip one byte
    INX                ; Skip another
    ; Forgot TXS!
    RTS                ; Still uses old S!
```

**Fix:** Must use TXS to update stack pointer!

## Key Takeaways

✅ Stack is **256 bytes** at $0100-$01FF

✅ Stack grows **downward** (high to low addresses)

✅ **PHA/PLA** for accumulator, **PHP/PLP** for flags

✅ Stack is **LIFO** - Last In, First Out

✅ **TSX/TXS** for direct stack pointer manipulation

✅ JSR uses stack for **return addresses** (2 bytes)

✅ Always **balance** pushes and pulls!

✅ Watch out for **stack overflow** with deep nesting

## Next Lesson

Ready for more? Continue to:
**[Lesson 09: Bit Manipulation →](../09-bits/)**

Learn powerful bitwise operations and masking techniques!

---

## Quick Reference

**Stack operations:**
```asm
PHA                ; Push A onto stack
PLA                ; Pull from stack into A
PHP                ; Push processor status
PLP                ; Pull processor status
```

**Stack pointer:**
```asm
TSX                ; Transfer S to X
TXS                ; Transfer X to S
```

**Save/restore pattern:**
```asm
PHA                ; Save
; ... do work ...
PLA                ; Restore
```

**Peek at stack:**
```asm
TSX                ; X = stack pointer
LDA $0101,X        ; Look at top value
```

---

*You've mastered the stack! State management is now your superpower!* 📚
