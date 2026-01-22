# Lesson 13: LCD Display - Text Output Made Easy

The HD44780 LCD controller is the most popular character LCD interface. In this lesson, we'll connect an LCD to our W65C02 and display text - a huge milestone in building a complete computer!

## Learning Objectives

By the end of this lesson, you'll:
- Understand HD44780 LCD architecture and commands
- Know how to initialize an LCD properly
- Be able to display text and custom characters
- Understand 4-bit vs 8-bit interface modes
- Control cursor position and display attributes
- Build a working text display system

## The HD44780 LCD Controller

### What is it?

The HD44780 is a character LCD controller found in most 16×2 and 20×4 displays. It:
- Stores displayed characters in RAM (DDRAM)
- Generates character patterns from ROM (CGROM)
- Allows custom characters (CGRAM)
- Handles all display timing internally
- Simple parallel interface

### Common LCD Sizes
- **16×2** - 16 characters × 2 lines (most common)
- **20×4** - 20 characters × 4 lines
- **16×1** - 16 characters × 1 line

## LCD Pin Connections

Standard 16-pin HD44780 interface:

```
Pin  Name  Function
---  ----  --------
 1   VSS   Ground
 2   VDD   +5V power
 3   V0    Contrast adjust (potentiometer)
 4   RS    Register Select (0=command, 1=data)
 5   R/W̅   Read/Write (0=write, 1=read)
 6   E     Enable (falling edge triggers action)
 7   DB0   Data bit 0  ┐
 8   DB1   Data bit 1  │ 8-bit mode uses all
 9   DB2   Data bit 2  │ 4-bit mode uses only
10   DB3   Data bit 3  ┘ DB4-DB7 (saves 4 pins!)
11   DB4   Data bit 4  ┐
12   DB5   Data bit 5  │ Always used
13   DB6   Data bit 6  │
14   DB7   Data bit 7  ┘
15   A     Backlight anode (+)
16   K     Backlight cathode (-)
```

## Connecting LCD to VIA

For this lesson, we'll use 4-bit mode to save pins:

```
LCD      VIA 65C22
---      ---------
RS    →  PA0
R/W̅   →  PA1  (or tie to GND for write-only)
E     →  PA2
DB4   →  PA4
DB5   →  PA5
DB6   →  PA6
DB7   →  PA7
```

This uses 7 VIA pins, leaving PA3 and Port B free!

## LCD Commands

The HD44780 has two register types:

### Register Select (RS)
- **RS = 0**: Command register (control LCD)
- **RS = 1**: Data register (write characters)

### Common Commands (RS=0)

```
Command                    Code     Description
-------------------------- -------- ---------------------------
Clear display              0x01     Clear screen, home cursor
Return home                0x02     Cursor to position 0
Entry mode set             0x04-07  Cursor move direction
Display on/off             0x08-0F  Display/cursor/blink control
Cursor/display shift       0x10-1F  Move cursor or display
Function set               0x20-3F  Interface width, lines, font
Set CGRAM address          0x40-7F  Custom character address
Set DDRAM address          0x80-FF  Cursor position
```

### Important Command Details

**Entry Mode (0x04-0x07):**
```
0x04 = Cursor moves left, no shift
0x05 = Cursor moves left, display shifts right
0x06 = Cursor moves right, no shift ← Most common
0x07 = Cursor moves right, display shifts left
```

**Display Control (0x08-0x0F):**
```
Bit 2: Display on/off
Bit 1: Cursor on/off
Bit 0: Cursor blink on/off

0x08 = Display off
0x0C = Display on, cursor off
0x0E = Display on, cursor on, no blink
0x0F = Display on, cursor on, blinking
```

**Function Set (0x20-0x3F):**
```
Bit 4: Interface (1=8-bit, 0=4-bit)
Bit 3: Lines (1=2-line, 0=1-line)
Bit 2: Font (1=5×10, 0=5×8)

0x28 = 4-bit, 2-line, 5×8 font ← Common
0x38 = 8-bit, 2-line, 5×8 font
```

## The Code: LCD Initialization

