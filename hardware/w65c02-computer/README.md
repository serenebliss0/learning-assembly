# Building a W65C02 Computer from Scratch

This guide will walk you through building your own computer based on the W65C02 microprocessor. Inspired by Ben Eater's excellent videos!

## Why Build a Computer?

Building a computer from scratch is one of the best ways to truly understand how computers work. You'll learn:
- How CPUs, RAM, and ROM interact
- What a bus is and how it works
- Address decoding and memory mapping
- Clock signals and timing
- Input/Output interfacing

It's challenging but incredibly rewarding!

## Overview

We'll build the computer in stages:

1. **Minimal System** - CPU, clock, LED (proof of life)
2. **Add Memory** - RAM and ROM
3. **Add Output** - LCD display
4. **Add Input** - Keyboard or buttons
5. **Expand** - More I/O with VIA chip

## What You'll Build

**Final specifications:**
- W65C02S CPU running at 1-8 MHz
- 32KB RAM
- 32KB ROM (EEPROM for easy programming)
- LCD display (16x2 characters)
- Keyboard input
- Expandable I/O via 65C22 VIA

**Total cost:** ~$100-150 for complete system

## Prerequisites

Before starting:
1. Complete at least first 5 W65C02 assembly lessons
2. Read [Computer Architecture Basics](../components/computer-architecture.md)
3. Basic electronics knowledge (or willingness to learn!)
4. Patience!

## Required Components

### Essential ICs

| Component | Quantity | Purpose | Cost |
|-----------|----------|---------|------|
| W65C02S | 1 | CPU | ~$8 |
| 62256 (32KB SRAM) | 1 | RAM | ~$5 |
| AT28C256 (32KB EEPROM) | 1 | ROM | ~$5 |
| 74HC00 (NAND gates) | 1 | Address decode | ~$1 |
| 74HC139 (Decoder) | 1 | Address decode | ~$1 |
| Clock oscillator can (1-8MHz) | 1 | Clock signal | ~$2 |
| HD44780 LCD (16x2) | 1 | Display | ~$10 |
| 65C22 VIA (optional) | 1 | I/O expansion | ~$8 |

**Note on availability:** W65C02S and 65C22 are still manufactured by Western Design Center but may have limited stock at some distributors. Check multiple suppliers (Mouser, Digi-Key, Jameco) or order directly from WDC. The 74HC series and memory chips are widely available.

### Passive Components

- Resistors: 1KΩ (×10), 10KΩ (×10), 3.3KΩ (×1)
- Capacitors: 0.1µF ceramic (×10), 10µF electrolytic (×2)
- LEDs: Various colors (×5-10)
- Push buttons (×2-4)
- 10KΩ potentiometer (for LCD contrast)

### Other Materials

- Breadboards (at least 3 large ones)
- Jumper wire kit
- USB power supply (5V, 1A minimum)
- Breadboard power supply module

**See detailed list:** [Complete Bill of Materials](./01-bom.md)

## Required Tools

### Essential

- Wire strippers
- Multimeter (for testing voltage/continuity)
- Needle-nose pliers

### Recommended

- TL866II Plus programmer (for EEPROM) - ~$50
- Logic probe or LEDs for testing
- Helping hands / PCB holder

### Advanced (Optional)

- Oscilloscope (~$200-500)
- Logic analyzer (~$50-100)
- Soldering iron (for final build on perfboard)

## Stage 1: Minimal System

**Goal:** Get the CPU running with a clock and verify it's working.

### Components Needed
- W65C02S CPU
- Clock oscillator
- LED and resistor
- Power supply

### Build Steps

1. **Power rails** - Set up +5V and GND on breadboard
2. **Install CPU** - Place W65C02S on breadboard
3. **Connect power** - VDD (pin 1) to +5V, VSS (pin 21) to GND
4. **Connect clock** - Clock oscillator to PHI2 (pin 37)
5. **Pull up RES** - Reset (pin 40) to +5V via 1KΩ resistor
6. **Pull up IRQ/NMI** - IRQ (pin 2) and NMI (pin 6) to +5V
7. **Test LED** - LED to address line A0 to see activity

### Testing

When powered on, you should see:
- LED blinking or flickering
- Address lines showing activity (if using logic probe)

**Detailed guide:** [Stage 1 - Minimal System](./02-minimal-system.md)

## Stage 2: Add Memory (RAM and ROM)

**Goal:** Add memory so the CPU can execute actual programs.

### Why Both RAM and ROM?

- **ROM (EEPROM)** - Stores your program permanently
- **RAM** - Temporary storage for variables and stack

### Memory Map

We'll use a simple split:
- $0000-$7FFF: RAM (32KB)
- $8000-$FFFF: ROM (32KB)

### Address Decoding

Use a NAND gate to decode:
- A15 = 0 → RAM selected
- A15 = 1 → ROM selected

### Build Steps

1. Add address decoder circuit
2. Install RAM chip
3. Install ROM chip
4. Connect address bus (A0-A14 to both chips)
5. Connect data bus (D0-D7 to both chips)
6. Connect control signals (R/W, PHI2)

### First Program

Write a simple program that:
1. Blinks an LED
2. Counts up in binary on LEDs

**Detailed guide:** [Stage 2 - Add Memory](./03-add-memory.md)

## Stage 3: Add LCD Display

**Goal:** Output text to a display!

### Why LCD?

Much more useful than LEDs for debugging and user interaction. The HD44780 is industry-standard and easy to interface.

### LCD Interface

