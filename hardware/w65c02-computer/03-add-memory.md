# Stage 2: Add Memory (RAM + ROM + Address Decoding)

## 🎯 Goal

Transform your basic CPU into a real computer by adding memory. By the end of this stage, you'll have:
- 32KB of RAM for variables and stack
- 32KB of ROM for program storage
- Address decoding logic to select RAM or ROM
- The ability to program and run real assembly code
- A programmable computer!

**Time Required:** 4-6 hours  
**Difficulty:** Intermediate

---

## 📋 What You'll Need

In addition to your Stage 1 circuit:
- [ ] AS6C62256 32KB SRAM chip (DIP-28)
- [ ] AT28C256 32KB EEPROM chip (DIP-28)
- [ ] 74HC00 Quad NAND gate (DIP-14)
- [ ] 2x 28-pin DIP sockets
- [ ] 1x 14-pin DIP socket
- [ ] 2x 0.1μF ceramic capacitors
- [ ] Additional breadboard (recommended)
- [ ] More jumper wires
- [ ] EEPROM programmer (Arduino-based or TL866)

---

## 🗺️ Memory Map Planning

Before building, understand where everything lives in memory:

```
$0000 ┌──────────────────────┐
      │                      │
      │      RAM (32KB)      │  Read/Write
      │                      │  Variables, Stack, Workspace
      │   AS6C62256 SRAM    │
$7FFF └──────────────────────┘
$8000 ┌──────────────────────┐
      │                      │
      │      ROM (32KB)      │  Read-Only
      │                      │  Program Code
      │   AT28C256 EEPROM   │
$FFFF └──────────────────────┘
```

**Why This Layout:**
- **RAM at $0000-$7FFF** (A15 = 0): Fast access for frequently used data
- **ROM at $8000-$FFFF** (A15 = 1): Contains program and reset vectors
- **Simple decoding:** Just look at address line A15!
  - A15 = 0 → Select RAM
  - A15 = 1 → Select ROM

**Critical:** The 6502 expects vectors at the TOP of memory:
- $FFFC-$FFFD: Reset vector (where CPU starts after reset)
- $FFFA-$FFFB: NMI vector (non-maskable interrupt)
- $FFFE-$FFFF: IRQ vector (interrupt request)

These MUST be in ROM, which is why ROM is at the high addresses.

---

## 🔌 AS6C62256 SRAM Pinout

32KB Static RAM chip (28-pin DIP):

```
         AS6C62256
       +----\/----+
  A14 1|          |28 VCC (+5V)
  A12 2|          |27 /WE (Write Enable)
   A7 3|          |26 A13
   A6 4|          |25 A8
   A5 5|          |24 A9
   A4 6|          |23 A11
   A3 7|          |22 /OE (Output Enable)
   A2 8|          |21 A10
   A1 9|          |20 /CE (Chip Enable)
   A0 10|         |19 D7
   D0 11|         |18 D6
   D1 12|         |17 D5
   D2 13|         |16 D4
  GND 14|         |15 D3
       +----------+
```

**Key Signals:**
- **A0-A14** (15 address lines): 32KB = 2^15 addresses
- **D0-D7** (8 data lines): Byte-wide memory
- **/CE (Chip Enable)**: Must be LOW to activate chip
- **/OE (Output Enable)**: Must be LOW to read data
- **/WE (Write Enable)**: Must be LOW to write data
- **All signals are active LOW** (enabled when 0V)

---

## 🔌 AT28C256 EEPROM Pinout

32KB Electrically Erasable ROM (28-pin DIP):

```
        AT28C256
       +----\/----+
  A14 1|          |28 VCC (+5V)
  A12 2|          |27 /WE (Write Enable)
   A7 3|          |26 A13
   A6 4|          |25 A8
   A5 5|          |24 A9
   A4 6|          |23 A11
   A3 7|          |22 /OE (Output Enable)
   A2 8|          |21 A10
   A1 9|          |20 /CE (Chip Enable)
   A0 10|         |19 D7
   D0 11|         |18 D6
   D1 12|         |17 D5
   D2 13|         |16 D4
  GND 14|         |15 D3
       +----------+
```

