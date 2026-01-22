# Lesson 12: VIA (65C22) - The Versatile Interface Adapter

The 65C22 VIA (Versatile Interface Adapter) is the 6502's Swiss Army knife for I/O. It provides 16 GPIO pins, two timers, a shift register, and interrupt capability - all in one chip!

## Learning Objectives

By the end of this lesson, you'll:
- Understand the 65C22 VIA architecture
- Know how to configure GPIO pins as inputs or outputs
- Be able to program the VIA timers
- Understand how to use VIA interrupts
- Build practical projects using the VIA

## The 65C22 VIA Chip

### Features
- **Two 8-bit I/O ports** (Port A and Port B)
- **16 GPIO pins** (each pin configurable as input or output)
- **Two 16-bit timers** with multiple modes
- **8-bit shift register** for serial I/O
- **Interrupt generation** from timers, pins, and shift register
- **Handshaking modes** for printer/peripheral control

### Why Use a VIA?

Instead of dedicated address decoders for each LED or button, the VIA gives you:
- 16 pins controlled through 4 addresses
- Built-in timers (no delay loops!)
- Interrupt support
- Industry-standard chip used in real computers (Apple II, VIC-20, BBC Micro)

## VIA Register Map

The VIA has 16 internal registers accessed at consecutive memory addresses:

```
If VIA base address is $8000:

$8000  ORB/IRB   Output/Input Register B
$8001  ORA/IRA   Output/Input Register A (with handshake)
$8002  DDRB      Data Direction Register B
$8003  DDRA      Data Direction Register A
$8004  T1C-L     Timer 1 Counter Low
$8005  T1C-H     Timer 1 Counter High
$8006  T1L-L     Timer 1 Latch Low
$8007  T1L-H     Timer 1 Latch High
$8008  T2C-L     Timer 2 Counter Low
$8009  T2C-H     Timer 2 Counter High
$800A  SR        Shift Register
$800B  ACR       Auxiliary Control Register
$800C  PCR       Peripheral Control Register
$800D  IFR       Interrupt Flag Register
$800E  IER       Interrupt Enable Register
$800F  ORA/IRA   Output/Input Register A (no handshake)
```

## Setting Up GPIO

### Data Direction Registers (DDR)

Each port has a DDR that controls pin direction:
- **0** = Input
- **1** = Output

```asm
; via_setup.s - Basic VIA GPIO setup

.segment "CODE"
.org $8000

; VIA registers
VIA_BASE = $8000
PORTB = VIA_BASE + $00    ; Port B data
PORTA = VIA_BASE + $01    ; Port A data
DDRB  = VIA_BASE + $02    ; Port B direction
DDRA  = VIA_BASE + $03    ; Port A direction

reset:
    ; Configure Port B as all outputs (for LEDs)
    LDA #$FF              ; All bits = 1 (output)
    STA DDRB              ; Set Port B direction
    
    ; Configure Port A as all inputs (for buttons)
    LDA #$00              ; All bits = 0 (input)
    STA DDRA              ; Set Port A direction
    
    ; Now we can use the ports!
    JMP main_loop

main_loop:
    ; Read buttons from Port A
    LDA PORTA             ; Read input pins
    
    ; Display on LEDs via Port B
    STA PORTB             ; Write to output pins
    
    JMP main_loop         ; Repeat forever

; Interrupt vectors
.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Configuring Direction

```asm
LDA #$FF              ; Binary: 11111111
STA DDRB              ; All 8 pins are outputs
```

Each bit in the DDR controls one pin:
- DDRB bit 0 → PB0 direction
- DDRB bit 1 → PB1 direction
- ...
- DDRB bit 7 → PB7 direction

**Mixed I/O example:**
```asm
LDA #%00001111        ; Binary: 4 outputs (low), 4 inputs (high)
STA DDRB              ; PB0-PB3 outputs, PB4-PB7 inputs
```

### Reading and Writing

Once direction is set:

```asm
; Output
LDA #$AA
STA PORTB             ; Writes to output pins

