# Lesson 01: Hello World - Your First W65C02 Program

Welcome to your first 6502 assembly program! We'll write a simple program that outputs characters.

## Learning Objectives

By the end of this lesson, you'll:
- Understand the basic structure of a 6502 program
- Know how to use the accumulator and registers
- Understand memory-mapped I/O
- Be able to assemble and test in an emulator

## The 6502 CPU

The W65C02 is beautifully simple:

**Registers:**
- **A** (Accumulator) - Main working register
- **X** (Index) - For indexing and counting
- **Y** (Index) - For indexing and counting
- **PC** (Program Counter) - Current instruction address
- **S** (Stack Pointer) - Top of stack
- **P** (Processor Status) - Flags

**No 16 or 32-bit registers - just 8-bit!** Simple and elegant.

## The Code

Create a file called `hello.s`:

```asm
; hello.s - Your first W65C02 program
; This program writes "Hello, World!" to memory location $6000
; py65mon can read this location and display it

.segment "CODE"
.org $8000              ; Start program at address $8000

reset:
    LDX #$00           ; Initialize X register to 0

loop:
    LDA message,X      ; Load character from message into A
    BEQ done          ; If zero (end of string), we're done
    STA $6000         ; Store character to output location
    INX               ; Increment X (move to next character)
    JMP loop          ; Jump back to loop

done:
    JMP done          ; Loop forever (halt)

message:
    .byte "Hello, World!", $00    ; Our message, null-terminated

; Interrupt vectors
.segment "VECTORS"
.org $FFFC
.word reset           ; Reset vector points to our start
.word $0000           ; NMI vector (not used)
```

## Breaking It Down

### Segments and Origin

```asm
.segment "CODE"
.org $8000
```

- `.segment "CODE"` - Declares this is code
- `.org $8000` - Start at address $8000 (32768 in decimal)

On 6502, we typically put programs in high memory and use low memory (zero page) for variables.

### Initialize Index Register

```asm
LDX #$00
```

- `LDX` - "Load X register"
- `#` - Immediate mode (literal value)
- `$00` - Zero in hexadecimal

This sets X = 0. We'll use X as an index into our message string.

### The Loop

```asm
loop:
    LDA message,X      ; Load character from message
    BEQ done          ; Branch if equal to zero
    STA $6000         ; Store to output
    INX               ; Increment X
    JMP loop          ; Jump back to loop
```

Let's trace through this:

**First iteration (X=0):**
1. `LDA message,X` - Load message[0] = 'H' into A
2. `BEQ done` - Is A zero? No, so don't branch
3. `STA $6000` - Write 'H' to address $6000
4. `INX` - X becomes 1
5. `JMP loop` - Go back to loop

**Second iteration (X=1):**
1. `LDA message,X` - Load message[1] = 'e' into A
2. Continue...

**Last iteration (X=13):**
1. `LDA message,X` - Load message[13] = $00 (null terminator)
2. `BEQ done` - A is zero! Branch to done

### The Halt

```asm
done:
    JMP done
```

This jumps to itself - infinite loop. This is how we "halt" on 6502!

### The Data

```asm
message:
    .byte "Hello, World!", $00
```

- `message:` - Label for this data
- `.byte` - Define byte(s)
- `"Hello, World!"` - Our string
- `$00` - Null terminator (marks end)

### Reset Vector

```asm
.segment "VECTORS"
.org $FFFC
.word reset
```

When the 6502 powers on or resets, it reads address $FFFC-$FFFD to know where to start. We put the address of our `reset` label there.

## Building and Running

### Step 1: Assemble

```bash
ca65 hello.s -o hello.o
```

This creates `hello.o` (object file).

### Step 2: Link

```bash
ld65 -t none -o hello.bin hello.o
```

This creates `hello.bin` (binary file).

- `-t none` - No target system (raw binary)

### Step 3: Run in Emulator

```bash
py65mon -m 65c02 -r hello.bin
```

This loads and runs the program in py65mon emulator.

You can interact with the emulator:

```
py65> goto 8000        # Jump to start of program
py65> step             # Execute one instruction
py65> mem 6000         # View memory at $6000
py65> registers        # Show all registers
```

