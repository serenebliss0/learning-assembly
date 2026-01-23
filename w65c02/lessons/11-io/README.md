# Lesson 11: Memory-Mapped I/O - Talking to the Outside World

Welcome to the world of hardware! This lesson introduces memory-mapped I/O, the fundamental way the 6502 communicates with external devices like LEDs, buttons, displays, and more.

## Learning Objectives

By the end of this lesson, you'll:
- Understand what memory-mapped I/O means
- Know how to read from and write to I/O devices
- Be able to control LEDs using memory writes
- Understand how to read button states
- Learn about hardware timing considerations
- Build simple hardware interaction programs

## What is Memory-Mapped I/O?

The 6502 doesn't have special I/O instructions like some CPUs (e.g., x86's `IN`/`OUT`). Instead, it treats I/O devices as **memory locations**.

**Key Concept:** When you write to certain memory addresses, you're not writing to RAM - you're controlling hardware!

### Memory Map Example

```
$0000-$7FFF  RAM (32K)
$8000-$9FFF  I/O Devices (8K)
  $8000      LED output port
  $8001      Button input port
  $8002      LCD command
  $8003      LCD data
$A000-$FFFF  ROM (24K)
```

This is a typical Ben Eater-style memory map. The I/O area is "decoded" by hardware to activate devices instead of RAM.

## Hardware Setup

For these examples, imagine this simple circuit:

```
Address Decoding:
- A15 = 1, A14 = 0, A13 = 0 → I/O selected ($8000-$9FFF)

LED Port ($8000):
- 8 LEDs connected to data bus D0-D7
- Active high (1 = LED on)
- Write-only

Button Port ($8001):
- 8 buttons connected to data bus D0-D7
- Pulled high, grounded when pressed (0 = pressed)
- Read-only
```

## The Code: LED Control

Create a file called `led_test.s`:

```asm
; led_test.s - Control LEDs via memory-mapped I/O
; Hardware: 8 LEDs connected to address $8000

.segment "CODE"
.org $8000

; I/O addresses
LED_PORT = $8000

reset:
    ; Test 1: Turn on all LEDs
    LDA #$FF           ; All bits set
    STA LED_PORT       ; Light all LEDs
    JSR delay

    ; Test 2: Turn off all LEDs
    LDA #$00           ; All bits clear
    STA LED_PORT       ; All LEDs off
    JSR delay

    ; Test 3: Alternate pattern
    LDA #$AA           ; Binary 10101010
    STA LED_PORT
    JSR delay

    LDA #$55           ; Binary 01010101
    STA LED_PORT
    JSR delay

    ; Test 4: Walking LED
    LDX #$08           ; 8 LEDs to test
    LDA #$01           ; Start with rightmost LED

walk_loop:
    STA LED_PORT       ; Light current LED
    JSR delay
    ASL A              ; Shift left (next LED)
    DEX
    BNE walk_loop

    JMP reset          ; Repeat forever

; Simple delay routine
; Delays approximately 65536 * 256 cycles
delay:
    LDY #$00           ; Outer loop counter
delay_outer:
    LDX #$00           ; Inner loop counter
delay_inner:
    NOP                ; Do nothing
    DEX
    BNE delay_inner
    DEY
    BNE delay_outer
    RTS

; Interrupt vectors
.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Defining I/O Addresses

```asm
LED_PORT = $8000
```

We use a constant for clarity. This makes code readable and easy to change if hardware changes.

### Writing to Hardware

```asm
LDA #$FF           ; Load value
STA LED_PORT       ; Write to I/O
```

**This looks like normal memory access!** That's the beauty of memory-mapped I/O. The difference is:
- Writing to RAM stores the value
- Writing to `LED_PORT` controls hardware

### Understanding Patterns

```asm
LDA #$AA           ; Binary: 10101010
STA LED_PORT
```

Each bit controls one LED:
- Bit 0 (D0) → LED 0
- Bit 1 (D1) → LED 1
- ...
- Bit 7 (D7) → LED 7

So `$AA` lights LEDs 1, 3, 5, and 7.

### Walking LEDs

```asm
LDA #$01           ; Start: 00000001
walk_loop:
    STA LED_PORT   ; Light LED
    JSR delay
    ASL A          ; Shift: 00000010, 00000100, etc.
    DEX
    BNE walk_loop
```

`ASL` (Arithmetic Shift Left) moves the bit left each time, creating a walking effect.

## Reading Input: Button Example

Create `button_test.s`:

```asm
; button_test.s - Read buttons and control LEDs
; Hardware: 8 buttons at $8001, 8 LEDs at $8000

