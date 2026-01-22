# Stage 3: Add LCD Display (HD44780)

## 🎯 Goal

Add visual output to your computer with a character LCD display. By the end of this stage, you'll have:
- A 16x2 character LCD connected to your computer
- Assembly language routines for LCD control
- The ability to display text, numbers, and custom characters
- A complete interactive system!

**Time Required:** 3-4 hours  
**Difficulty:** Intermediate to Advanced

---

## 📋 What You'll Need

In addition to your Stage 2 circuit:
- [ ] 16x2 LCD module (HD44780 compatible)
- [ ] 10kΩ potentiometer (contrast adjustment)
- [ ] Additional breadboard space or third breadboard
- [ ] 220Ω resistor (for backlight, if needed)
- [ ] More jumper wires
- [ ] Patience for software debugging!

---

## 📺 Understanding the HD44780 LCD Controller

### What is the HD44780?

The HD44780 is a character LCD controller chip found in most 16x2 and 20x4 displays. It:
- Handles all the low-level LCD timing
- Stores characters in display RAM (DDRAM)
- Includes a built-in character set (ASCII + Japanese katakana)
- Accepts commands and data through a parallel interface

### LCD Module Specifications

**Physical:**
- 16 characters per line, 2 lines
- 5x8 pixel characters
- Built-in LED backlight
- Viewing angle: ~60°

**Electrical:**
- 5V power supply (VDD)
- Adjustable contrast (0-5V on VO pin)
- 4-bit or 8-bit data interface
- Multiple control signals

**Memory Organization:**
```
Display Position    DDRAM Address
Line 1: [0-15]      $00-$0F
Line 2: [0-15]      $40-$4F

Example:
  Position (0,0) = Address $00
  Position (15,0) = Address $0F
  Position (0,1) = Address $40
  Position (15,1) = Address $4F
```

---

## 🔌 HD44780 LCD Pinout

16-pin header on the LCD module:

```
Pin | Name | Function              | Connection
----+------+----------------------+------------------
 1  | VSS  | Ground               | GND
 2  | VDD  | +5V Power            | +5V
 3  | VO   | Contrast Adjust      | Potentiometer wiper
 4  | RS   | Register Select      | Address decode
 5  | R/W  | Read/Write           | CPU R/W or GND
 6  | E    | Enable               | Address decode
 7  | DB0  | Data Bit 0           | Not used (4-bit mode)
 8  | DB1  | Data Bit 1           | Not used (4-bit mode)
 9  | DB2  | Data Bit 2           | Not used (4-bit mode)
10  | DB3  | Data Bit 3           | Not used (4-bit mode)
11  | DB4  | Data Bit 4           | D0 or D4 (CPU data bus)
12  | DB5  | Data Bit 5           | D1 or D5 (CPU data bus)
13  | DB6  | Data Bit 6           | D2 or D6 (CPU data bus)
14  | DB7  | Data Bit 7           | D3 or D7 (CPU data bus)
15  | A    | Backlight Anode (+)  | +5V via 220Ω
16  | K    | Backlight Cathode(-) | GND
```

### Control Signals Explained

**RS (Register Select) - Pin 4:**
- RS = 0: Command mode (write instructions to LCD)
- RS = 1: Data mode (write characters to display)

**R/W (Read/Write) - Pin 5:**
- R/W = 0: Write to LCD
- R/W = 1: Read from LCD (check busy flag, read data)
- **For simplicity, we'll tie this to ground (write-only)**

**E (Enable) - Pin 6:**
- Data is latched on the falling edge of E
- Must be HIGH for at least 450ns
- LCD reads data when E goes from HIGH to LOW

---

## 🧠 4-Bit vs 8-Bit Interface Mode

The HD44780 supports two interface modes:

### 8-Bit Mode
- Uses all 8 data lines (DB0-DB7)
- Sends one byte per operation
- Faster, simpler in software
- **Costs 8 I/O pins**