**Notice:** Pinout is IDENTICAL to SRAM! This makes wiring easier.

**Key Differences from SRAM:**
- **Read-only in normal operation** (/WE not connected during runtime)
- **Must be programmed** with special hardware before installation
- **Non-volatile** - keeps data without power
- **Slower** - 150ns access time vs 55ns for SRAM

---

## 🔌 74HC00 Quad NAND Gate Pinout

4 independent NAND gates in one chip (14-pin DIP):

```
        74HC00
      +----\/----+
1A  1 |          | 14 VCC (+5V)
1B  2 |          | 13 4B
1Y  3 |          | 12 4A
2A  4 |          | 11 4Y
2B  5 |          | 10 3B
2Y  6 |          |  9 3A
GND 7 |          |  8 3Y
      +----------+
```

**NAND Truth Table:**
```
A  B | Y
-----+---
0  0 | 1
0  1 | 1
1  0 | 1
1  1 | 0
```

Output is LOW only when BOTH inputs are HIGH.

---

## 🧠 Address Decoding Theory

The W65C02 has 16 address lines (A0-A15), giving 64KB of addressable memory. We have two 32KB chips. How do we select which chip?

**Simple Solution: Use A15 as the chip select**

```
When A15 = 0 ($0000-$7FFF):
  - Enable RAM
  - Disable ROM
  
When A15 = 1 ($8000-$FFFF):
  - Disable RAM
  - Enable ROM
```

**But there's a problem!** 
- RAM /CE and ROM /CE are active LOW (0 = enabled)
- A15 is HIGH for ROM addresses
- We need: A15=0 → RAM_CE=0, A15=1 → ROM_CE=0

**Solution: Invert A15 for ROM**

Using one NAND gate as an inverter:
```
ROM_CE = NOT(A15)

When A15 = 0: ROM_CE = NOT(0) = 1 (ROM disabled)
When A15 = 1: ROM_CE = NOT(1) = 0 (ROM enabled)
```

For RAM, connect A15 directly (it works perfectly):
```
RAM_CE = A15

When A15 = 0: RAM_CE = 0 (RAM enabled)
When A15 = 1: RAM_CE = 1 (RAM disabled)
```

---

## 🔧 Step-by-Step Build Instructions

### Step 1: Prepare Second Breadboard

**Recommended:** Use a second breadboard for memory chips.

1. **Position breadboards side-by-side**
2. **Connect power rails between boards:**
   ```
   Board 1 +5V rail → Board 2 +5V rail (red wire)
   Board 1 GND rail → Board 2 GND rail (black wire)
   ```
3. **Verify voltage** on second breadboard with multimeter

**Alternative:** Use same breadboard but requires careful planning.

### Step 2: Remove Data Bus Hardwiring

Remember in Stage 1, we hardwired the data bus to $EA? Time to remove that!

**Disconnect from CPU:**
- Remove all connections to pins 26-33 (D0-D7)
- Remove pull-up resistors on D1, D3, D5, D6, D7
- Remove ground connections on D0, D2, D4

**Leave these CPU pins open for now** - we'll connect them to memory chips.

### Step 3: Install Memory Chip Sockets

**RAM Socket:**
1. Position 28-pin socket on breadboard
2. Orient notch toward top (marks pin 1)
3. Straddle center gap
4. Press firmly to insert all pins

**ROM Socket:**
1. Position second 28-pin socket below RAM
2. Same orientation (notch up)
3. Leave a few rows between chips for clarity

**74HC00 Socket:**
1. Position 14-pin socket in convenient location
2. This will be our address decoder

**Add decoupling capacitors:**
- RAM: 0.1μF between pin 28 (VCC) and pin 14 (GND)
- ROM: 0.1μF between pin 28 (VCC) and pin 14 (GND)

### Step 4: Power Connections for Memory

**RAM Power:**
```
Pin 28 (VCC) → +5V rail (red wire)
Pin 14 (GND) → Ground rail (black wire)
0.1μF capacitor between pins 28 and 14
```