- 8 data lines (D0-D7) or 4 data lines (D4-D7) for 4-bit mode
- 3 control lines (RS, R/W, E)
- Power and contrast

We'll use **4-bit mode** to save I/O pins.

### Build Steps

1. Wire LCD power and contrast pot
2. Connect data lines to RAM/ROM data bus
3. Connect control lines to address-decoded locations
4. Write initialization routine
5. Write character display routine

### First Text

Display "Hello, World!" on the LCD!

**Detailed guide:** [Stage 3 - Add LCD](./04-add-lcd.md)

## Stage 4: Add Input

**Goal:** Get user input via keyboard or buttons.

### Options

1. **Simple buttons** - Easiest, good for menus
2. **Matrix keyboard** - More keys, more complex
3. **PS/2 keyboard** - Full keyboard, challenging

Start with simple buttons!

### Button Interface

- Connect buttons to I/O pins
- Add pull-up resistors
- Write debouncing routine

### Build Steps

1. Add button hardware
2. Write button read routine
3. Add debouncing
4. Create simple menu system

**Detailed guide:** [Stage 4 - Add Input](./05-add-input.md)

## Stage 5: Add VIA for Expansion

**Goal:** Add more I/O capabilities with the 65C22 VIA.

### What is a VIA?

The 65C22 Versatile Interface Adapter provides:
- 2 × 8-bit I/O ports
- Timers
- Shift register (for serial communication)
- Interrupt capability

Perfect for expansion!

### Uses

- Sound generation
- More LEDs/buttons
- Serial communication
- Connecting peripherals

**Detailed guide:** [Stage 5 - Add VIA](./06-add-via.md)

## Software Development

### Programming Workflow

1. Write assembly code on PC
2. Assemble to binary
3. Program EEPROM with binary
4. Insert EEPROM into computer
5. Power on and test
6. Debug and iterate

### EEPROM Programming

Using TL866II Plus:
1. Install Xgpro software
2. Select AT28C256 chip
3. Load your .bin file
4. Click "Program"
5. Wait ~30 seconds
6. Remove and insert into computer

**Detailed guide:** [Programming EEPROMs](./07-programming-eeprom.md)

## Troubleshooting

### Nothing Happens

1. Check power - measure 5V at VDD pin
2. Check clock - should see pulses on PHI2
3. Check reset - should be HIGH
4. Check address lines - should show activity

### Erratic Behavior

1. Add decoupling capacitors (0.1µF near each IC)
2. Check all ground connections
3. Verify clock frequency not too high
4. Check for loose wires

### Specific Problems

- **No LCD display**: Check contrast pot, verify initialization
- **Wrong LCD text**: Check data line connections
- **Crashes randomly**: Add decoupling caps, lower clock speed
- **Can't program EEPROM**: Check programmer settings, chip type

**Detailed guide:** [Troubleshooting Hardware](../debugging/hardware-debugging.md)

## From Breadboard to PCB

Once working on breadboard, you might want something permanent!

### Options

1. **Perfboard** - Transfer design to permanent through-hole board
2. **Custom PCB** - Design and order PCB (more advanced)
3. **Keep it on breadboard** - It works!

### Design Considerations

- Decoupling capacitors near each IC
- Ground plane
- Clean power distribution
- Reset button
- Power indicator LED

## Learning Resources

### Videos

- **Ben Eater's 6502 series** - Excellent step-by-step videos
- **The 8-Bit Guy** - Computer history and projects

### Books

- "Programming the 65816" - Great reference
- "6502 Assembly Language Programming" - Classic text

### Websites

- 6502.org - Community and resources
- Western Design Center - Official W65C02 info
- EEVblog forums - Help with hardware

### Datasheets (Essential!)

- [W65C02S Datasheet](http://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf)
- [62256 SRAM Datasheet](https://www.alliance-memory.com/wp-content/uploads/pdf/AS6C62256.pdf)
- [AT28C256 EEPROM Datasheet](http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf)
- [HD44780 LCD Datasheet](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf)
- [65C22 VIA Datasheet](http://www.westerndesigncenter.com/wdc/documentation/w65c22.pdf)

## Projects to Try

Once your computer is working:

1. **Calculator** - Simple math operations
2. **Text editor** - Edit and save text
3. **Games** - Snake, Pong, etc.
4. **Music player** - Generate tones
5. **Serial terminal** - Communicate with PC

**See:** [Project Ideas](./08-project-ideas.md)

## Community

Join the community!

- Reddit: r/beneater, r/6502
- 6502.org forums
- GitHub Issues on this repo

Share your build progress, ask questions, help others!

## Next Steps

Ready to start building?

1. **Order components** - [Bill of Materials](./01-bom.md)
2. **Gather tools**
3. **Start with Stage 1** - [Minimal System](./02-minimal-system.md)
4. **Work through assembly lessons** alongside building
5. **Take your time** - Don't rush!

---

## FAQ

**Q: How long does it take?**
A: 10-20 hours spread over a few weeks, depending on experience.

**Q: Is it hard?**
A: Challenging but manageable. Start simple, build up gradually.

**Q: Can I use different chips?**
A: Yes! Many alternatives work (6502, 65C02, different RAM/ROM sizes).

**Q: Do I need an oscilloscope?**
A: No, but it helps. A logic probe or LEDs work for basic debugging.

**Q: What if I break something?**
A: Components are cheap. Order extras of key chips.

**Q: Can I use this for real projects?**
A: Absolutely! The 65C02 is still used in embedded systems today.

---

*Ready to build? Let's get started!* 🔨

**[→ Next: Bill of Materials](./01-bom.md)**