### 4-Bit Mode (We'll use this!)
- Uses only 4 data lines (DB4-DB7)
- Sends high nibble first, then low nibble
- Slightly slower, more complex software
- **Saves 4 precious I/O pins!**

**Why 4-bit mode?**
- The 6502 has limited I/O capability
- We can use the upper 4 bits of the data bus
- Saves address space for other peripherals
- Industry standard for small systems

---

## 🗺️ Memory-Mapped LCD Interface

We'll connect the LCD to a specific memory address range. When the CPU writes to these addresses, it controls the LCD.

**Proposed Memory Map:**

```
$0000-$7FFF: RAM (32KB)
$8000-$8001: LCD Control (2 addresses)
  $8000: LCD Data (RS=1)  - Write characters here
  $8001: LCD Command (RS=0) - Write commands here
$8002-$FFFF: ROM
```

**Wait, ROM was at $8000!** We need to adjust our memory map:

### Revised Memory Map

```
$0000-$3FFF: RAM (16KB)
$4000-$4001: LCD (2 bytes)
  $4000: LCD Data (RS=1)
  $4001: LCD Command (RS=0)
$4002-$5FFF: Unused (could add more I/O)
$6000-$7FFF: RAM (8KB) - Optional, or leave unused
$8000-$FFFF: ROM (32KB)
```

**Simpler Alternative - Use $6000:**

```
$0000-$5FFF: RAM (24KB)
$6000-$6001: LCD
  $6000: LCD Command (RS=0)
  $6001: LCD Data (RS=1)
$6002-$7FFF: Unused
$8000-$FFFF: ROM (32KB)
```

**We'll use $6000-$6001** - easy to remember and decode!

---

## 🔧 Address Decoding for LCD

We need to generate the Enable (E) signal when CPU accesses $6000-$6001.

### Required Logic

**LCD Enable (E) should be HIGH when:**
- A15 = 0 (not ROM)
- A14 = 1
- A13 = 1  
- A12 = 0
- A11 = 0
- A10 = 0
- A9-A1 = 0
- Address = $6000 or $6001

**Register Select (RS):**
- RS = 0 when address = $6000 (Command)
- RS = 1 when address = $6001 (Data)
- RS = A0 (the lowest address bit!)

### Simplified Decoding

Actually check for address range $6000-$7FFF and use A0 for RS:

```
Enable when: A15=0, A14=1, A13=1 (addresses $6000-$7FFF)
RS = A0
```

**Using 74HC00 NAND gates:**

Gate 1: Check A14 AND A13
Gate 2: Check result AND NOT(A15)
Gate 3: AND result with Φ2 (clock)
Output: Enable signal to LCD

---

## 🔧 Step-by-Step Build Instructions

### Step 1: Position the LCD

**Physical Layout:**
1. Place LCD module on breadboard or third board
2. If LCD has no header pins, solder a 16-pin header
3. Orient LCD so you can read the display
4. Position close to main circuit (minimize wire length)

**Power test:**
```
LCD Pin 1 (VSS) → Ground
LCD Pin 2 (VDD) → +5V
LCD Pin 3 (VO) → Ground (temporarily, for full contrast)
```

**Apply power** - You should see:
- Backlight illuminates (if present)
- Top row of blocks (full contrast) or blank (no contrast)
- If you see squares, LCD has power but needs initialization

**Remove power** before continuing.

---

### Step 2: Contrast Control Circuit

The contrast pin (VO) needs 0-5V for contrast adjustment.

**Wiring:**
```
+5V → 10kΩ Potentiometer Pin 1
Potentiometer Pin 2 (wiper) → LCD Pin 3 (VO)
Potentiometer Pin 3 → Ground
```

This creates a voltage divider: 0V (full contrast) to 5V (no contrast).

**Typical setting:** About 0.5-1V for good contrast.

---

### Step 3: Connect Data Bus (4-bit mode)

We'll use the **upper 4 bits** of the CPU data bus (D4-D7):

