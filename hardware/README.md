# Hardware Guide 🛠️

Welcome to the hardware section! Here you'll learn about computer hardware and how to build your own computer.

## What You'll Learn

This guide covers both the theory and practice of computer hardware:
- How CPUs, RAM, and buses work
- What components you need
- How to assemble them into a working computer
- Debugging hardware issues

## Learning Paths

### 🔰 Start with Theory

Before building, understand the fundamentals:

1. **[Computer Architecture Basics](./components/computer-architecture.md)**
   - What is a CPU?
   - How does memory work?
   - What are buses?
   - Clock signals and timing

2. **[Digital Electronics Primer](./components/digital-electronics.md)**
   - Logic gates
   - Voltage levels (TTL vs CMOS)
   - Pull-up/pull-down resistors
   - Basic circuit reading

3. **[Component Guide](./components/README.md)**
   - Essential components
   - Where to buy them
   - How to select parts

### 🔧 Building Projects

Choose your hardware adventure:

#### Option 1: W65C02 Computer (Recommended for Beginners)

**[→ W65C02 Computer Building Guide](./w65c02-computer/README.md)**

Build a simple but complete computer from scratch!

- Uses modern W65C02 processor
- Simple, elegant design
- Can be built on breadboards
- Great for learning fundamentals
- Full assembly language support

**What you'll build:**
- Minimal: CPU + RAM + ROM (~$50)
- With LCD: Add output display (~$70)
- Complete: Add keyboard input (~$100)

**Skills learned:**
- Circuit design and breadboarding
- Memory mapping
- Address decoding
- I/O interfacing
- Debugging hardware

#### Option 2: Understanding x86 PCs

**[→ PC Architecture Guide](./pc-architecture/README.md)**

Can't build an x86 PC from scratch (too complex), but you can understand it!

- How modern PCs work
- BIOS/UEFI firmware
- Boot process
- PCI/PCIe buses
- Chipsets and architecture

**What you'll learn:**
- Modern CPU architecture
- Memory hierarchy (cache, RAM, storage)
- Peripheral interfaces
- Firmware and booting
- Why PCs are designed the way they are

## Component Guides

Detailed guides for specific components:

- **[Microprocessors](./components/microprocessors.md)**
  - W65C02, Z80, 8086, etc.
  - How to choose
  - Datasheets explained

- **[Memory Chips](./components/memory.md)**
  - RAM (SRAM, DRAM)
  - ROM (EEPROM, Flash)
  - Address decoding

- **[Interface Chips](./components/interfaces.md)**
  - VIA (65C22)
  - ACIA (serial)
  - PIO (parallel)

- **[Passive Components](./components/passive.md)**
  - Resistors, capacitors
  - Crystals and oscillators
  - Voltage regulators

- **[Tools You'll Need](./components/tools.md)**
  - Soldering equipment
  - Multimeter
  - Logic analyzer
  - Oscilloscope (optional)

## Step-by-Step Build: W65C02 Computer

Want to build the W65C02 computer? Here's the recommended path:

### Stage 1: Planning
1. Read the [W65C02 Computer Overview](./w65c02-computer/00-overview.md)
2. Review the [Bill of Materials](./w65c02-computer/01-bom.md)
3. Order components (links provided)
4. Gather tools

### Stage 2: Minimal System
5. Build [CPU + Clock Circuit](./w65c02-computer/02-cpu-clock.md)
6. Add [RAM](./w65c02-computer/03-ram.md)
7. Add [ROM](./w65c02-computer/04-rom.md)
8. Test with [Blink LED Program](./w65c02-computer/05-first-test.md)

### Stage 3: Output
9. Add [LCD Display](./w65c02-computer/06-lcd.md)
10. Write [Hello World](./w65c02-computer/07-hello-lcd.md)

### Stage 4: Input
11. Add [Keyboard Interface](./w65c02-computer/08-keyboard.md)
12. Build [Simple Monitor](./w65c02-computer/09-monitor.md)

### Stage 5: Expansion
13. Add [VIA for I/O](./w65c02-computer/10-via.md)
14. Build [Additional Projects](./w65c02-computer/11-projects.md)

## Troubleshooting Hardware

Hardware not working? Don't panic!

**[→ Hardware Debugging Guide](./debugging/README.md)**

Common issues:
- Power problems
- Clock issues
- Address decoding errors
- Bad connections
- Timing violations

## Safety First!

Important safety notes:
- Work in a static-safe environment
- Double-check power connections before turning on
- Use appropriate voltage levels
- Don't touch powered circuits
- Know when to ask for help

## Cost Estimates

| Project | Budget Build | Full Build |
|---------|-------------|------------|
| Minimal W65C02 | $50 | $80 |
| W65C02 + LCD | $70 | $110 |
| Complete W65C02 | $100 | $150 |

*Prices include all components but not tools*

## Tools Budget

Essential tools: $50-100
- Breadboards
- Jumper wires
- Basic multimeter
- Soldering iron

Professional tools: $200-500+
- Quality soldering station
- Logic analyzer
- Oscilloscope
- Better multimeter

Start with essentials, upgrade as needed!

## Where to Buy

**Component Suppliers:**
- Mouser Electronics (https://www.mouser.com)
- Digi-Key (https://www.digikey.com)
- Jameco Electronics (https://www.jameco.com)
- Amazon/eBay (for breadboards, wires, etc.)

**Specific chips:**
- W65C02: WDC (https://wdc65xx.com) or through distributors
- EEPROMs: AT28C256 from Atmel/Microchip
- RAM: Alliance, ISSI, or other SRAM manufacturers

## Community and Resources

- Ben Eater's videos (https://eater.net)
- 6502.org forums
- Reddit: r/beneater, r/6502
- EEVblog forums
- Our GitHub Issues

## Next Steps

Ready to build? Choose your path:

**For hardware building:**
→ [Start with W65C02 Computer Build](./w65c02-computer/README.md)

**For understanding modern PCs:**
→ [Read PC Architecture Guide](./pc-architecture/README.md)

**Need to learn more first?**
→ [Computer Architecture Basics](./components/computer-architecture.md)

---

*Remember: Building hardware is challenging but incredibly rewarding. Take it step by step!* 🔨