.segment "CODE"
.org $8000

LED_PORT = $8000
BUTTON_PORT = $8001

reset:
    ; Main loop: read buttons, display on LEDs
main_loop:
    LDA BUTTON_PORT    ; Read button states
    EOR #$FF          ; Invert (buttons are active low)
    STA LED_PORT      ; Display on LEDs
    JMP main_loop     ; Repeat forever

; Interrupt vectors
.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

### Understanding Button Reading

```asm
LDA BUTTON_PORT    ; Read hardware
```

When you read from an input port:
- Data bus gets value from external device
- If button pressed → bit = 0 (grounded)
- If button not pressed → bit = 1 (pull-up)

```asm
EOR #$FF          ; Exclusive OR with all 1s
```

This **inverts** the bits because our buttons are active-low (0 when pressed), but we want LEDs to light when pressed (1 = on).

### Active High vs Active Low

**Active Low** (common for buttons):
- Logic 0 = active/pressed
- Logic 1 = inactive/not pressed

**Active High** (common for LEDs):
- Logic 1 = on/lit
- Logic 0 = off/dark

We use `EOR #$FF` to convert between them.

## Debouncing: A Real-World Problem

Physical buttons "bounce" - they make multiple contacts before settling:

```
Button pressed:    __|‾\__|‾‾‾‾‾‾‾‾
Desired signal:    __|‾‾‾‾‾‾‾‾‾‾‾‾
```

### Software Debounce

```asm
; button_debounce.s - Debounced button reader

.segment "CODE"
.org $8000

LED_PORT = $8000
BUTTON_PORT = $8001

reset:
    LDX #$00           ; Previous button state

main_loop:
    LDA BUTTON_PORT    ; Read current state
    STA $20           ; Save it
    JSR delay         ; Wait for bounce to settle
    LDA BUTTON_PORT    ; Read again
    CMP $20           ; Same as before?
    BNE main_loop     ; No - still bouncing, try again
    
    ; Stable reading
    CMP X              ; Changed from last time?
    BEQ main_loop     ; No change, keep waiting
    
    ; Button state changed!
    TAX               ; Save new state
    EOR #$FF          ; Invert for LEDs
    STA LED_PORT      ; Update display
    JMP main_loop

delay:
    PHA               ; Save A
    LDY #$10          ; Short delay
delay_loop:
    DEY
    BNE delay_loop
    PLA               ; Restore A
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

This reads twice with a delay, only accepting the reading if both match.

## Experiments

### Experiment 1: Binary Counter

Modify `led_test.s` to count in binary:

```asm
reset:
    LDA #$00          ; Start at 0
count_loop:
    STA LED_PORT      ; Display count
    JSR delay
    CLC               ; Clear carry
    ADC #$01          ; Add 1
    JMP count_loop    ; Continue forever
```

Watch the LEDs count from 0 to 255!

### Experiment 2: Test Individual Bits

Create patterns to test each LED individually:

```asm
test_leds:
    LDA #$01          ; Test LED 0
    STA LED_PORT
    JSR delay
    
    LDA #$02          ; Test LED 1
    STA LED_PORT
    JSR delay
    
    ; Continue for all 8 LEDs...
```

### Experiment 3: Button-Triggered Action

Make a button press trigger a sequence:

```asm
wait_for_button:
    LDA BUTTON_PORT
    AND #$01          ; Check button 0
    BNE wait_for_button  ; Wait until pressed (goes to 0)
    
    ; Button pressed! Run sequence
    ; (Add your LED sequence here)
```

## Exercises

**Exercise 1:** Create a "larson scanner" (KITT/Cylon effect) where an LED bounces back and forth.

**Exercise 2:** Make a simple game: light a random LED, player must press the corresponding button within time limit.

**Exercise 3:** Create a binary calculator display - read 4 buttons as input, display sum on LEDs.

<details>
<summary>Solution to Exercise 1</summary>

```asm
.segment "CODE"
.org $8000

LED_PORT = $8000

reset:
    LDA #$01          ; Start at right

scan_right:
    LDX #$07          ; 7 positions to right
right_loop:
    STA LED_PORT
    JSR delay
    ASL A             ; Shift left
    DEX
    BNE right_loop

scan_left:
    LDX #$07          ; 7 positions to left
left_loop:
    STA LED_PORT
    JSR delay
    LSR A             ; Shift right
    DEX
    BNE left_loop
    
    JMP scan_right    ; Repeat

delay:
    PHA
    LDY #$00
dly1:
    LDX #$00