```asm
; lcd_init.s - Initialize HD44780 LCD in 4-bit mode

.segment "CODE"
.org $8000

; VIA ports
VIA_BASE = $8000
PORTA = VIA_BASE + $01
DDRA  = VIA_BASE + $03

; LCD control bits on Port A
LCD_RS = %00000001        ; PA0 - Register Select
LCD_RW = %00000010        ; PA1 - Read/Write
LCD_E  = %00000100        ; PA2 - Enable
LCD_DATA = %11110000      ; PA4-PA7 - Data bits

reset:
    ; Configure VIA Port A
    LDA #$FF              ; All outputs
    STA DDRA
    
    ; Wait for LCD power-on (>40ms)
    JSR delay_long
    JSR delay_long
    
    ; Initialize LCD to 4-bit mode
    ; This sequence is critical!
    
    ; First: Send 0x03 three times (special init sequence)
    LDA #$30              ; 0x03 in high nibble
    JSR lcd_init_nibble
    JSR delay_long        ; >4.1ms
    
    LDA #$30
    JSR lcd_init_nibble
    JSR delay_short       ; >100μs
    
    LDA #$30
    JSR lcd_init_nibble
    JSR delay_short
    
    ; Now switch to 4-bit mode
    LDA #$20              ; 0x02 in high nibble
    JSR lcd_init_nibble
    JSR delay_short
    
    ; LCD is now in 4-bit mode!
    ; Configure: 4-bit, 2-line, 5x8 font
    LDA #$28
    JSR lcd_command
    
    ; Display on, cursor on, blink on
    LDA #$0F
    JSR lcd_command
    
    ; Clear display
    LDA #$01
    JSR lcd_command
    JSR delay_long        ; Clear needs extra time
    
    ; Entry mode: increment cursor, no shift
    LDA #$06
    JSR lcd_command
    
    ; LCD is ready!
    JMP main_program

; Send initialization nibble (special mode)
; Only used during initialization!
lcd_init_nibble:
    STA PORTA             ; Output data
    ORA #LCD_E            ; Set E high
    STA PORTA
    AND #(~LCD_E)         ; Set E low (trigger)
    STA PORTA
    RTS

; Send command to LCD (RS=0)
; A = command byte
lcd_command:
    PHA                   ; Save command
    
    ; Send high nibble
    AND #$F0              ; Mask high nibble
    STA PORTA             ; Output (RS=0, RW=0)
    ORA #LCD_E            ; E high
    STA PORTA
    AND #(~LCD_E)         ; E low
    STA PORTA
    
    PLA                   ; Restore command
    PHA                   ; Save again
    
    ; Send low nibble
    ASL A                 ; Shift low nibble to high
    ASL A
    ASL A
    ASL A
    STA PORTA             ; Output
    ORA #LCD_E            ; E high
    STA PORTA
    AND #(~LCD_E)         ; E low
    STA PORTA
    
    PLA                   ; Restore A
    JSR delay_short       ; Command execution time
    RTS

; Send data to LCD (RS=1)
; A = character to display
lcd_data:
    PHA                   ; Save character
    
    ; Send high nibble
    AND #$F0              ; Mask high nibble
    ORA #LCD_RS           ; Set RS=1 (data mode)
    STA PORTA
    ORA #LCD_E            ; E high
    STA PORTA
    AND #(~LCD_E)         ; E low
    STA PORTA
    
    PLA                   ; Restore character
    PHA                   ; Save again
    
    ; Send low nibble
    ASL A                 ; Shift low nibble to high
    ASL A
    ASL A
    ASL A
    ORA #LCD_RS           ; Keep RS=1
    STA PORTA
    ORA #LCD_E            ; E high
    STA PORTA
    AND #(~LCD_E)         ; E low
    STA PORTA
    
    PLA                   ; Restore A
    JSR delay_short       ; Character execution time
    RTS

; Delay routines
delay_long:               ; ~5ms at 1MHz
    PHA
    PHX
    LDX #$FA
dl1:
    DEX
    BNE dl1
    PLX
    PLA
    RTS

delay_short:              ; ~50μs at 1MHz
    PHA
    PHX
    LDX #$10
ds1:
    DEX
    BNE ds1
    PLX
    PLA
    RTS

main_program:
    ; Now use the LCD!
    ; Display "Hello, World!"
    
    ; Print string
    LDX #$00
print_loop:
    LDA message,X
    BEQ done              ; Stop at null terminator
    JSR lcd_data
    INX
    JMP print_loop

done:
    JMP done              ; Halt

message:
    .byte "Hello, World!", $00

; Interrupt vectors
.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Breaking It Down

### Initialization Sequence

The HD44780 requires a specific initialization:

1. **Wait >40ms** after power-on
2. **Send 0x03** (function set) three times with delays
3. **Send 0x02** to switch to 4-bit mode
4. **Now in 4-bit mode**, send full commands:
   - Function set (0x28)
   - Display control (0x0F)
   - Clear display (0x01)
   - Entry mode (0x06)

**Why so complex?** The LCD doesn't know if you're using 4-bit or 8-bit mode at startup. This sequence works regardless.

### 4-Bit Communication

In 4-bit mode, each byte is sent as **two nibbles** (high, then low):

```asm
; To send 0x48 ('H'):
; High nibble: 0x40 (4 in high bits)
; Low nibble:  0x80 (8 in high bits, shifted left 4)