**ROM Power:**
```
Pin 28 (VCC) → +5V rail (red wire)
Pin 14 (GND) → Ground rail (black wire)
0.1μF capacitor between pins 28 and 14
```

**74HC00 Power:**
```
Pin 14 (VCC) → +5V rail
Pin 7 (GND) → Ground rail
```

**Verify:** Multimeter check all VCC pins read 5V to ground.

---

### Step 5: Connect Address Bus (A0-A14)

Both RAM and ROM need address lines A0-A14 (15 bits for 32KB).

**For EACH address line, connect CPU → RAM → ROM:**

| CPU Pin | Signal | RAM Pin | ROM Pin | Wire Color |
|---------|--------|---------|---------|------------|
| 9 | A0 | 10 | 10 | Green |
| 10 | A1 | 9 | 9 | Green |
| 11 | A2 | 8 | 8 | Green |
| 12 | A3 | 7 | 7 | Green |
| 13 | A4 | 6 | 6 | Green |
| 14 | A5 | 5 | 5 | Green |
| 15 | A6 | 4 | 4 | Green |
| 16 | A7 | 3 | 3 | Green |
| 17 | A8 | 25 | 25 | Green |
| 18 | A9 | 24 | 24 | Green |
| 19 | A10 | 21 | 21 | Green |
| 20 | A11 | 23 | 23 | Green |
| 22 | A12 | 2 | 2 | Green |
| 23 | A13 | 26 | 26 | Green |
| 24 | A14 | 1 | 1 | Green |

**Wiring Method:**
- Use green wires for visual consistency
- Can daisy-chain: CPU → RAM → ROM for each address line
- Or use breadboard rails to distribute signals

**Example for A0:**
```
CPU Pin 9 → breadboard row X
RAM Pin 10 → breadboard row X  
ROM Pin 10 → breadboard row X
```

**This is tedious but critical!** Take your time and double-check each connection.

**Note:** A15 is NOT connected yet (used for chip select decoding).

---

### Step 6: Connect Data Bus (D0-D7)

The data bus connects CPU, RAM, and ROM together.

**For EACH data line:**

| CPU Pin | Signal | RAM Pin | ROM Pin | Wire Color |
|---------|--------|---------|---------|------------|
| 33 | D0 | 11 | 11 | Blue |
| 32 | D1 | 12 | 12 | Blue |
| 31 | D2 | 13 | 13 | Blue |
| 30 | D3 | 15 | 15 | Blue |
| 29 | D4 | 16 | 16 | Blue |
| 28 | D5 | 17 | 17 | Blue |
| 27 | D6 | 18 | 18 | Blue |
| 26 | D7 | 19 | 19 | Blue |

**Wiring Method - Shared Bus:**
```
CPU Pin 33 (D0) ─┬─ RAM Pin 11 (D0)
                 └─ ROM Pin 11 (D0)

CPU Pin 32 (D1) ─┬─ RAM Pin 12 (D1)
                 └─ ROM Pin 12 (D1)
... (repeat for all 8 data lines)
```

**Use blue wires** for easy identification.

**Important:** 
- All three devices share the same data bus
- Only one chip should drive the bus at a time
- That's what the chip enable signals control!

---

### Step 7: Build Address Decoder

Now the critical part - selecting RAM vs ROM based on A15.

**Connect CPU A15 to decoder:**
```
CPU Pin 25 (A15) → 74HC00 Pin 1 (1A)
```

**Build inverter for ROM chip select:**
```
74HC00 Configuration:
  Pin 1 (1A) ← CPU A15
  Pin 2 (1B) ← Connect to Pin 1 (same as 1A)
  Pin 3 (1Y) → ROM Pin 20 (/CE)
```

When both NAND inputs are the same, it acts as an inverter:
- A15 = 0 → 1Y = NOT(0) = 1 → ROM disabled
- A15 = 1 → 1Y = NOT(1) = 0 → ROM enabled ✓

**RAM chip select (direct connection):**
```
CPU Pin 25 (A15) → RAM Pin 20 (/CE)
```

Simple! When A15 = 0, RAM is enabled; when A15 = 1, RAM is disabled.