; Input
LDA PORTA             ; Reads from input pins
```

**Important:** You can always read or write the port registers. But:
- Writing to an input pin does nothing (value goes to internal latch, not pin)
- Reading an output pin returns the value you wrote (useful!)

## VIA Timers: Precise Timing

The VIA's biggest advantage: **hardware timers** that count without using CPU cycles!

### Timer 1: Free-Running Interval Timer

Timer 1 can generate precise delays and periodic interrupts.

```asm
; via_timer.s - Using VIA Timer 1 for delays

.segment "CODE"
.org $8000

VIA_BASE = $8000
PORTB  = VIA_BASE + $00
DDRB   = VIA_BASE + $02
T1CL   = VIA_BASE + $04    ; Timer 1 Counter Low
T1CH   = VIA_BASE + $05    ; Timer 1 Counter High
T1LL   = VIA_BASE + $06    ; Timer 1 Latch Low
T1LH   = VIA_BASE + $07    ; Timer 1 Latch High
ACR    = VIA_BASE + $0B    ; Auxiliary Control Register
IFR    = VIA_BASE + $0D    ; Interrupt Flag Register

reset:
    ; Setup Port B for LEDs
    LDA #$FF
    STA DDRB
    
    ; Configure Timer 1 for continuous interrupts
    LDA #%01000000        ; Timer 1 continuous, PB7 disabled
    STA ACR
    
    ; Set timer period for 0.1 second (at 1MHz: 100,000 cycles)
    ; 100,000 = $0186A0, but we'll use a smaller value for demo
    LDA #$00
    STA T1LL              ; Latch low = $00
    LDA #$40              ; Latch high = $40 (16,384 cycles)
    STA T1LH
    STA T1CH              ; Writing high byte starts timer
    
    LDA #$00              ; Counter for LED pattern

blink_loop:
    ; Wait for timer
    LDA IFR               ; Read interrupt flags
    AND #%01000000        ; Check Timer 1 flag (bit 6)
    BEQ blink_loop        ; Wait until set
    
    ; Timer expired! Clear flag by reading T1CL
    LDA T1CL              ; Reading low counter clears flag
    
    ; Toggle LED pattern
    LDA PORTB
    EOR #$FF              ; Invert all bits
    STA PORTB
    
    JMP blink_loop        ; Continue

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

### Understanding Timer Operation

1. **Load the latch** (T1LL/T1LH) with desired count
2. **Write to T1CH** to transfer latch to counter and start
3. **Counter decrements** each clock cycle
4. **When counter reaches 0:**
   - IFR bit 6 is set (timer expired)
   - In continuous mode: counter reloads from latch
   - Can generate interrupt (if enabled)
5. **Clear flag** by reading T1CL

### Timer Modes (ACR bits 6-7)

```
ACR bits 7-6:
  00 = One-shot mode (stop after timeout)
  01 = Free-run mode (auto-reload and continue)
  10 = One-shot mode with PB7 pulse output
  11 = Free-run mode with PB7 square wave output
```

## Calculating Timer Values

For a delay at 1MHz clock:

**Cycles needed = Frequency × Time**

Examples:
- 0.1 second = 1,000,000 × 0.1 = 100,000 cycles = $0186A0
- 1 millisecond = 1,000,000 × 0.001 = 1,000 cycles = $03E8
- 100 microseconds = 1,000,000 × 0.0001 = 100 cycles = $64

**Timer value = Cycles - 2** (accounting for VIA overhead)

```asm
; For 1ms delay at 1MHz:
LDA #<(1000-2)        ; Low byte
STA T1LL
LDA #>(1000-2)        ; High byte
STA T1LH
STA T1CH              ; Start timer
```

## Advanced Example: Traffic Light

