# Computer Components Guide

Understanding what components make up a computer and how they work together.

## Overview

A computer needs several key components working together:

1. **CPU (Central Processing Unit)** - The "brain"
2. **Memory** - Storage for data and programs
3. **Clock** - Timing for all operations
4. **Buses** - Pathways for data/addresses/control
5. **I/O (Input/Output)** - Interact with outside world
6. **Power Supply** - Provides electricity

Let's understand each one!

## The CPU (Microprocessor)

The CPU executes instructions and controls everything.

### What It Does

1. **Fetch** - Get next instruction from memory
2. **Decode** - Figure out what instruction means
3. **Execute** - Perform the operation
4. **Repeat** - Do it again, billions of times per second

### Inside a CPU

**Main parts:**
- **ALU (Arithmetic Logic Unit)** - Does math and logic
- **Registers** - Tiny, super-fast storage
- **Control Unit** - Orchestrates everything
- **Cache** (modern CPUs) - Fast memory buffer

### Popular CPUs for DIY

| CPU | Bits | Speed | Complexity | Cost | Best For |
|-----|------|-------|------------|------|----------|
| W65C02 | 8 | 1-14 MHz | Simple | $8 | Learning, DIY computers |
| Z80 | 8 | 4-20 MHz | Moderate | $15 | Retro projects |
| 68000 | 16/32 | 8-16 MHz | Complex | $20 | Advanced projects |
| AVR/PIC | 8 | Varies | Moderate | $2-5 | Embedded systems |
| ARM | 32 | 50+ MHz | Very complex | $5-50 | Modern embedded |

**For this repo, we focus on W65C02** because it's:
- Simple to understand
- Still manufactured
- Great documentation
- Perfect for learning
- Affordable

### CPU Pinout (W65C02)

The W65C02 is a 40-pin DIP package:

```
        +---+--+---+
    VSS |1  +--+ 40| /VP
   /RDY |2       39| PHI2 (clock in)
    PHI |3       38| /SO
   /IRQ |4       37| PHI2 (clock out)
    /ML |5       36| BE
   /NMI |6       35| NC
   SYNC |7       34| R/W
    VDD |8   W   33| D0
     A0 |9   6   32| D1
     A1 |10  5   31| D2
     A2 |11  C   30| D3
     A3 |12  0   29| D4
     A4 |13  2   28| D5
     A5 |14      27| D6
     A6 |15      26| D7
     A7 |16      25| A15
     A8 |17      24| A14
     A9 |18      23| A13
    A10 |19      22| A12
    A11 |20      21| /RES
        +-----------+
```

**Key pins:**
- **A0-A15** (16 pins): Address bus - can address 64KB
- **D0-D7** (8 pins): Data bus - 8-bit data
- **R/W** (1 pin): Read/Write control
- **PHI2** (pin 39): Clock input
- **/RES** (pin 21): Reset (active low)
- **VDD/VSS**: Power (+5V and ground)

## Memory

Memory stores data and programs.

### Types of Memory

**RAM (Random Access Memory):**
- Read and write
- Loses data when power off (volatile)
- Fast
- Used for variables, stack, temporary data

**ROM (Read-Only Memory):**
- Read only (or rarely written)
- Keeps data when power off (non-volatile)
- Stores program code
- Various types: EPROM, EEPROM, Flash

### Memory Technologies

**SRAM (Static RAM):**
- Fast
- Simple to use
- More expensive per byte
- Uses more power
- Common chip: 62256 (32KB)

**DRAM (Dynamic RAM):**
- Needs refresh circuitry
- More complex
- Cheaper per byte
- Used in modern PCs
- Too complex for simple DIY

**EEPROM (Electrically Erasable):**
- Can be programmed electrically
- Slow writes, fast reads
- Limited write cycles (~100,000)
- Perfect for storing programs
- Common chip: AT28C256 (32KB)

### Memory Organization

Memory is organized in bytes, each with unique address:

```
Address    Data
-------    ----
$0000      $A9    ; LDA #$42
$0001      $42
$0002      $8D    ; STA $6000
$0003      $00
$0004      $60
...
```

### Memory Map

A **memory map** shows what's where:

**Example W65C02 Computer:**
```
$0000 - $00FF   Zero Page (256 bytes)
$0100 - $01FF   Stack (256 bytes)
$0200 - $7FFF   General RAM (~32KB)
$8000 - $DFFF   Program ROM (~24KB)
$E000 - $EFFF   I/O mapped devices
$F000 - $FFFF   ROM (~4KB)
$FFFA - $FFFB   NMI vector
$FFFC - $FFFD   Reset vector
$FFFE - $FFFF   IRQ vector
```

### Address Decoding

How does CPU select RAM vs ROM?

Use logic gates to decode address lines:
- A15 = 0 → Select RAM
- A15 = 1 → Select ROM

For multiple devices, use decoder chips like 74HC138.

## Clock

The clock synchronizes all operations.

### What Is a Clock?

A repeating square wave signal:

```
      +---+   +---+   +---+
      |   |   |   |   |   |
------+   +---+   +---+   +---
      ^   ^   ^   ^   ^
      Tick! Tick! Tick!
```

### Clock Sources

**Crystal Oscillator:**
- Very stable frequency
- Requires caps and support circuit
- Example: 1.8432 MHz (common for serial)

**Oscillator Can:**
- Complete oscillator in a package
- Just add power
- Easy to use
- Example: 1 MHz, 4 MHz, 8 MHz

**555 Timer:**
- Adjustable frequency
- Simple to build
- Less stable
- Good for learning/testing

### Clock Speed

**Faster = Better?** Not always!

**Faster:**
- More instructions per second
- Better performance

**Slower:**
- Easier to troubleshoot
- Less noise
- Lower power
- Easier timing

For learning: Start with 1 MHz. You can actually see signals!

For the W65C02:
- Minimum: DC (0 Hz) - can single-step!
- Maximum: 14 MHz (W65C02S)

## Buses

Buses are groups of wires carrying signals.

### Address Bus

Carries memory addresses from CPU to memory/devices.

- W65C02: 16-bit address bus (A0-A15)
- Can address 2^16 = 65,536 bytes (64KB)

```
CPU                Memory
---                ------
A0 --------------> A0
A1 --------------> A1
...
A15 -------------> A15
```

### Data Bus

Carries actual data between CPU and memory.

- W65C02: 8-bit data bus (D0-D7)
- Bidirectional (data flows both ways)
- Can transfer 1 byte at a time

```
CPU                Memory
---                ------
D0 <-------------> D0
D1 <-------------> D1
...
D7 <-------------> D7
```

### Control Bus

Control signals like:
- **R/W** - Read or Write
- **Clock** - Timing signal
- **/RES** - Reset
- **/IRQ**, **/NMI** - Interrupts
- Chip selects

```
CPU
---
R/W ----------> Memory (tells it read or write)
Clock --------> Memory (when to act)
```

## Input/Output (I/O)

How computer interacts with outside world.

### Methods

**Memory-Mapped I/O:**
- Devices appear as memory addresses
- Read/write like normal memory
- Simple!

Example:
```asm
LDA $6000    ; Read from input device at $6000
STA $7000    ; Write to output device at $7000
```

**Port-Mapped I/O:**
- Special IN/OUT instructions
- Separate I/O space
- Used by x86
- Not used by 6502

### Common I/O Devices

**Simple:**
- LEDs (output)
- Buttons (input)
- Switches (input)

**Intermediate:**
- LCD display (output)
- 7-segment displays (output)
- Keypad matrix (input)

**Advanced:**
- Serial port (bidirectional)
- Parallel port (bidirectional)
- PS/2 keyboard (input)
- Sound output

### Interface Chips

Special chips designed for I/O:

**65C22 VIA (Versatile Interface Adapter):**
- 2 × 8-bit parallel ports
- Timers
- Shift register
- Perfect for 6502 systems

**6551 ACIA (Asynchronous Communications Interface Adapter):**
- Serial communication
- RS-232 interface
- For connecting to PC

**6522 VIA, 6821 PIA:**
- Older variants
- Similar functionality

## Power Supply

Everything needs power!

### Requirements

**Voltage:** 
- Most DIY computers: 5V DC
- Modern logic: Often 3.3V
- Match your components!