; Send high nibble
LDA #$48
AND #$F0              ; = 0x40
; ... send to LCD ...

; Send low nibble
LDA #$48
ASL A                 ; = 0x90
ASL A                 ; = 0x20
ASL A                 ; = 0x40
ASL A                 ; = 0x80
; ... send to LCD ...
```

### Enable (E) Signal

The LCD reads data on the **falling edge** of E:

```asm
LDA #data
STA PORTA             ; Data + RS + RW, E=0
ORA #LCD_E            ; Set E=1
STA PORTA             ; E goes high
AND #(~LCD_E)         ; Clear E bit
STA PORTA             ; E goes low → LCD reads data
```

## Cursor Positioning

The LCD's DDRAM (Display Data RAM) is not linear:

### 16×2 Display DDRAM Addresses

```
Line 1: 0x00-0x0F (addresses 0x00-0x0F)
Line 2: 0x40-0x4F (addresses 0x40-0x4F)
```

### 20×4 Display DDRAM Addresses

```
Line 1: 0x00-0x13 (addresses 0x00-0x13)
Line 2: 0x40-0x53 (addresses 0x40-0x53)
Line 3: 0x14-0x27 (addresses 0x14-0x27)
Line 4: 0x54-0x67 (addresses 0x54-0x67)
```

### Set Cursor Position

To position cursor, set DDRAM address (command 0x80-0xFF):

```asm
; Set cursor to line 1, column 5
; Address = 0x00 + 5 = 0x05
; Command = 0x80 | 0x05 = 0x85
LDA #$85
JSR lcd_command

; Set cursor to line 2, column 0
; Address = 0x40
; Command = 0x80 | 0x40 = 0xC0
LDA #$C0
JSR lcd_command
```

### Helper Function

```asm
; Set cursor position
; X = column (0-15)
; Y = row (0-1)
lcd_set_cursor:
    TYA
    BEQ cursor_line1
    
cursor_line2:
    TXA
    CLC
    ADC #$40              ; Line 2 starts at 0x40
    ORA #$80              ; Set DDRAM command bit
    JSR lcd_command
    RTS
    
cursor_line1:
    TXA
    ORA #$80              ; Set DDRAM command bit
    JSR lcd_command
    RTS
```

## Custom Characters

The LCD can store 8 custom 5×8 characters in CGRAM:

### Character Format

Each character is 8 bytes (rows), 5 bits used per byte:

```
Byte 0: Row 0  %xxx00000  (bits 4-0 used)
Byte 1: Row 1  %xxx00000
Byte 2: Row 2  %xxx00000
Byte 3: Row 3  %xxx00000
Byte 4: Row 4  %xxx00000
Byte 5: Row 5  %xxx00000
Byte 6: Row 6  %xxx00000
Byte 7: Row 7  %xxx00000  (usually cursor row)
```

### Example: Heart Character

```asm
; Define heart character (character 0)
create_heart:
    ; Set CGRAM address (char 0 = address 0x00)
    LDA #$40              ; CGRAM command + address 0
    JSR lcd_command
    
    ; Send 8 bytes of character data
    LDA #%00000           ; Row 0
    JSR lcd_data
    LDA #%01010           ; Row 1  .█.█.
    JSR lcd_data
    LDA #%11111           ; Row 2  █████
    JSR lcd_data
    LDA #%11111           ; Row 3  █████
    JSR lcd_data
    LDA #%01110           ; Row 4  .███.
    JSR lcd_data
    LDA #%00100           ; Row 5  ..█..
    JSR lcd_data
    LDA #%00000           ; Row 6
    JSR lcd_data
    LDA #%00000           ; Row 7
    JSR lcd_data
    
    ; Return to DDRAM mode
    LDA #$80
    JSR lcd_command
    RTS

; Display the custom character
display_heart:
    LDA #$00              ; Character 0
    JSR lcd_data
    RTS
```

## Advanced Example: Scrolling Text

```asm
; scrolling_text.s - Scroll text across LCD