```asm
; traffic_light.s - Traffic light controller using VIA timer

.segment "CODE"
.org $8000

VIA_BASE = $8000
PORTB  = VIA_BASE + $00
DDRB   = VIA_BASE + $02
T1CL   = VIA_BASE + $04
T1CH   = VIA_BASE + $05
T1LL   = VIA_BASE + $06
T1LH   = VIA_BASE + $07
ACR    = VIA_BASE + $0B
IFR    = VIA_BASE + $0D

; LED bit assignments
RED    = %00000001        ; PB0
YELLOW = %00000010        ; PB1
GREEN  = %00000100        ; PB2

reset:
    ; Setup
    LDA #$FF
    STA DDRB              ; Port B outputs
    
    LDA #%01000000        ; Timer continuous mode
    STA ACR

    ; Main traffic light sequence
main_loop:
    ; RED light - 5 seconds
    LDA #RED
    STA PORTB
    LDA #5                ; 5 time units
    JSR wait_seconds
    
    ; RED + YELLOW - 2 seconds
    LDA #(RED | YELLOW)
    STA PORTB
    LDA #2
    JSR wait_seconds
    
    ; GREEN - 5 seconds
    LDA #GREEN
    STA PORTB
    LDA #5
    JSR wait_seconds
    
    ; YELLOW - 2 seconds
    LDA #YELLOW
    STA PORTB
    LDA #2
    JSR wait_seconds
    
    JMP main_loop         ; Repeat

; Wait A seconds (approximately)
; Uses: A (seconds to wait), Y (counter)
wait_seconds:
    TAY                   ; Y = seconds count
wait_loop:
    ; Set timer for ~1 second (using smaller value for demo)
    LDA #<(10000-2)       ; Adjust for your clock speed
    STA T1LL
    LDA #>(10000-2)
    STA T1LH
    STA T1CH              ; Start timer
    
wait_timer:
    LDA IFR
    AND #%01000000
    BEQ wait_timer        ; Wait for timeout
    
    LDA T1CL              ; Clear flag
    
    DEY
    BNE wait_loop         ; Count down seconds
    
    RTS

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Timer 2: Simple Counter

Timer 2 is simpler - one-shot only, no free-run mode. Often used for:
- Single delays
- Counting external pulses (on PB6)

```asm
; Using Timer 2
LDA #<1000
STA VIA_BASE + $08        ; T2C-L
LDA #>1000
STA VIA_BASE + $09        ; T2C-H (starts timer)

; Wait for timeout
wait_t2:
    LDA VIA_BASE + $0D    ; Check IFR
    AND #%00100000        ; Timer 2 flag (bit 5)
    BEQ wait_t2
    
; Clear by reading T2C-L
LDA VIA_BASE + $08
```

## Shift Register: Serial I/O

The VIA can shift data in/out serially using the shift register (SR).

### Modes (ACR bits 2-4)

```
000 = Disabled
001 = Shift in under T2 control
010 = Shift in under Φ2 clock
011 = Shift in under external clock
100 = Shift out free-run at T2 rate
101 = Shift out under T2 control
110 = Shift out under Φ2 clock
111 = Shift out under external clock
```

### Example: LED Chaser with Shift Register

```asm
; Shift a pattern through LEDs
reset:
    LDA #$FF
    STA DDRB
    
    ; Enable shift out under T2 control
    LDA #%00010100        ; Shift out, T2 rate
    STA ACR
    
    ; Set T2 for shift rate
    LDA #<1000
    STA VIA_BASE + $08
    LDA #>1000
    STA VIA_BASE + $09
    
    ; Load pattern
    LDA #%10101010
    STA VIA_BASE + $0A    ; Shift register
    
    ; Pattern shifts out automatically!
    JMP *