**ASCII Diagram - Address Decoder:**
```
         CPU A15 ────────┬──────────→ RAM /CE (Pin 20)
                         │
                         └──→ 74HC00 ──→ ROM /CE (Pin 20)
                              Pin 1,2    Pin 3
                              (NAND)     (inverted)
```

---

### Step 8: Connect Control Signals

**Output Enable (Read Control):**

Both RAM and ROM have /OE (Output Enable) pins that control when they put data on the bus.

**Simple version - Always enabled:**
```
RAM Pin 22 (/OE) → Ground
ROM Pin 22 (/OE) → Ground
```

This works because chip enable (/CE) already prevents bus conflicts.

**Better version - Controlled by CPU clock:**

The W65C02 provides a Φ2 output (pin 39) that's synchronized with memory access timing:
```
CPU Pin 39 (Φ2O) → 74HC04 inverter → RAM Pin 22 (/OE)
CPU Pin 39 (Φ2O) → 74HC04 inverter → ROM Pin 22 (/OE)
```

**For now, use the simple version** (ground /OE). We'll optimize later.

**Write Enable (RAM only):**

RAM needs to know when to write data. Connect to CPU's R/W signal:

```
CPU Pin 34 (R/W) → 74HC00 gate → RAM Pin 27 (/WE)
```

**But there's a catch!** 
- CPU R/W: HIGH = Read, LOW = Write
- RAM /WE: LOW = Write, HIGH = Read
- They're INVERTED!

**Solution: Use another NAND gate as inverter**
```
74HC00 Pin 4 (2A) ← CPU R/W (pin 34)
74HC00 Pin 5 (2B) ← Connect to Pin 4
74HC00 Pin 6 (2Y) → RAM Pin 27 (/WE)
```

**ROM /WE:**
```
ROM Pin 27 (/WE) → +5V (via 10kΩ resistor)
```

Keep ROM in read-only mode during normal operation!

---

### Step 9: Verify All Connections

Before powering on, methodically check EVERY wire:

**RAM Checklist:**
- [ ] Pin 28 (VCC) → +5V
- [ ] Pin 14 (GND) → Ground
- [ ] Pins 1-10, 21, 23-26 (A0-A14) → CPU address bus
- [ ] Pins 11-13, 15-19 (D0-D7) → CPU data bus
- [ ] Pin 20 (/CE) → CPU A15
- [ ] Pin 22 (/OE) → Ground (or Φ2O inverted)
- [ ] Pin 27 (/WE) → R/W inverted through 74HC00
- [ ] 0.1μF cap between pins 28 and 14

**ROM Checklist:**
- [ ] Pin 28 (VCC) → +5V
- [ ] Pin 14 (GND) → Ground
- [ ] Pins 1-10, 21, 23-26 (A0-A14) → CPU address bus
- [ ] Pins 11-13, 15-19 (D0-D7) → CPU data bus
- [ ] Pin 20 (/CE) → A15 inverted through 74HC00
- [ ] Pin 22 (/OE) → Ground
- [ ] Pin 27 (/WE) → +5V (via 10kΩ)
- [ ] 0.1μF cap between pins 28 and 14

**74HC00 Checklist:**
- [ ] Pin 14 (VCC) → +5V
- [ ] Pin 7 (GND) → Ground
- [ ] Pins 1,2 (1A, 1B) → CPU A15
- [ ] Pin 3 (1Y) → ROM /CE
- [ ] Pins 4,5 (2A, 2B) → CPU R/W
- [ ] Pin 6 (2Y) → RAM /WE

**CPU Updates:**
- [ ] Address bus A0-A14 connected to memory
- [ ] Address bus A15 connected to decoder
- [ ] Data bus D0-D7 connected to memory
- [ ] R/W signal connected to decoder

---

## 💾 Programming the EEPROM

Before inserting the ROM chip, you need to program it with code. We'll start with a simple test program.

### Test Program 1: Fill Memory Pattern

This program writes a pattern to RAM, then reads it back.