.segment "CODE"
.org $8000

; (Include lcd_command, lcd_data, etc. from above)

main_program:
    ; Initialize LCD
    JSR lcd_init
    
    ; Display scrolling message
    LDX #$00              ; Start position in message

scroll_loop:
    ; Clear display
    LDA #$01
    JSR lcd_command
    JSR delay_long
    
    ; Print 16 characters starting at position X
    LDY #$00              ; Screen position
print_window:
    TXA
    CLC
    ADC Y                 ; Message position = X + Y
    TAX
    LDA message,X
    BEQ reset_scroll      ; End of message, restart
    JSR lcd_data
    TXA
    SEC
    SBC Y
    TAX                   ; Restore X
    
    INY
    CPY #16               ; 16 characters displayed?
    BNE print_window
    
    ; Delay before scrolling
    JSR delay_long
    JSR delay_long
    JSR delay_long
    
    ; Advance start position
    INX
    JMP scroll_loop

reset_scroll:
    LDX #$00
    JMP scroll_loop

message:
    .byte "Welcome to the W65C02 computer! ", $00

; (Include lcd_init and delay routines here)

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```

## Experiments

### Experiment 1: Cursor Styles

Try different display control commands:

```asm
LDA #$0C              ; No cursor
JSR lcd_command

LDA #$0E              ; Underline cursor
JSR lcd_command

LDA #$0F              ; Blinking block cursor
JSR lcd_command
```

### Experiment 2: Display Shifting

Shift the entire display left or right:

```asm
; Shift display left
LDA #$18
JSR lcd_command

; Shift display right
LDA #$1C
JSR lcd_command
```

### Experiment 3: Progress Bar

Create a progress bar using custom characters:

```asm
; Define progress bar characters (empty, 1/4, 2/4, 3/4, full)
; Character 0: empty      [     ]
; Character 1: 1/4 full   [█    ]
; Character 2: 2/4 full   [██   ]
; Character 3: 3/4 full   [███  ]
; Character 4: full       [█████]
```

## Exercises

**Exercise 1:** Create a 2-line display showing current time (HH:MM:SS) that updates every second using VIA Timer 1.

**Exercise 2:** Build a text editor - use buttons to select characters and write them to LCD. Include backspace function.

**Exercise 3:** Create an animated character that walks across the screen using custom characters for different walking poses.

<details>
<summary>Solution to Exercise 3</summary>

```asm
.segment "CODE"
.org $8000

main_program:
    JSR lcd_init
    JSR create_walk_chars
    
    ; Walk across screen
    LDX #$00              ; Position

walk_loop:
    ; Set cursor position
    TXA
    ORA #$80
    JSR lcd_command
    
    ; Display walking animation
    LDA #$00              ; Frame 1
    JSR lcd_data
    JSR delay_long
    
    ; Erase
    TXA
    ORA #$80
    JSR lcd_command
    LDA #' '
    JSR lcd_data
    
    ; Next position
    INX
    CPX #16
    BNE walk_loop
    
    ; Reset
    LDX #$00
    JMP walk_loop

create_walk_chars:
    ; Character 0: Walking frame 1
    LDA #$40              ; CGRAM address
    JSR lcd_command
    
    LDA #%00100           ; Head
    JSR lcd_data
    LDA #%00100           ; Body
    JSR lcd_data
    LDA #%01110           ; Arms
    JSR lcd_data
    LDA #%00100           ; Body
    JSR lcd_data
    LDA #%00100           ; Body
    JSR lcd_data
    LDA #%01010           ; Legs
    JSR lcd_data
    LDA #%10001           ; Feet
    JSR lcd_data
    LDA #%00000
    JSR lcd_data
    
    ; Add more walking frames...
    
    RTS

; (Include lcd_init, lcd_command, lcd_data, delays)

.segment "VECTORS"
.org $FFFC
.word reset
.word $0000
```
</details>

## Deep Dive: LCD Timing

The HD44780 has specific timing requirements:

### Enable Pulse Width

```
E high time:  ≥ 230ns (1 cycle at 4MHz = 250ns ✓)
E cycle time: ≥ 500ns (2 cycles at 4MHz = 500ns ✓)
```

At 1MHz 6502, our code is slow enough! At higher speeds, add NOPs:

```asm
ORA #LCD_E
STA PORTA
NOP                   ; Ensure E high time
NOP
AND #(~LCD_E)
STA PORTA
```

### Command Execution Times

```
Clear display:       1.52ms
Return home:         1.52ms
All other commands:  37μs
Data write:          37μs
```

Our delay routines must meet these minimums.

### Busy Flag

Instead of delays, you can check the busy flag:

```asm
; Read busy flag (DB7) via Port A
; Must configure PA7-PA4 as inputs!
lcd_wait:
    LDA #$0F              ; Low nibble output, high input
    STA DDRA
    
