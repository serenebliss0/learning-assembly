# Bill of Materials - W65C02 Computer

## Overview

This is a complete parts list for building a W65C02-based 8-bit computer from scratch. The system includes a CPU, clock circuit, RAM, ROM, and LCD display - everything you need to write and run assembly programs on real hardware.

**Estimated Total Cost:** $60-$80 (excluding breadboards and basic tools)

**Build Time:** 10-20 hours spread across multiple sessions

---

## 🔧 Tools Required

### Essential Tools
- **Soldering iron** (for EEPROM programmer, optional for headers)
- **Wire strippers**
- **Needle-nose pliers**
- **Multimeter** - for checking connections and voltages
- **USB cable** - for powering the breadboard

### Nice to Have
- **Logic probe** - invaluable for debugging
- **Oscilloscope** - helpful but not required
- **Component storage box** - keep your parts organized

---

## 🔌 Power Supply

| Item | Part Number | Quantity | Price | Notes |
|------|-------------|----------|-------|-------|
| **Breadboard power supply** | MB102 | 1 | $2-3 | 5V/3.3V output, accepts 6.5-12V input or USB |
| **9V power adapter** | 9V 1A DC | 1 | $5-7 | 2.1mm barrel jack, center positive |
| **OR USB cable** | USB-A to Micro-B | 1 | $3-5 | Alternative power via USB |

**Where to Buy:**
- Mouser: 490-SWI10-5-N-P5 (5V 2A adapter)
- Amazon: Search "MB102 breadboard power supply"

**Why These:** The MB102 module provides regulated 5V power from either a 9V wall adapter or USB. The W65C02 requires stable 5V power (±5%).

---

## 🍞 Breadboards and Wire

| Item | Part Number | Quantity | Price | Notes |
|------|-------------|----------|-------|-------|
| **Large breadboard** | 830 tie-points | 3-4 | $5 each | More breadboards = easier layout |
| **Breadboard jumper wire kit** | Various lengths | 1 kit | $8-12 | Get solid core, 22 AWG |
| **22 AWG solid core wire** | Various colors | 1 roll | $10-15 | For custom length jumpers |

**Where to Buy:**
- Amazon: "Breadboard jumper wire kit"
- Jameco: 20722 (830 point breadboard)

**Important:** Use **solid core** wire for breadboards. Stranded wire doesn't stay in place.

**Color Coding Recommendation:**
- Red: +5V power
- Black: Ground (GND)
- Yellow: Clock signals
- Green: Address bus (A0-A15)
- Blue: Data bus (D0-D7)
- White/Gray: Control signals (R/W, RES, etc.)

---

## 💻 Main IC Chips

### CPU and Support Chips

| Item | Part Number | Qty | Price | Supplier Part # | Notes |
|------|-------------|-----|-------|----------------|-------|
| **CPU** | W65C02S6TPG-14 | 1 | $5-7 | Mouser: 955-W65C02S6TPG-14 | CMOS 6502, DIP-40 package, 14 MHz |
| **RAM** | AS6C62256-55PCN | 1 | $5-6 | Mouser: 913-AS6C62256-55PCN | 32KB SRAM, 55ns, DIP-28 |
| **ROM/EEPROM** | AT28C256-15PU | 1 | $4-5 | Mouser: 556-AT28C256-15PU | 32KB EEPROM, 150ns, DIP-28 |

**Important Notes:**