```assembly
; Simple ROM test program
; Writes $AA to $0000, reads it back

.org $8000          ; ROM starts at $8000

reset:
    LDA #$AA        ; Load $AA into accumulator
    STA $0000       ; Store at RAM address $0000
    
    LDA $0000       ; Read back from $0000
    STA $0001       ; Store result at $0001
    
loop:
    JMP loop        ; Infinite loop

; Reset vector at $FFFC
.org $FFFC
    .word reset     ; Point to reset handler
    .word $0000     ; NMI vector (unused)
```

### Test Program 2: LED Blink via Memory

```assembly
; Blink an LED connected to address $6000
.org $8000

reset:
    LDA #$FF        ; All bits high
    
blink_loop:
    STA $6000       ; Write to address $6000 (LED on)
    
    ; Simple delay loop
    LDY #$00
    LDX #$00
delay1:
    DEX
    BNE delay1
    DEY
    BNE delay1
    
    LDA #$00        ; All bits low
    STA $6000       ; LED off
    
    ; Another delay
    LDY #$00
    LDX #$00
delay2:
    DEX
    BNE delay2
    DEY
    BNE delay2
    
    LDA #$FF        ; Reset for next blink
    JMP blink_loop

.org $FFFC
    .word reset
    .word $0000
```

### Using VASM Assembler

**Install VASM:**
```bash
# On Linux/Mac:
wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
tar xzf vasm.tar.gz
cd vasm
make CPU=6502 SYNTAX=oldstyle
sudo cp vasm6502_oldstyle /usr/local/bin/
```

**Assemble your code:**
```bash
vasm6502_oldstyle -Fbin -dotdir test.asm -o test.bin
```

This creates `test.bin` - a binary file ready to program into the EEPROM.

### Programming with Arduino

**Upload programmer sketch to Arduino** (search for "Ben Eater EEPROM programmer Arduino sketch")

**Run programmer:**
```bash
# Send binary file to Arduino
python3 programmer.py test.bin
```

**Programming takes about 30 seconds** - wait for completion message.

### Programming with TL866

```bash
# Using minipro command line tool:
minipro -p AT28C256 -w test.bin
```

**Verify the programming:**
```bash
minipro -p AT28C256 -r verify.bin
diff test.bin verify.bin
```

Should report no differences!

---

## ⚡ Power-On and Testing

### Test Procedure

1. **Remove power** from breadboard

2. **Insert RAM chip:**
   - Match pin 1 (notch) with socket notch
   - Press gently but firmly
   - Verify all pins inserted

3. **Insert programmed ROM chip:**
   - Same orientation as RAM
   - Handle carefully (contains your program!)

4. **Insert 74HC00:**
   - Match orientation

5. **Final visual check:**
   - Look for crossed wires
   - Check for loose connections
   - Verify power rail connections

6. **Apply power**

7. **Press and release reset button**

8. **Observe behavior:**
   - If using Test Program 1: Nothing visible (needs debugging tools)
   - If using Test Program 2: LED should blink!

### Test Program 1 Verification

**Using Multimeter:**
1. Measure data bus voltage while clocking
2. Should see data values changing
3. No longer always $EA!

**Using Logic Analyzer:**
1. Connect to address bus
2. Connect to data bus
3. Trigger on reset
4. Should see program execution sequence

### Test Program 2 Verification (LED Blink)

**Add LED to address $6000:**