dly2:
    DEX
    BNE dly2
    DEY
    BNE dly1
    PLA
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: Address Decoding

How does the 6502 know $8000 is an LED and not RAM?

**Answer: External hardware!**

### Simple Address Decoder

```
Address bus A15-A13: 100 → I/O selected
                    ↓
            +-------------+
            | 74LS138     |  3-to-8 decoder
A15 --------|A2           |
A14 --------|A1           |
A13 --------|A0           |
            |             |
            |   Y0   -----|-----→ LED enable ($8000)
            |   Y1   -----|-----→ Button enable ($8001)
            |   Y2   -----|-----→ (unused)
            +-------------+
```

When you write to $8000:
1. A15=1, A14=0, A13=0 activates decoder
2. A0-A2 select output Y0
3. Y0 enables LED latch
4. Data bus D0-D7 stored in latch
5. LEDs display the value

### Partial Address Decoding

Ben Eater's computer often uses **partial decoding** - not all address lines are checked:

```asm
LED_PORT = $8000   ; Also responds to $8002, $8004, $8006...
```

This is simpler but means addresses "mirror" throughout the range. Fine for simple systems!

## Deep Dive: Timing Considerations

### Hold Time

Hardware needs time to respond. The 6502 at 1MHz:
- 1 cycle = 1 microsecond
- Most instructions = 2-6 cycles

Usually this is **plenty** for simple I/O. But some devices (like LCDs) need delays between commands.

### Race Conditions

Reading an input port that's changing:

```asm
LDA BUTTON_PORT    ; Read at time T
; Button changes here!
STA $20           ; Store old value
```

**Solution:** Read twice and compare, or use hardware latching.

### Read-Modify-Write

Some devices are **write-only** or **read-only**:

```asm
INC LED_PORT      ; PROBLEM! INC reads then writes
```

If `LED_PORT` is write-only, the read returns garbage. **Solution:** Use memory variable:

```asm
INC $20           ; Modify in RAM
LDA $20
STA LED_PORT      ; Write result
```

## Real Hardware Example

This code works on Ben Eater's 6502 computer with a simple LED port:

### Bill of Materials
- 8× LEDs
- 8× 330Ω resistors
- 74HC573 (8-bit latch)
- 74LS138 (3-to-8 decoder) for address decode

### Connection
```
6502 Data Bus D0-D7 → 74HC573 D0-D7
6502 R/W̅ + Address decode → 74HC573 LE (latch enable)
74HC573 Q0-Q7 → LEDs → Resistors → Ground
```

When you `STA LED_PORT`:
1. Data bus has your value
2. Address decoder activates LE
3. Latch captures value
4. LEDs display it (even after bus changes)

## Common Errors

### LEDs don't light
**Check:**
- Power to LEDs
- Correct address decoding
- R/W̅ signal (should be LOW for write)
- Resistors not too large

### All LEDs always on/off
**Possible cause:** 
- Address decoder always/never active
- Latch not enabled
- Short circuit

### Random LED behavior
**Possible cause:**
- Floating inputs (add pull-ups)
- Missing ground connection
- Address conflicts

## Key Takeaways

✅ **Memory-mapped I/O** treats devices as memory addresses

✅ **Writing** to I/O address controls output devices (LEDs, displays)

✅ **Reading** from I/O address gets input device states (buttons, sensors)

✅ **Address decoding** determines which device responds

✅ **Timing** usually automatic at 6502 speeds, but some devices need delays

✅ **Debouncing** necessary for real button inputs

## Next Lesson

Ready to dive deeper into I/O? Continue to:
**[Lesson 12: VIA (65C22) - The Versatile Interface Adapter →](../12-via/)**

Learn about the powerful 65C22 VIA chip that provides GPIO, timers, shift registers, and more!

---

## Quick Reference

**Memory-Mapped I/O:**
```asm
; Output
LDA #value
STA IO_PORT

; Input
LDA IO_PORT
```

**Common Bit Operations:**
```asm
AND #mask      ; Clear bits (mask = 0)
ORA #mask      ; Set bits (mask = 1)
EOR #$FF       ; Invert all bits
ASL            ; Shift left (multiply by 2)
LSR            ; Shift right (divide by 2)
ROL            ; Rotate left through carry
ROR            ; Rotate right through carry
```

**Debounce Pattern:**
```asm
read_stable:
    LDA INPUT_PORT
    STA temp
    JSR delay
    LDA INPUT_PORT
    CMP temp
    BNE read_stable    ; Try again if different
    ; A now has stable value
```

---

*You're now ready to control real hardware!* 🚀