```

## Experiments

### Experiment 1: PWM LED Dimming

Use Timer 1 to generate PWM (Pulse Width Modulation) for LED brightness:

```asm
; Vary duty cycle to dim LED
pwm_loop:
    LDA #$FF
    STA PORTB             ; LED on
    LDX #10               ; On time
    JSR short_delay
    
    LDA #$00
    STA PORTB             ; LED off
    LDX #90               ; Off time (longer = dimmer)
    JSR short_delay
    
    JMP pwm_loop
```

### Experiment 2: Frequency Counter

Use Timer 2 to count pulses on PB6:

```asm
; Configure T2 to count external pulses
LDA #%00100000        ; T2 counts PB6
STA ACR
```

### Experiment 3: Debounce with Timer

Use timer to implement hardware-assisted debouncing:

```asm
button_wait:
    LDA PORTA
    AND #$01              ; Check button
    BNE button_wait       ; Wait for press
    
    ; Start 20ms debounce timer
    LDA #<(20000-2)
    STA T1LL
    LDA #>(20000-2)
    STA T1LH
    STA T1CH
    
    ; Wait for timer
debounce:
    LDA IFR
    AND #%01000000
    BEQ debounce
    
    LDA T1CL              ; Clear flag
    
    ; Now read button again
    LDA PORTA
    AND #$01
    BNE button_wait       ; False alarm, try again
    
    ; Confirmed button press!
```

## Exercises

**Exercise 1:** Create a binary clock using Timer 1 to keep accurate time. Display seconds on 6 LEDs (0-59), minutes on 6 more LEDs.

**Exercise 2:** Implement a reaction time game: light random LED, measure time until corresponding button pressed using timer.

**Exercise 3:** Create a music player - use Timer 1 to generate different frequencies on a speaker connected to PB7.

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

VIA_BASE = $8000
ACR    = VIA_BASE + $0B
T1LL   = VIA_BASE + $06
T1LH   = VIA_BASE + $07
T1CH   = VIA_BASE + $05

; Note frequencies (timer values for 1MHz clock)
; These create square waves on PB7
NOTE_C = 3822          ; 261.6 Hz
NOTE_D = 3405          ; 293.7 Hz
NOTE_E = 3034          ; 329.6 Hz
NOTE_F = 2863          ; 349.2 Hz
NOTE_G = 2551          ; 392.0 Hz
NOTE_A = 2273          ; 440.0 Hz
NOTE_B = 2025          ; 493.9 Hz

reset:
    ; Configure Timer 1 for square wave on PB7
    LDA #%11000000        ; Free-run, PB7 toggle
    STA ACR
    
    ; Play C major scale
    LDX #$00
play_scale:
    LDA notes_lo,X
    STA T1LL
    LDA notes_hi,X
    STA T1LH
    STA T1CH              ; Start tone
    
    JSR delay_note        ; Hold note
    
    INX
    CPX #$07              ; 7 notes
    BNE play_scale
    
    JMP reset             ; Repeat

delay_note:
    LDY #$10              ; Note duration
dn1:
    LDX #$00
dn2:
    DEX
    BNE dn2
    DEY
    BNE dn1
    RTS

notes_lo:
    .byte <NOTE_C, <NOTE_D, <NOTE_E, <NOTE_F
    .byte <NOTE_G, <NOTE_A, <NOTE_B
notes_hi:
    .byte >NOTE_C, >NOTE_D, >NOTE_E, >NOTE_F
    .byte >NOTE_G, >NOTE_A, >NOTE_B

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: VIA Interrupts

The VIA can generate interrupts for various events:

### Interrupt Flag Register (IFR)

```
Bit 7: IRQ̅ (any enabled interrupt active)
Bit 6: Timer 1
Bit 5: Timer 2
Bit 4: CB1 (handshake)
Bit 3: CB2 (handshake)
Bit 2: Shift register
Bit 1: CA1 (handshake)
Bit 0: CA2 (handshake)
```

### Interrupt Enable Register (IER)

```
Bit 7: Set/Clear (1=set, 0=clear)
Bit 6-0: Enable bits (matching IFR)
```

To enable Timer 1 interrupts:
```asm
LDA #%11000000        ; Bit 7=1 (set), Bit 6=1 (Timer 1)
STA IER
```

To disable Timer 1 interrupts:
```asm
LDA #%01000000        ; Bit 7=0 (clear), Bit 6=1 (Timer 1)
STA IER
```

We'll cover interrupt handling in detail in Lesson 14!

## Deep Dive: Handshaking

The VIA supports automatic handshaking for printers and peripherals:

**CA1/CA2 and CB1/CB2** pins can:
- Detect edges (rising/falling)
- Generate automatic handshake pulses
- Trigger interrupts

This allows the VIA to handle parallel printer protocol automatically:
1. Computer writes data to port
2. CA2 pulses (tells printer "data ready")
3. Printer processes data
4. Printer pulses CA1 (tells VIA "acknowledged")
5. VIA generates interrupt
6. Computer writes next byte

## Real Hardware: Ben Eater's Computer

The W65C22S VIA is commonly used in Ben Eater-style 6502 builds:

### Connections
```
Address Bus A0-A3  → VIA RS0-RS3 (register select)
Data Bus D0-D7     → VIA D0-D7
R/W̅                → VIA R/W̅
Φ2                 → VIA Φ2 (clock)
CS1, C̅S̅2           → Address decoder (e.g., $8000-$800F)
R̅E̅S̅                → System reset