| CPU Pin | Signal | LCD Pin | LCD Signal |
|---------|--------|---------|------------|
| 29 | D4 | 11 | DB4 |
| 28 | D5 | 12 | DB5 |
| 27 | D6 | 13 | DB6 |
| 26 | D7 | 14 | DB7 |

**Wiring:**
```
CPU Pin 29 (D4) → LCD Pin 11 (DB4)
CPU Pin 28 (D5) → LCD Pin 12 (DB5)
CPU Pin 27 (D6) → LCD Pin 13 (DB6)
CPU Pin 26 (D7) → LCD Pin 14 (DB7)
```

**Lower bits DB0-DB3 (LCD pins 7-10):** Leave unconnected.

---

### Step 4: Build Address Decoder for LCD

**Goal:** Generate Enable (E) signal when accessing $6000-$6001.

**Simple version using NAND gates:**

We need to detect: A15=0, A14=1, A13=1

**Using 74HC00:**

```
Gate 3:
  Pin 9 (3A) ← A14 (CPU pin 24)
  Pin 10 (3B) ← A13 (CPU pin 23)
  Pin 8 (3Y) → Intermediate signal (A14 AND A13)

Gate 4:
  Pin 12 (4A) ← Pin 8 (output from Gate 3)
  Pin 13 (4B) ← NOT(A15) = invert A15
  Pin 11 (4Y) → Preliminary Enable

Final AND with Φ2 (clock):
  Need another gate to AND with Φ2
  Or use 74HC08 (AND gate)
```

**Simpler approach - Use 74HC138 decoder (recommended):**

If you have a 74HC138 3-to-8 decoder:
```
Inputs: A13, A14, A15
Output: Active LOW for $6000-$7FFF range
```

**For now, let's use a simple manual approach:**

Connect LCD Enable directly to an address line for testing:
```
LCD Pin 6 (E) ← Via 74HC08 AND gate ← A14 AND Φ2
```

This isn't perfect but lets us test the LCD.

---

### Step 5: Connect Control Signals

**Register Select (RS):**
```
LCD Pin 4 (RS) ← CPU Pin 9 (A0)
```

When address is $6000 (A0=0): RS=0 (Command mode)
When address is $6001 (A0=1): RS=1 (Data mode)

**Read/Write (R/W):**

**Simple version - Write-only:**
```
LCD Pin 5 (R/W) → Ground
```

This puts LCD in permanent write mode. We won't read the busy flag (we'll use delays instead).

**Better version - Connect to CPU:**
```
LCD Pin 5 (R/W) ← CPU Pin 34 (R/W)
```

Allows reading busy flag, but requires more complex software.

**Enable (E):**

For now, simple test connection:
```
LCD Pin 6 (E) ← Manual connection to test
```

We'll refine this after basic testing.

---

### Step 6: Backlight Connection

**If LCD has backlight (pins 15 and 16):**

```
+5V → 220Ω resistor → LCD Pin 15 (A, anode)
LCD Pin 16 (K, cathode) → Ground
```

**Why 220Ω?** Limits current to ~20mA, safe for LED backlight.

**Some LCDs have built-in current limiting** - check datasheet! May not need resistor.

---

### Step 7: Complete Wiring Checklist

**LCD Power:**
- [ ] Pin 1 (VSS) → Ground
- [ ] Pin 2 (VDD) → +5V
- [ ] Pin 3 (VO) → 10kΩ pot wiper

**LCD Control:**
- [ ] Pin 4 (RS) → CPU A0 (pin 9)
- [ ] Pin 5 (R/W) → Ground (or CPU R/W)
- [ ] Pin 6 (E) → Address decoder output

**LCD Data (4-bit mode):**
- [ ] Pin 11 (DB4) → CPU D4 (pin 29)
- [ ] Pin 12 (DB5) → CPU D5 (pin 28)
- [ ] Pin 13 (DB6) → CPU D6 (pin 27)
- [ ] Pin 14 (DB7) → CPU D7 (pin 26)