**Current:**
- W65C02: ~10 mA
- RAM/ROM: ~10-100 mA each
- LEDs: ~20 mA each
- LCD: ~50 mA
- Total: Usually under 500 mA

**Stability:**
- Must be stable (not fluctuating)
- Clean (low noise)
- Regulated

### Power Supply Options

**USB Power:**
- 5V, up to 500 mA (USB 2.0) or 900 mA (USB 3.0)
- Convenient and safe
- Good for breadboard projects

**Wall Adapter:**
- Various voltages
- Use with regulator
- Higher current available

**Breadboard Power Supply Module:**
- Takes 7-12V input
- Outputs 5V and 3.3V
- Convenient for breadboard
- ~$3

**Battery:**
- Portable
- Need voltage regulator
- 4× AA batteries = 6V (regulate to 5V)

### Power Distribution

**Good practices:**
- Use power rails on breadboard
- Add bulk capacitor (10µF) at power input
- Add 0.1µF bypass capacitor near EACH IC
- Check voltage at each IC (should be close to 5V)

### Bypass Capacitors

**Why?** When IC switches, it draws quick burst of current. This causes voltage dip. Bypass cap provides that burst locally.

**Where?** Place 0.1µF ceramic cap between VDD and GND pins of EVERY IC, as close as possible.

```
        VDD
         |
        [C]  0.1µF (bypass cap)
         |
        GND
```

## Putting It All Together

Here's how components connect in a simple computer:

```
         +-------+
Clock -->| W65C02|<--> RAM (data bus)
         |  CPU  |<--> ROM (data bus)
         +-------+
            |  |
            |  +-----> A0-A15 (address bus)
            |
            +--------> Control signals (R/W, etc.)
```

### Minimal System

Absolute minimum to run code:
1. CPU
2. ROM (with program)
3. Clock
4. Power supply
5. Pull-up resistors on unused inputs

### Practical System

For actually doing something:
1. CPU
2. RAM (for variables)
3. ROM (for program)
4. Clock
5. I/O (LCD, LEDs, buttons)
6. Interface chips (VIA for expansion)
7. Power supply

## Component Selection Tips

### Choosing a CPU

**For learning:**
- W65C02 - Simple, well-documented
- Z80 - Classic, lots of resources

**For embedded projects:**
- AVR - Arduino uses these
- PIC - Also popular
- ARM - Industry standard, more complex

### Choosing Memory

**RAM:**
- 32KB (62256) - Good size for most projects
- Bigger if doing complex graphics

**ROM:**
- EEPROM (AT28C256) - Reprogrammable, easy
- Flash - Modern, higher density
- EPROM - Old school, needs UV eraser

### Logic Chips

**Families:**
- **74HC** - CMOS, low power, 5V (use this!)
- **74LS** - TTL, higher power, obsolete
- **74HCT** - CMOS with TTL compatibility

**Common chips:**
- 74HC00 - NAND gates
- 74HC04 - Inverters
- 74HC08 - AND gates
- 74HC32 - OR gates
- 74HC138 - 3-to-8 decoder
- 74HC139 - 2-to-4 decoder
- 74HC245 - Bus transceiver

## Where to Learn More

**Component datasheets:**
- Always read the datasheet!
- Contains pinout, timing, specs
- Essential reference

**Tutorials:**
- Ben Eater's videos
- 6502.org tutorials
- This repository!

**Books:**
- "Digital Computer Electronics" - Malvino
- "The Art of Electronics" - Horowitz & Hill

---

## Quick Reference: W65C02 Computer

**Minimum Bill of Materials:**
- W65C02S CPU
- AT28C256 EEPROM (32KB)
- Oscillator can (1-8 MHz)
- 1KΩ resistors (×5)
- 0.1µF capacitors (×5)
- Breadboard
- Jumper wires
- 5V power supply

**Add for practical use:**
- 62256 SRAM (32KB)
- 74HC00 (for address decode)
- HD44780 LCD display
- Push buttons
- More capacitors and resistors

**Cost: ~$50-100** depending on components

---

*Ready to build? Check out the [W65C02 Computer Building Guide](../w65c02-computer/README.md)!*