Port A PA0-PA7     → LCD data (or other device)
Port B PB0-PB7     → LEDs, buttons, etc.
```

### Typical Memory Map
```
$8000-$800F: VIA registers
$8000: Port B data (LEDs/buttons)
$8001: Port A data (LCD data)
```

## Common Errors

### Timer doesn't trigger
**Check:**
- ACR configured correctly
- IFR flag being cleared (read T1CL)
- Timer value not too small
- Clock connected to VIA

### Port doesn't output
**Check:**
- DDR set to output (1)
- Writing to correct address
- VIA chip enabled (CS pins)

### Can't read inputs
**Check:**
- DDR set to input (0)
- Pull-up resistors on input pins
- Reading correct port address

## Key Takeaways

✅ **VIA provides 16 GPIO pins** through 2 ports

✅ **Data Direction Registers** (DDR) control input/output

✅ **Timer 1** is versatile - one-shot, free-run, PWM capable

✅ **Timer 2** is simpler - one-shot and pulse counting

✅ **Shift register** enables serial I/O

✅ **Interrupts** available for timers and I/O events

✅ **Hardware timers** more accurate than software delays

## Next Lesson

Ready to control an LCD? Continue to:
**[Lesson 13: LCD Display - Text Output →](../13-lcd/)**

Learn how to interface the HD44780 LCD controller using the VIA!

---

## Quick Reference

**VIA Register Offsets:**
```
+$00  PORTB/IRB    +$08  T2C-L
+$01  PORTA/IRA    +$09  T2C-H
+$02  DDRB         +$0A  SR
+$03  DDRA         +$0B  ACR
+$04  T1C-L        +$0C  PCR
+$05  T1C-H        +$0D  IFR
+$06  T1L-L        +$0E  IER
+$07  T1L-H        +$0F  PORTA (no handshake)
```

**Timer Setup:**
```asm
; Load timer value
LDA #<value
STA T1LL
LDA #>value
STA T1LH
STA T1CH          ; Starts timer

; Wait for timeout
wait:
    LDA IFR
    AND #%01000000
    BEQ wait
LDA T1CL          ; Clear flag
```

**GPIO Setup:**
```asm
; Configure direction
LDA #%11110000    ; High nibble output, low input
STA DDRA

; Write outputs
LDA #value
STA PORTA

; Read inputs
LDA PORTA
```

---

*The VIA is your I/O powerhouse!* ⚡