**LCD Backlight:**
- [ ] Pin 15 (A) → +5V via 220Ω
- [ ] Pin 16 (K) → Ground

**Potentiometer:**
- [ ] One end → +5V
- [ ] Wiper → LCD pin 3
- [ ] Other end → Ground

---

## 💻 LCD Initialization Sequence

The HD44780 must be initialized after power-on. This is tricky in 4-bit mode!

### Why Initialization is Complex

**Problem:** LCD doesn't know if you're using 4-bit or 8-bit mode at startup!

**Solution:** Special initialization sequence that works regardless:

1. Wait >40ms after power-on (LCD internal reset)
2. Send $03 three times (in 8-bit mode timing)
3. Send $02 (switch to 4-bit mode)
4. Now LCD knows it's 4-bit mode!
5. Send configuration commands (in 4-bit mode)

### Initialization Code

```assembly
; LCD initialization for 4-bit mode
; Assumes LCD at $6000 (command) and $6001 (data)

LCD_CMD = $6000    ; LCD command register (RS=0)
LCD_DAT = $6001    ; LCD data register (RS=1)

lcd_init:
    ; Wait >40ms for LCD power-on reset
    LDX #$FF
wait_40ms:
    LDY #$FF
delay1:
    DEY
    BNE delay1
    DEX
    BNE wait_40ms
    
    ; Send $03 (Function Set) - 8-bit mode
    ; In 8-bit mode, just write high nibble
    LDA #$03
    STA LCD_CMD
    
    JSR lcd_delay_5ms   ; Wait >4.1ms
    
    ; Send $03 again
    LDA #$03
    STA LCD_CMD
    
    JSR lcd_delay_150us ; Wait >100us
    
    ; Send $03 one more time
    LDA #$03
    STA LCD_CMD
    
    JSR lcd_delay_150us
    
    ; Send $02 to switch to 4-bit mode
    LDA #$02
    STA LCD_CMD
    
    JSR lcd_delay_150us
    
    ; Now in 4-bit mode - send commands as two nibbles
    
    ; Function Set: 4-bit mode, 2 lines, 5x8 font
    LDA #$28           ; 0010 1000
    JSR lcd_command
    
    ; Display ON, Cursor OFF, Blink OFF
    LDA #$0C           ; 0000 1100
    JSR lcd_command
    
    ; Clear Display
    LDA #$01           ; 0000 0001
    JSR lcd_command
    JSR lcd_delay_5ms  ; Clear needs 1.52ms
    
    ; Entry Mode: Increment cursor, no shift
    LDA #$06           ; 0000 0110
    JSR lcd_command
    
    RTS

; Send command to LCD (4-bit mode)
lcd_command:
    PHA                ; Save A
    
    ; Send high nibble
    LSR A              ; Shift high nibble into low position
    LSR A
    LSR A
    LSR A
    STA LCD_CMD        ; Write to LCD
    JSR lcd_delay_1ms
    
    ; Send low nibble
    PLA                ; Restore A
    PHA
    AND #$0F           ; Mask low nibble
    STA LCD_CMD        ; Write to LCD
    JSR lcd_delay_1ms
    
    PLA                ; Restore stack
    RTS

; Send data (character) to LCD
lcd_data:
    PHA                ; Save A
    
    ; Send high nibble
    LSR A
    LSR A
    LSR A
    LSR A
    STA LCD_DAT        ; Write to LCD data register
    JSR lcd_delay_1ms
    
    ; Send low nibble
    PLA                ; Restore A
    PHA
    AND #$0F
    STA LCD_DAT
    JSR lcd_delay_1ms
    
    PLA
    RTS

; Delay routines
lcd_delay_1ms:
    ; At 1 MHz clock: 1000 cycles = 1ms
    PHA
    LDA #$04           ; Outer loop
delay_1ms_outer:
    LDY #$FA           ; Inner loop (250 * 4 = 1000 cycles)
delay_1ms_inner:
    DEY
    BNE delay_1ms_inner
    SEC
    SBC #$01
    BNE delay_1ms_outer
    PLA
    RTS

lcd_delay_5ms:
    JSR lcd_delay_1ms
    JSR lcd_delay_1ms
    JSR lcd_delay_1ms
    JSR lcd_delay_1ms
    JSR lcd_delay_1ms
    RTS

lcd_delay_150us:
    ; Simplified - just call 1ms (overkill but safe)
    JSR lcd_delay_1ms
    RTS
```

