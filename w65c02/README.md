# W65C02 Assembly Learning Path 🔧

Welcome to the W65C02 Assembly learning path! This is based on the classic 6502 processor - perfect for building your own computer!

## What is W65C02 Assembly?

The W65C02 is a modern version of the classic 6502 processor used in:
- Apple II
- Commodore 64
- Nintendo Entertainment System (NES)
- BBC Micro

It's simple, elegant, and perfect for learning AND for building your own computer from scratch!

## Why Start Here?

Choose the W65C02 path if you want to:
- Build your own computer from scratch
- Understand computer architecture from first principles
- Learn with a simpler, more elegant instruction set
- Follow Ben Eater-style hardware tutorials

## Prerequisites

- Basic programming knowledge (any language is fine)
- Patience and curiosity!
- Optional: Basic electronics knowledge (for hardware building)

## Learning Path

### Phase 1: Fundamentals (Start Here!)
1. **[Lesson 01: Hello World (Emulator)](./lessons/01-hello-world/)** - Your first 6502 program
2. **[Lesson 02: Registers and Flags](./lessons/02-registers/)** - Understanding the CPU
3. **[Lesson 03: Addressing Modes](./lessons/03-addressing/)** - Different ways to access data
4. **[Lesson 04: Arithmetic Operations](./lessons/04-arithmetic/)** - Basic math
5. **[Lesson 05: Control Flow](./lessons/05-control-flow/)** - Branching and loops

### Phase 2: Intermediate Concepts
6. **[Lesson 06: Subroutines](./lessons/06-subroutines/)** - JSR and RTS
7. **[Lesson 07: Working with Memory](./lessons/07-memory/)** - Zero page and beyond
8. **[Lesson 08: Stack Operations](./lessons/08-stack/)** - Using the stack
9. **[Lesson 09: Bit Manipulation](./lessons/09-bits/)** - Bit operations
10. **[Lesson 10: Tables and Lookup](./lessons/10-tables/)** - Data structures

### Phase 3: Hardware Integration
11. **[Lesson 11: Memory-Mapped I/O](./lessons/11-io/)** - Controlling hardware
12. **[Lesson 12: VIA (65C22)](./lessons/12-via/)** - Versatile Interface Adapter
13. **[Lesson 13: LCD Display](./lessons/13-lcd/)** - Controlling an LCD
14. **[Lesson 14: Interrupts](./lessons/14-interrupts/)** - IRQ and NMI
15. **[Lesson 15: Building a Monitor](./lessons/15-monitor/)** - Simple OS

## Hardware Projects

Want to build the computer? Follow these guides:

1. **[Minimal Computer](./projects/01-minimal/)** - CPU, RAM, ROM
2. **[Add LCD Display](./projects/02-lcd/)** - Output capability
3. **[Add Keyboard Input](./projects/03-keyboard/)** - Input capability
4. **[Add VIA for Expansion](./projects/04-via/)** - I/O ports
5. **[Complete Computer](./projects/05-complete/)** - Full system!

**→ See also: [W65C02 Computer Building Guide](../hardware/w65c02-computer/README.md)**

## Examples

Quick reference examples:
- [Basic Examples](./examples/basic-examples.asm)
- [Math Examples](./examples/math-examples.asm)
- [I/O Examples](./examples/io-examples.asm)
- [Hardware Control](./examples/hardware-examples.asm)

## Setup Guide

Before you start, set up your development environment:
**[→ W65C02 Setup Instructions](./setup.md)**

You'll need:
- cc65 toolchain (for assembly and linking)
- py65mon (emulator for testing)
- Optional: Hardware components for physical build

## Quick Reference

- **[W65C02 Instruction Reference](./reference/instructions.md)** - All instructions
- **[Addressing Modes](./reference/addressing-modes.md)** - Complete guide
- **[Memory Map](./reference/memory-map.md)** - Standard memory layout
- **[Pin Reference](./reference/pins.md)** - W65C02 pinout

## Tips for Success

1. **Start with emulator** - Test code before hardware
2. **Understand addressing modes** - They're key to 6502
3. **Use zero page** - It's fast!
4. **Draw out your logic** - Visual helps
5. **Check the flags** - Status register is important

## Common Pitfalls

- Forgetting to set/clear flags
- Wrong addressing mode
- Not handling overflow
- Decimal mode confusion (it's a thing!)

See [Common Mistakes](../resources/common-mistakes.md) for more.

## Hardware Building

If you want to build the physical computer:

1. **Start with software** - Learn assembly in emulator first
2. **Read the hardware guide** - [W65C02 Computer Building Guide](../hardware/w65c02-computer/README.md)
3. **Get components** - See [Components Guide](../hardware/components/README.md)
4. **Build incrementally** - Test each stage
5. **Be patient** - Hardware debugging is challenging but rewarding!

## Need Help?

- Check the [Debugging Tips](../resources/debugging-tips.md)
- Review the [Glossary](../resources/glossary.md)
- Open an issue on GitHub
- Double-check your wiring (if building hardware)!

## Next Steps

Ready to begin? **[Start with Lesson 01: Hello World →](./lessons/01-hello-world/)**

---

*Remember: The 6502 is simple and elegant. Perfect for learning!* 🚀