check_busy:
    LDA #LCD_RW           ; RS=0, RW=1 (read command)
    STA PORTA
    ORA #LCD_E            ; E high
    STA PORTA
    LDA PORTA             ; Read high nibble
    PHA
    LDA #LCD_RW           ; E low
    STA PORTA
    
    ; Read low nibble (required but not used)
    LDA #LCD_RW
    ORA #LCD_E
    STA PORTA
    LDA #LCD_RW
    STA PORTA
    
    PLA                   ; Get high nibble
    AND #%10000000        ; Check DB7 (busy flag)
    BNE check_busy        ; Loop if busy
    
    LDA #$FF              ; Restore outputs
    STA DDRA
    RTS
```

This is more efficient but complex. Delays are simpler!

## Deep Dive: 8-Bit Mode

8-bit mode uses all data pins but requires only one write per byte:

```asm
; 8-bit mode connections:
; DB0-DB7 → PA0-PA7 (or PB0-PB7)
; RS → different pin
; E  → different pin

lcd_command_8bit:
    STA PORTB             ; Data on Port B
    LDA #LCD_E            ; Control on Port A
    STA PORTA             ; E high
    LDA #$00
    STA PORTA             ; E low
    RTS
```

**Advantages:**
- Simpler code (one write)
- Slightly faster

**Disadvantages:**
- Uses 8 pins instead of 4
- Initialization similar complexity

For breadboard projects, 4-bit mode is preferred!

## Real Hardware: Connection Tips

### Contrast Adjustment

Connect a 10kΩ potentiometer:
```
VDD (pin 2) ─── Pot ─── VSS (pin 1)
                 │
                 └─── V0 (pin 3)
```

Adjust pot until characters visible.

### Backlight

Most LCDs have LED backlight:
```
+5V ─── 220Ω resistor ─── A (pin 15)
GND ──────────────────── K (pin 16)
```

### Pull-ups

If reading from LCD (using R/W̅), add pull-up resistors (4.7kΩ) on DB7-DB4.

## Common Errors

### No display
**Check:**
- Power (VDD, VSS)
- Contrast (adjust pot)
- Enable signal toggling
- Initialization sequence correct
- Delays long enough

### Garbage characters
**Check:**
- Timing (E pulse width)
- 4-bit vs 8-bit mode match
- Proper nibble order
- Connection to correct pins

### Characters in wrong position
**Check:**
- DDRAM address calculation
- Line 2 starts at 0x40, not 0x10!
- Cursor position command (0x80 + address)

## Key Takeaways

✅ **HD44780** is standard character LCD controller

✅ **4-bit mode** saves pins with minimal code complexity

✅ **Initialization sequence** is critical - follow it exactly!

✅ **RS bit** selects command (0) or data (1)

✅ **E signal** falling edge triggers read/write

✅ **DDRAM addresses** not linear - Line 2 starts at 0x40

✅ **Custom characters** enable graphics and symbols

✅ **Delays** required between commands

## Next Lesson

Ready to respond to events? Continue to:
**[Lesson 14: Interrupts - Event-Driven Programming →](../14-interrupts/)**

Learn how to handle asynchronous events with interrupts!

---

## Quick Reference

**Key Commands:**
```asm
0x01          ; Clear display
0x02          ; Return home
0x06          ; Entry mode: increment, no shift
0x0C          ; Display on, cursor off
0x0E          ; Display on, cursor on
0x0F          ; Display on, cursor blink
0x28          ; 4-bit, 2-line, 5×8 font
0x38          ; 8-bit, 2-line, 5×8 font
0x80 | addr   ; Set DDRAM address (cursor position)
0x40 | addr   ; Set CGRAM address (custom character)
```

**Set Cursor Position:**
```asm
; Line 1, column 0
LDA #$80
JSR lcd_command

; Line 2, column 5
LDA #$C5              ; 0x80 | (0x40 + 5)
JSR lcd_command
```

**Display String:**
```asm
print_string:
    LDX #$00
loop:
    LDA string,X
    BEQ done
    JSR lcd_data
    INX
    JMP loop
done:
    RTS
```

---

*Text display unlocked!* 📺