**CPU - W65C02S:**
- Must be the CMOS version (W65C02S), not NMOS (6502)
- WDC (Western Design Center) is the only current manufacturer
- The "S" model has additional instructions and bug fixes
- Speed rating: 6TPG-14 = 14 MHz (plenty fast, we'll run at 1 MHz)

**RAM - AS6C62256:**
- 32KB x 8-bit static RAM
- 55ns access time (fast enough for 1 MHz operation)
- Alternatives: CY62256, HM62256, UM61256 (all compatible)
- **NOT**: Make sure it's the 32KB version (62256), not 8KB (6264)

**ROM - AT28C256:**
- Electrically Erasable PROM (EEPROM)
- Can be programmed and erased without UV light
- 150ns access time
- You'll need a programmer (see below)
- Alternative: SST39SF010A (flash memory, requires different programming)

### Logic Chips

| Item | Part Number | Qty | Price | Notes |
|------|-------------|-----|-------|-------|
| **Quad NAND gate** | 74HC00 | 1 | $0.40 | For address decoding |
| **Quad AND gate** | 74HC08 | 1 | $0.40 | Alternative for address decoding |
| **Hex inverter** | 74HC04 | 1 | $0.40 | For signal inversion if needed |

**Where to Buy:**
- Mouser: 595-SN74HC00N
- Digi-Key: 296-8205-5-ND (74HC00)

**CRITICAL:** Use **74HC** series, NOT 74HCT or 74LS!
- 74HC: CMOS, 5V logic, compatible with W65C02
- 74HCT: TTL-compatible CMOS (different thresholds)
- 74LS: Old TTL technology (won't work reliably with CMOS)

The W65C02 has CMOS outputs that may not drive 74LS inputs properly.

---

## ⏱️ Clock Circuit Components

### Option A: 555 Timer (Recommended for Learning)

| Item | Part Number | Qty | Price | Notes |
|------|-------------|-----|-------|-------|
| **555 timer IC** | NE555P or LM555CN | 1 | $0.50 | DIP-8 package |
| **Potentiometer** | 1MΩ linear | 1 | $1 | For adjustable clock speed |
| **Resistor** | 1kΩ (brown-black-red) | 1 | $0.10 | |
| **Capacitor** | 1μF electrolytic | 1 | $0.20 | For 1 Hz at mid-pot setting |
| **Capacitor** | 0.1μF ceramic | 1 | $0.10 | For ~1 kHz at mid-pot setting |
| **Capacitor** | 10nF (0.01μF) | 1 | $0.10 | For ~10 kHz |
| **LED** | 5mm red | 1 | $0.20 | Clock indicator |
| **Resistor** | 220Ω (red-red-brown) | 1 | $0.10 | LED current limiting |

**Where to Buy:**
- Mouser: 595-NE555P (timer)
- Jameco: 29081 (potentiometer)

### Option B: Crystal Oscillator (Production)

| Item | Part Number | Qty | Price | Notes |
|------|-------------|-----|-------|-------|
| **Crystal oscillator** | 1.8432 MHz DIP-8 | 1 | $2-3 | Common frequency for serial |
| **OR Crystal oscillator** | 1.000 MHz DIP-8 | 1 | $2-3 | Nice round number |

**Where to Buy:**
- Mouser: 815-ACO-1-8432MHZ (1.8432 MHz)
- Digi-Key: CTX277-ND (1 MHz)

**Why 1.8432 MHz?** Divides evenly for standard baud rates (9600, 19200, etc.) if you add serial I/O later.

---

## 📺 LCD Display Components

| Item | Part Number | Qty | Price | Notes |
|------|-------------|-----|-------|-------|
| **LCD module** | 1602A (16x2) | 1 | $4-6 | HD44780 compatible, 5V |
| **Potentiometer** | 10kΩ linear | 1 | $0.50 | For contrast adjustment |

**Where to Buy:**
- Amazon: Search "1602 LCD HD44780"
- Adafruit: 181 (comes with header pins)

**Specifications:**
- 16 characters x 2 lines
- HD44780 controller (or compatible)
- 5V power
- White on blue or green on black (common options)
- Includes LED backlight

**Optional - LCD Header:**
- 16-pin male header (if LCD doesn't have pins pre-soldered)
- Single row, 2.54mm pitch

---

## 🔌 IC Sockets (Highly Recommended)

| Item | Size | Qty | Price | Notes |
|------|------|-----|-------|-------|
| **DIP-40 socket** | 40-pin | 1 | $0.80 | For W65C02 CPU |
| **DIP-28 socket** | 28-pin | 2 | $0.40 ea | For RAM and ROM |
| **DIP-14 socket** | 14-pin | 3 | $0.30 ea | For 74HC logic chips |
| **DIP-8 socket** | 8-pin | 1 | $0.20 | For 555 timer |

**Where to Buy:**
- Mouser: 517-4840-6000-CP (40-pin)
- Jameco: 112301 (40-pin socket)

**Why Use Sockets:**
- Protects ICs from soldering heat (if you're building on perfboard later)
- Easy to replace if a chip fails
- Can swap chips for testing
- Professional look

---

## 🔴 LEDs and Resistors

### LEDs for Debugging

| Item | Color | Qty | Price | Notes |
|------|-------|-----|-------|-------|
| **5mm LEDs** | Red | 10 | $2 | For address/data bus visualization |
| **5mm LEDs** | Green | 5 | $1.50 | For control signals |
| **5mm LEDs** | Yellow | 5 | $1.50 | For status indicators |

### Resistor Pack

| Value | Color Code | Qty | Purpose |
|-------|------------|-----|---------|
| **220Ω** | Red-Red-Brown | 25 | LED current limiting (for 5V) |
| **1kΩ** | Brown-Black-Red | 10 | Pull-ups, 555 timing |
| **10kΩ** | Brown-Black-Orange | 10 | Pull-ups, reset circuits |
| **1MΩ** | Brown-Black-Green | 2 | 555 timer |

**Where to Buy:**
- Amazon: "Resistor kit" (get an assortment)
- Mouser: Search by value (e.g., "220 ohm 1/4 watt")

**Resistor Kit Recommendation:** Get a 860-piece resistor assortment kit (~$10 on Amazon). You'll have every value you need.

---

## 🎛️ Push Buttons and Switches

| Item | Type | Qty | Price | Notes |
|------|------|-----|-------|-------|
| **Tactile push button** | 6mm momentary | 3 | $1.50 | Reset, NMI, IRQ |
| **DIP switch** | 8-position | 1 | $1 | For manual data input (optional) |

**Where to Buy:**
- Adafruit: 367 (tactile button pack)
- Mouser: 653-B3F-1000 (push button)

---

## 📝 EEPROM Programmer

You'll need a way to program the AT28C256 EEPROM with your code.

### Option A: Arduino-Based Programmer (Recommended - DIY)

| Item | Qty | Price | Notes |
|------|-----|-------|-------|
| **Arduino Nano** | 1 | $5-8 | Arduino-compatible board |
| **74HC595 shift register** | 2 | $0.80 | For address multiplexing |

**Cost:** ~$7 + components you already have
**Tutorial:** Look up "Ben Eater EEPROM programmer" - excellent DIY project

### Option B: Commercial Programmer

| Item | Model | Price | Notes |
|------|-------|-------|-------|
| **TL866II Plus** | MiniPro | $50-60 | Programs many chip types |

**Where to Buy:**
- Amazon: Search "TL866II Plus programmer"
- eBay: Often cheaper

**Recommendation:** Start with the Arduino programmer. It's a great learning experience and costs very little. Upgrade to a commercial programmer if you do lots of EPROM work.

---

## 📦 Capacitors for Decoupling

**Critical for reliable operation!**

| Item | Value | Qty | Price | Notes |
|------|-------|-----|-------|-------|
| **Ceramic capacitors** | 0.1μF (104) | 10 | $2 | One per IC for power decoupling |

**Where to Buy:**
- Mouser: 80-C320C104K5R (0.1μF ceramic)
- Get a capacitor assortment kit

**Why You Need These:**
- Place one 0.1μF capacitor between VCC and GND on EVERY IC
- Located as close as possible to the IC's power pins
- Filters out noise and voltage spikes
- **DO NOT SKIP THIS** - your computer won't work reliably without them

**Placement:**
- CPU (pin 1/21 or 8/40)
- RAM (pin 14/28)
- ROM (pin 14/28)
- Each 74HC chip
- 555 timer

---

## 🛒 Shopping Lists by Supplier

### Mouser Electronics Order (~$25)

```
Qty  Part Number           Description                    Price
1    955-W65C02S6TPG-14   W65C02S CPU                    $6.50
1    913-AS6C62256-55PCN  32KB SRAM                      $5.20
1    556-AT28C256-15PU    32KB EEPROM                    $4.80
1    595-SN74HC00N        Quad NAND gate                 $0.42
1    595-SN74HC08N        Quad AND gate                  $0.42
1    595-SN74HC04N        Hex inverter                   $0.42
1    595-NE555P           555 timer                      $0.48
10   80-C320C104K5R       0.1μF capacitors               $2.00
1    517-4840-6000-CP     40-pin DIP socket              $0.85
2    517-4828-6000-CP     28-pin DIP socket              $1.60
```

### Amazon Order (~$30)

```
- 3x 830-point breadboards
- Jumper wire kit (various lengths)
- Resistor assortment kit (860 pieces)
- LED assortment kit (5mm, various colors)
- 16x2 LCD display (HD44780)
- MB102 breadboard power supply
- Arduino Nano (for EEPROM programmer)
- Tactile push buttons (pack of 10)
```

### Jameco Electronics (Alternative)

```
Qty  Part Number    Description                    Price
1    43081         W65C02S-14 CPU                 $6.95
1    242519        AS6C62256 32KB SRAM            $5.95
1    74374         AT28C256 EEPROM                $4.95
```

---

## 🔄 Alternative Components

### If You Can't Find W65C02S:
- **W65C02S6TPG-14** (14 MHz) - original recommendation
- **W65C02S6TPG-8** (8 MHz) - slower, but still works fine
- **UM6502** - Compatible but avoid NMOS 6502 variants

### RAM Alternatives:
All these are pin-compatible 32KB SRAM chips:
- **AS6C62256** (Alliance) - recommended
- **CY62256** (Cypress)
- **HM62256** (Hitachi/Renesas)
- **UM61256** (Unicorn Micro)

### ROM Alternatives:
- **AT28C256** (Atmel/Microchip) - EEPROM, recommended
- **SST39SF010A** (Microchip) - Flash memory, 128KB (needs adapter)
- **27C256** - UV EPROM (requires UV eraser, not recommended)

### Clock Alternatives:
- **555 timer** - Variable speed, great for learning
- **74HC14** + RC circuit - Schmitt trigger oscillator
- **Crystal oscillator can** - Fixed frequency, production use
- **Cypress CY2309** - Programmable clock (advanced)

---

## 💰 Cost Breakdown

| Category | Cost |
|----------|------|
| **Main ICs** (CPU, RAM, ROM) | $15-20 |
| **Logic chips** (74HC series) | $2-3 |
| **LCD display** | $4-6 |
| **Clock components** | $3-5 |
| **Breadboards** (3-4) | $15-20 |
| **Wire and jumpers** | $10-15 |
| **LEDs and resistors** | $5-8 |
| **Capacitors** | $2-3 |
| **Power supply** | $5-10 |
| **IC sockets** | $3-5 |
| **Misc (buttons, etc.)** | $3-5 |
| **TOTAL** | **$67-100** |

**EEPROM Programmer:**
- Arduino DIY: +$7
- Commercial: +$50-60

---

## ✅ Shopping Checklist

Print this list and check off items as you acquire them:

### Core Components
- [ ] W65C02S CPU (DIP-40)
- [ ] 32KB SRAM (AS6C62256 or equivalent)
- [ ] 32KB EEPROM (AT28C256)
- [ ] 74HC00 NAND gate
- [ ] 74HC08 AND gate (optional)
- [ ] 74HC04 inverter (optional)

### Clock Circuit
- [ ] 555 timer IC
- [ ] 1MΩ potentiometer
- [ ] 1kΩ resistor
- [ ] 1μF capacitor
- [ ] 0.1μF capacitor
- [ ] 10nF capacitor

### Display
- [ ] 16x2 LCD module (HD44780)
- [ ] 10kΩ potentiometer (contrast)

### Power and Infrastructure
- [ ] 3-4 breadboards (830 points each)
- [ ] Breadboard power supply (MB102)
- [ ] 9V power adapter OR USB cable
- [ ] Jumper wire kit
- [ ] Solid core wire (22 AWG)

### Passive Components
- [ ] 10x 0.1μF ceramic capacitors
- [ ] 25x 220Ω resistors
- [ ] 10x 1kΩ resistors
- [ ] 10x 10kΩ resistors
- [ ] 2x 1MΩ resistors

### LEDs and Indicators
- [ ] 10x red LEDs (5mm)
- [ ] 5x green LEDs (5mm)
- [ ] 5x yellow LEDs (5mm)

### Switches and Buttons
- [ ] 3x tactile push buttons
- [ ] 8-position DIP switch (optional)

### IC Sockets
- [ ] 1x 40-pin DIP socket
- [ ] 2x 28-pin DIP sockets
- [ ] 3x 14-pin DIP sockets
- [ ] 1x 8-pin DIP socket

### EEPROM Programming
- [ ] Arduino Nano (for DIY programmer)
- [ ] 2x 74HC595 shift registers (for DIY)
- [ ] OR TL866II Plus programmer

### Tools
- [ ] Multimeter
- [ ] Wire strippers
- [ ] Needle-nose pliers
- [ ] Soldering iron

---

## 📚 Additional Resources

### Datasheets (Essential Reading)
- **W65C02S:** https://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf
- **AS6C62256:** Search "AS6C62256 datasheet" for pinout
- **AT28C256:** Search "AT28C256 datasheet" for programming specs
- **HD44780:** LCD controller datasheet

### Where to Learn More
- **Ben Eater's YouTube Channel** - 6502 computer build series
- **6502.org** - Community forum and resources
- **Jameco Electronics** - Learning center with tutorials

---

## ⚠️ Common Mistakes to Avoid

1. **Wrong chip series:** Using 74LS instead of 74HC (won't work with CMOS)
2. **Forgetting decoupling caps:** Every IC needs a 0.1μF cap!
3. **NMOS 6502:** Make sure you get the CMOS W65C02S, not old NMOS 6502
4. **RAM size:** Get 32KB (62256), not 8KB (6264)
5. **Stranded wire:** Use solid core for breadboards
6. **No IC sockets:** Makes debugging and replacement difficult
7. **Cheap breadboards:** Get quality breadboards with good contacts

---

## 🎯 What's Next?

Once you have all these components:
1. **Read Stage 2: Minimal System** - Build the basic CPU/clock/LED circuit
2. **Test everything** - Make sure each component works before assembly
3. **Organize your workspace** - Keep components sorted and labeled
4. **Take your time** - Rushing leads to mistakes

**Good luck with your build!** 🚀

---

*Last updated: 2025*
*Prices and availability subject to change*