---

## 📝 Displaying Text

### Hello World Program

```assembly
.org $8000

reset:
    JSR lcd_init       ; Initialize LCD
    
    ; Display "Hello, World!"
    LDX #$00           ; String index
print_hello:
    LDA hello_text, X  ; Load character
    BEQ done           ; If zero, done
    JSR lcd_data       ; Display character
    INX
    JMP print_hello
    
done:
    JMP done           ; Infinite loop

hello_text:
    .byte "Hello, World!", $00

; Include all LCD routines from above
lcd_init:
    ; ... (initialization code) ...
lcd_command:
    ; ... (command sending code) ...
lcd_data:
    ; ... (data sending code) ...

; Reset vector
.org $FFFC
.word reset
.word $0000
```

### Moving Cursor

```assembly
; Set cursor position
; A = position (0-15 for line 1, 64-79 for line 2)
lcd_set_position:
    ORA #$80           ; Set DDRAM address command
    JSR lcd_command
    RTS

; Example: Write to position 5 on line 1
    LDA #$05           ; Position 5
    JSR lcd_set_position
    LDA #'X'
    JSR lcd_data       ; Display 'X' at position 5

; Example: Write to position 0 on line 2
    LDA #$40           ; Position 0 of line 2 (address $40)
    JSR lcd_set_position
    LDA #'Y'
    JSR lcd_data       ; Display 'Y' on line 2
```

### Clearing Display

```assembly
lcd_clear:
    LDA #$01           ; Clear display command
    JSR lcd_command
    JSR lcd_delay_5ms  ; Wait for clear to complete
    RTS
```

---

## 🎨 Advanced LCD Features

### Custom Characters

The HD44780 supports 8 custom characters (5x8 pixels each).

**Creating a Heart Symbol:**

```assembly
; Define heart character in CGRAM
lcd_create_heart:
    ; Set CGRAM address to character 0
    LDA #$40           ; CGRAM address for char 0
    JSR lcd_command
    
    ; Send 8 bytes (each byte = one row)
    LDA #%00000        ; Row 1: .....
    JSR lcd_data
    LDA #%01010        ; Row 2: .*.*.
    JSR lcd_data
    LDA #%11111        ; Row 3: *****
    JSR lcd_data
    LDA #%11111        ; Row 4: *****
    JSR lcd_data
    LDA #%01110        ; Row 5: .***
    JSR lcd_data
    LDA #%00100        ; Row 6: ..*..
    JSR lcd_data
    LDA #%00000        ; Row 7: .....
    JSR lcd_data
    LDA #%00000        ; Row 8: .....
    JSR lcd_data
    
    RTS

; Display the custom character
    JSR lcd_create_heart
    LDA #$00           ; Character code 0
    JSR lcd_data       ; Display heart!
```

### Number Display

```assembly
; Display a byte as decimal (0-255)
; A = number to display
lcd_print_decimal:
    PHA                ; Save number
    
    ; Extract hundreds digit
    LDX #$00           ; Hundreds counter
count_hundreds:
    CMP #100
    BCC print_hundreds
    SBC #100
    INX
    JMP count_hundreds
print_hundreds:
    TXA
    CLC
    ADC #'0'           ; Convert to ASCII
    JSR lcd_data
    
    ; Extract tens digit
    PLA
    PHA
    LDX #$00           ; Tens counter
count_tens:
    CMP #10
    BCC print_tens
    SBC #10
    INX
    JMP count_tens
print_tens:
    TXA
    CLC
    ADC #'0'
    JSR lcd_data
    
    ; Extract ones digit
    PLA
    CLC
    ADC #'0'
    JSR lcd_data
    
    RTS
```