### Step 4: See the Output

In py65mon, the program writes each character to $6000. You can see them:

```
py65> mem 6000
```

Or you can step through and watch the program run!

## Understanding Addressing Modes

The 6502 has several ways to access data:

### Immediate Mode
```asm
LDA #$42        ; Load the VALUE $42 into A
```

### Absolute Mode
```asm
LDA $2000       ; Load value FROM address $2000 into A
```

### Indexed Mode
```asm
LDA message,X   ; Load value from (message + X) into A
```

If `message` is at $8020 and X = 3, this loads from $8023.

We'll cover more addressing modes in Lesson 3!

## Experiments

### Experiment 1: Change the Message

Change:
```asm
.byte "Hello, World!", $00
```

To:
```asm
.byte "I love assembly!", $00
```

Reassemble and run. Does it work?

### Experiment 2: Without Null Terminator

Remove the `$00`:
```asm
.byte "Hello, World!"
```

What happens? (Hint: BEQ never triggers, loop continues past message!)

### Experiment 3: Count Down

Try using DEX (decrement X) instead of INX:

```asm
    LDX #$0C       ; Start at end of message
loop:
    LDA message,X
    STA $6000
    DEX            ; Count down
    BPL loop       ; Branch if plus (not negative)
```

This prints backwards!

## Exercises

**Exercise 1:** Modify the program to print your name.

**Exercise 2:** Add a second message and print both (hint: need two loops or reuse the loop).

**Exercise 3:** Print numbers 0-9 instead of a string.
- Hint: Start with X = 0, loop while X < 10
- Convert X to ASCII by adding $30 (0 is ASCII $30, 1 is $31, etc.)

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

reset:
    LDX #$00           ; Start at 0

loop:
    TXA                ; Transfer X to A
    CLC                ; Clear carry
    ADC #$30          ; Add $30 to convert to ASCII
    STA $6000         ; Output
    INX               ; Next number
    CPX #$0A          ; Compare X to 10
    BNE loop          ; Continue if not 10

done:
    JMP done

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: The Accumulator

The **A register** (accumulator) is your main working register. Almost all operations involve it:

- Arithmetic: `ADC`, `SBC`
- Logic: `AND`, `ORA`, `EOR`
- Loads/Stores: `LDA`, `STA`
- Comparisons: `CMP`

You'll be using A constantly!

## Deep Dive: Flags

The P register (status) has flags that track conditions:

- **Z** (Zero) - Set if result was zero
- **N** (Negative) - Set if bit 7 is set (signed negative)
- **C** (Carry) - Set on overflow/underflow
- **V** (Overflow) - Set on signed overflow

Our `BEQ` checks the Z flag. When `LDA` loads $00, Z flag is set, so BEQ branches.

## Common Errors

### Error: "ca65: command not found"
**Solution:** Install cc65. See [setup guide](../../setup.md).

### Program doesn't output anything
**Solution:** 
- Check emulator is showing memory location $6000
- Make sure you're using py65mon correctly
- Try stepping through with `step` command

### Assembler syntax error
**Solution:**
- ca65 uses different syntax than some 6502 assemblers
- Make sure you have `#` for immediate values
- Check your segment declarations

## Key Takeaways

✅ 6502 has simple, elegant design with just a few registers

✅ **A register** (accumulator) is your main working register

✅ **Indexed addressing** (`,X` and `,Y`) is powerful for arrays/strings

✅ **Flags** track conditions for branching

✅ Must set **reset vector** at $FFFC

## Next Lesson

Ready for more? Continue to:
**[Lesson 02: Registers and Flags →](../02-registers/)**

Or practice more with experiments first!

---

## Quick Reference

**Assemble:**
```bash
ca65 program.s -o program.o
```

**Link:**
```bash
ld65 -t none -o program.bin program.o
```

**Run in emulator:**
```bash
py65mon -m 65c02 -r program.bin
```

**Emulator commands:**
```
goto 8000      # Jump to address
step           # Execute one instruction
registers      # Show registers
mem 6000       # View memory
```

---

*Congratulations on your first 6502 program!* 🎉