Since $6000 = %0110000000000000, we need to decode:
- A15 = 0 (RAM area, but we'll use for I/O)
- A14 = 1
- A13 = 1

**Simple I/O for testing:**
Just tap into data bus D0:
```
CPU Pin 33 (D0) → 220Ω resistor → LED → Ground
```

Or better, decode address $6000 properly (more advanced).

**What you should see:**
- LED blinks on and off
- Roughly 1-2 seconds per blink (depending on clock speed)
- Consistent, repeating pattern

---

## 🔍 Troubleshooting

### Problem: Nothing happens (no LED activity)

**Check power first:**
1. Verify 5V at all VCC pins
2. Check ground connections
3. Look for hot chips (indicates short)

**Check reset:**
1. Measure CPU pin 40 (should be HIGH)
2. Try holding reset for 2 seconds, release
3. Press clock button a few times

**Check memory chips:**
1. Are they inserted correctly (notch orientation)?
2. Are they fully seated in sockets?
3. Try removing and reinserting

### Problem: Erratic behavior (random LED patterns)

**Likely causes:**

1. **Missing decoupling capacitors**
   - Add 0.1μF to EVERY IC
   - Place as close to power pins as possible

2. **Bad address decoding**
   - Verify A15 connections to 74HC00
   - Check ROM /CE gets inverted A15
   - Use multimeter to trace signals

3. **Data bus conflicts**
   - Both RAM and ROM enabled at once?
   - Check /CE signals with logic probe
   - Verify only one chip active per address

### Problem: Program doesn't run (seems stuck)

**Check reset vector:**
1. ROM MUST have valid reset vector at $FFFC-$FFFD
2. This tells CPU where to start
3. Verify in your assembly code: `.org $FFFC` and `.word reset`

**Check ROM programming:**
1. Remove ROM from circuit
2. Verify programming with programmer
3. Check for blank ROM (all $FF)

### Problem: RAM writes don't work

**Check R/W signal:**
1. Measure CPU pin 34 while operating
2. Should toggle HIGH/LOW
3. Check inversion through 74HC00 to RAM /WE

**Verify RAM is selected:**
1. Measure RAM /CE (pin 20)
2. Should be LOW for addresses $0000-$7FFF
3. Should be HIGH for addresses $8000-$FFFF

**Test RAM chip:**
1. Remove RAM from circuit
2. Measure power on chip (pin 28 = 5V, pin 14 = 0V)
3. Try a different RAM chip (might be defective)

### Problem: ROM doesn't respond

**Verify ROM is selected:**
1. Measure ROM /CE (pin 20)
2. Should be HIGH for addresses $0000-$7FFF
3. Should be LOW for addresses $8000-$FFFF

**Check /OE signal:**
1. Pin 22 should be LOW (grounded)
2. If floating, ROM won't output data

**Re-program ROM:**
1. Verify programming voltage (5V, not 12V)
2. Check programmer settings (AT28C256)
3. Try a different ROM chip

---

## 🎓 Understanding Memory Access

### Read Cycle

**When CPU reads from memory:**

1. **T1 (Φ2 LOW):** CPU puts address on address bus
   ```
   Example: CPU wants to read $8100
   Address bus = $8100
   A15 = 1 → ROM /CE = 0 (ROM enabled)
   ```

2. **Address decoding:** 74HC00 determines ROM is selected

3. **T2 (Φ2 HIGH):** Memory puts data on data bus
   ```
   ROM outputs byte at address $8100
   Data bus = (whatever is programmed at $8100)
   ```

4. **CPU latches data** from data bus

5. **Cycle complete:** Address bus changes to next address

### Write Cycle (RAM only)

**When CPU writes to memory:**

1. **Φ2 LOW:** CPU puts address on bus
   ```
   Example: CPU writing to $0050
   Address bus = $0050
   A15 = 0 → RAM /CE = 0 (RAM enabled)
   ```

2. **CPU puts data on bus**
   ```
   Data bus = value to write
   R/W = LOW (write mode)
   ```

3. **Φ2 HIGH:** R/W inverted to /WE
   ```
   /WE goes LOW → RAM latches data
   ```

4. **Data stored** in RAM at address $0050

### Bus Conflicts (and how we avoid them)

**Problem:** If both RAM and ROM output at once, they fight over the data bus!

**Solution:** Chip Enable (/CE) ensures only one chip is active:
```
Address $0050 (A15=0):
  RAM /CE = 0 (enabled, can drive bus)
  ROM /CE = 1 (disabled, hi-Z state)
  
Address $8100 (A15=1):
  RAM /CE = 1 (disabled, hi-Z state)
  ROM /CE = 0 (enabled, can drive bus)
```

**Hi-Z (high impedance):** Disabled chip doesn't fight for the bus.

---

## 🎯 Educational Experiments

### Experiment 1: Manual Memory Inspection

Add DIP switch to manually set data bus:
```
8x DIP switch:
  Switch 0 → D0 (via 10kΩ to +5V, switch to GND)
  Switch 1 → D1
  ... etc ...
```

Now you can manually enter data bytes!

### Experiment 2: RAM Test Pattern

Write a program that:
1. Writes $00, $01, $02... $FF to RAM
2. Reads back and verifies
3. Lights LED if match, blinks if mismatch

This tests all RAM locations!

### Experiment 3: ROM Checksum

Calculate checksum of ROM contents:
```assembly
reset:
    LDA #$00        ; Initialize checksum
    STA $0000       ; Store in RAM
    
    LDX #$00        ; Start at ROM $8000
checksum_loop:
    LDA $8000, X    ; Read ROM byte
    CLC
    ADC $0000       ; Add to checksum
    STA $0000       ; Store new checksum
    
    INX
    BNE checksum_loop
    
    ; Result in $0000
done:
    JMP done
```

Verify the calculated checksum matches expected value.

### Experiment 4: Watch Address Decoding

Add LEDs to monitor chip selects:
```
RAM /CE (pin 20) → 220Ω → Green LED → +5V
ROM /CE (pin 20) → 220Ω → Red LED → +5V
```

**Note:** LEDs go to +5V (not GND) because /CE is active LOW.

As CPU accesses different addresses, watch which chip is selected!

---

## 📊 Memory Access Timing

The W65C02 runs on a clock cycle. Each instruction takes 2-7 cycles:

```
Instruction: LDA $0000 (3 cycles)

Cycle 1: Fetch opcode
  Address = PC
  Read = opcode ($AD = LDA absolute)
  
Cycle 2: Fetch low byte of address  
  Address = PC + 1
  Read = $00
  
Cycle 3: Fetch high byte, read from target
  Address = PC + 2
  Read = $00
  Then: Address = $0000, Read = data
```

**With 1 MHz clock:**
- Each cycle = 1 microsecond
- LDA $0000 takes 3 microseconds
- Plenty of time for our 55ns SRAM!

**Memory Access Budget:**
```
1 MHz clock = 1000ns per cycle
  - Address setup: 100ns
  - RAM access: 55ns
  - Data setup: 50ns
  - Margin: 795ns
```

We have HUGE timing margins! Could run much faster.

---

## ✅ Success Criteria

Stage 2 complete when:
- ✅ CPU reads valid instructions from ROM
- ✅ Program executes correctly (LED blinks, or test passes)
- ✅ RAM can be written and read back
- ✅ Address decoding works (no bus conflicts)
- ✅ Reset boots to ROM program
- ✅ System is stable (no crashes or erratic behavior)

---

## 🎯 Next Steps

You now have a REAL computer! It can:
- Execute programs stored in ROM
- Read and write variables in RAM
- Access full 64KB memory space
- Run at clock speeds up to several MHz

**In Stage 3 (Add LCD), you'll learn:**
- Connect an HD44780 LCD display
- Display text and custom characters
- Write assembly routines for LCD control
- Create interactive programs with visual output

**Before moving on:**
- Test several different programs
- Experiment with RAM read/write
- Try increasing clock speed
- Document your circuit layout (take photos!)

**When ready:** Proceed to **04-add-lcd.md**

---

## 📝 Quick Reference

### Memory Map
```
$0000-$7FFF: RAM (32KB) - Read/Write
$8000-$FFFF: ROM (32KB) - Read-Only
$FFFC-$FFFD: Reset Vector
$FFFA-$FFFB: NMI Vector  
$FFFE-$FFFF: IRQ Vector
```

### Address Decoding Logic
```
RAM /CE = A15 (active when A15 = 0)
ROM /CE = NOT(A15) (active when A15 = 1)
RAM /WE = NOT(R/W)
```

### Essential Vectors (must be in ROM)
```assembly
.org $FFFC
.word reset_handler  ; Where CPU starts
.word nmi_handler    ; NMI interrupt
```

---

*Stage 2 Complete! Ready for Stage 3: Add LCD Display* 🚀