### Scrolling Text

```assembly
; Scroll display left
lcd_scroll_left:
    LDA #$18           ; Shift display left command
    JSR lcd_command
    RTS

; Scroll display right  
lcd_scroll_right:
    LDA #$1C           ; Shift display right command
    JSR lcd_command
    RTS

; Scrolling marquee example
scroll_demo:
    LDX #$10           ; Scroll 16 positions
scroll_loop:
    JSR lcd_scroll_left
    JSR lcd_delay_5ms  ; Delay between scrolls
    JSR lcd_delay_5ms
    JSR lcd_delay_5ms
    JSR lcd_delay_5ms
    JSR lcd_delay_5ms
    DEX
    BNE scroll_loop
    RTS
```

---

## 🔍 Troubleshooting

### Problem: LCD shows nothing (blank screen)

**Check:**
1. **Power:**
   - Measure pin 2 (VDD) = 5V
   - Measure pin 1 (VSS) = 0V
   - Check power connections

2. **Backlight:**
   - Should be lit (if present)
   - Check pin 15/16 connections
   - Try different resistor value

3. **Contrast:**
   - Adjust potentiometer slowly
   - Should see blocks appear/disappear
   - Try extremes: full clockwise, then counter-clockwise

### Problem: LCD shows black blocks (all pixels on)

**This means:**
- LCD has power ✓
- Contrast is set ✓
- LCD is NOT initialized properly

**Check:**
1. **Initialization code:**
   - Verify delays are long enough
   - Check initialization sequence
   - Make sure power-on delay is adequate (>40ms)

2. **Enable signal:**
   - Must pulse HIGH then LOW
   - Check with oscilloscope or logic analyzer
   - Verify address decoder works

### Problem: Random characters or garbage

**Likely causes:**

1. **Noise/interference:**
   - Add decoupling capacitors near LCD power pins
   - Shorten wire connections
   - Check ground connections

2. **Wrong nibble order:**
   - High nibble must be sent before low nibble
   - Check your lcd_command/lcd_data routines

3. **Timing issues:**
   - Delays may be too short
   - Increase delay values and test

### Problem: Some characters display, others don't

**Check:**
1. **Data bus connections:**
   - Verify D4-D7 connected to DB4-DB7
   - One wrong wire causes bit errors
   - Test with simple patterns (0x0F, 0xF0, 0xAA, 0x55)

2. **Address decoder:**
   - Make sure Enable (E) pulses correctly
   - Check RS signal toggles between command/data

### Problem: Cursor visible but no characters

**Check:**
1. **RS signal:**
   - Should be LOW for commands, HIGH for data
   - Verify connection to A0
   - Check with multimeter or logic probe

2. **Character codes:**
   - Make sure sending valid ASCII (0x20-0x7E)
   - Try simple test: LDA #'A', JSR lcd_data

---

## 🎓 Understanding LCD Commands

### Common LCD Commands

| Command | Code | Description |
|---------|------|-------------|
| Clear Display | $01 | Clears screen, cursor to home |
| Return Home | $02 | Cursor to position 0, no clear |
| Entry Mode Set | $04-$07 | Set cursor move direction |
| Display ON/OFF | $08-$0F | Control display/cursor/blink |
| Cursor/Display Shift | $10-$1F | Move cursor or scroll display |
| Function Set | $20-$3F | Set interface, lines, font |
| Set CGRAM Address | $40-$7F | Set custom character address |
| Set DDRAM Address | $80-$FF | Set cursor position |

### Entry Mode ($04-$07)

```
Bit:  0  0  0  0  0  1  I/D S
                       │   └─ Shift display
                       └───── Increment/Decrement cursor

Common values:
$04: Decrement cursor, no shift
$05: Decrement cursor, shift display
$06: Increment cursor, no shift (most common)
$07: Increment cursor, shift display
```

### Display Control ($08-$0F)

```
Bit:  0  0  0  0  1  D  C  B
                    │  │  └─ Blink cursor
                    │  └──── Show cursor
                    └─────── Display ON

Common values:
$08: Display OFF, cursor OFF, blink OFF
$0C: Display ON, cursor OFF, blink OFF (most common)
$0E: Display ON, cursor ON, blink OFF
$0F: Display ON, cursor ON, blink ON
```

### Function Set ($20-$3F)

```
Bit:  0  0  1  DL N  F  *  *
                │  │  │
                │  │  └───── Font (0=5x8, 1=5x10)
                │  └──────── Lines (0=1 line, 1=2 lines)
                └─────────── Data Length (0=4-bit, 1=8-bit)

Common values:
$20: 4-bit, 1 line, 5x8 font
$28: 4-bit, 2 lines, 5x8 font (most common)
$30: 8-bit, 1 line, 5x8 font
$38: 8-bit, 2 lines, 5x8 font
```

---

## ✅ Success Criteria

Stage 3 complete when:
- ✅ LCD powers on with proper contrast
- ✅ Initialization completes without errors
- ✅ "Hello, World!" displays correctly
- ✅ Can write to both lines of display
- ✅ Characters are clear and readable
- ✅ Cursor positioning works
- ✅ Can clear display and write new text

---

## 🎯 Next Steps and Projects

Congratulations! You now have a fully functional 8-bit computer with visual output!

### Suggested Projects

1. **Calculator:**
   - Add push buttons for digits (0-9)
   - Implement basic math (+, -, *, /)
   - Display results on LCD

2. **Clock/Timer:**
   - Use timer interrupts (if you add a timer chip)
   - Display hours:minutes:seconds
   - Countdown timer

3. **Memory Viewer:**
   - Display RAM contents in hex
   - Scroll through memory with buttons
   - Useful for debugging!

4. **Interactive Menu:**
   - Multiple screens/modes
   - Button navigation
   - Settings and options

5. **Games:**
   - Guess the number
   - Simon Says
   - Simple text adventures

### Hardware Enhancements

- **Add serial port (6551 ACIA)** - Communicate with PC
- **Add VIA (6522)** - More I/O pins for keyboard, gamepad
- **Add sound (AY-3-8910)** - Music and sound effects
- **Add SD card interface** - Load programs from storage
- **Build PCB version** - Make it permanent!

---

## 📝 Quick Reference

### LCD Address Map
```
$6000: Command Register (RS=0)
$6001: Data Register (RS=1)
```

### Common Operations
```assembly
; Initialize LCD
JSR lcd_init

; Clear screen
LDA #$01
JSR lcd_command

; Write character
LDA #'A'
JSR lcd_data

; Set cursor to line 2
LDA #$40
JSR lcd_set_position

; Display string
LDX #$00
loop:
    LDA text, X
    BEQ done
    JSR lcd_data
    INX
    JMP loop
done:
```

### Pin Connections Summary
```
LCD Power:    Pin 1=GND, Pin 2=+5V
Contrast:     Pin 3=Pot wiper
Control:      Pin 4=A0, Pin 5=GND, Pin 6=Enable
Data:         Pins 11-14 = D4-D7
Backlight:    Pin 15=+5V (via 220Ω), Pin 16=GND
```

---

## 🎉 Congratulations!

You've built a complete 8-bit computer from scratch! You now understand:
- CPU architecture and operation
- Memory interfacing and address decoding
- Memory-mapped I/O
- LCD control and initialization
- Assembly language programming
- Hardware debugging techniques

**This is a significant achievement!** You've mastered concepts that many computer science students never experience hands-on.

**Keep learning:**
- Experiment with different programs
- Add more peripherals
- Learn about interrupts and timers
- Explore other 8-bit systems (Z80, 6809)
- Share your project online!

---

*Stage 3 Complete! Your W65C02 Computer is DONE!* 🚀🎉

*Happy hacking!* 💻✨
