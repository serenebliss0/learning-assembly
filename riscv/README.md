# RISC-V Assembly Learning Path 🖥️

Welcome to the RISC-V Assembly learning path! RISC-V is a modern, open-source instruction set architecture that's gaining rapid adoption.

## What is RISC-V Assembly?

RISC-V (pronounced "risk-five") is an open standard instruction set architecture (ISA) based on RISC principles. It's used in:
- Embedded systems and microcontrollers
- Academic research and education
- High-performance computing
- IoT devices
- Increasingly, commercial products

Learning RISC-V assembly gives you insight into modern, clean CPU design!

## Why Choose RISC-V?

Choose the RISC-V path if you want to:
- Learn a modern, clean instruction set
- Work with open-source hardware
- Understand RISC (Reduced Instruction Set Computer) principles
- Target embedded systems and IoT
- Be part of the future of computing

### Advantages of RISC-V

✅ **Open and Free**: No licensing fees, completely open
✅ **Clean Design**: Simple, consistent instruction set
✅ **Modular**: Base + optional extensions (M, A, F, D, C)
✅ **Modern**: Designed with lessons from decades of CPU evolution
✅ **Growing Ecosystem**: Increasing hardware and software support
✅ **Educational**: Excellent for learning computer architecture

## Prerequisites

- Basic programming knowledge (any language is fine)
- Patience and curiosity!
- No special hardware required (we'll use emulators)

## Learning Path

### Phase 1: Fundamentals (Start Here!)
1. **[Lesson 01: Hello World](./lessons/01-hello-world/)** - Your first RISC-V program
2. **[Lesson 02: Registers and Data](./lessons/02-registers/)** - Understanding registers
3. **[Lesson 03: Arithmetic Operations](./lessons/03-arithmetic/)** - Basic math
4. **[Lesson 04: Memory Operations](./lessons/04-memory/)** - Load and store
5. **[Lesson 05: Control Flow](./lessons/05-control-flow/)** - Branches and jumps

### Phase 2: Intermediate Concepts
6. **[Lesson 06: Functions and Stack](./lessons/06-functions/)** - Calling conventions
7. **[Lesson 07: Multiplication and Division](./lessons/07-mul-div/)** - M extension
8. **[Lesson 08: Bit Manipulation](./lessons/08-bits/)** - Shifts and logic
9. **[Lesson 09: System Calls](./lessons/09-syscalls/)** - Interacting with the OS
10. **[Lesson 10: Arrays and Pointers](./lessons/10-arrays/)** - Data structures

### Phase 3: Advanced Topics
11. **[Lesson 11: Compressed Instructions](./lessons/11-compressed/)** - C extension
12. **[Lesson 12: Atomic Operations](./lessons/12-atomic/)** - A extension
13. **[Lesson 13: Floating Point](./lessons/13-float/)** - F/D extensions
14. **[Lesson 14: Interrupts and Exceptions](./lessons/14-interrupts/)** - CSR registers
15. **[Lesson 15: Bare Metal Programming](./lessons/15-bare-metal/)** - No OS!

## RISC-V Basics

### Register Set (RV32I)

RISC-V has 32 general-purpose registers:

| Register | ABI Name | Purpose | Saved by |
|----------|----------|---------|----------|
| x0 | zero | Always zero | - |
| x1 | ra | Return address | Caller |
| x2 | sp | Stack pointer | Callee |
| x3 | gp | Global pointer | - |
| x4 | tp | Thread pointer | - |
| x5-x7 | t0-t2 | Temporaries | Caller |
| x8 | s0/fp | Saved/Frame pointer | Callee |
| x9 | s1 | Saved register | Callee |
| x10-x11 | a0-a1 | Args/Return values | Caller |
| x12-x17 | a2-a7 | Arguments | Caller |
| x18-x27 | s2-s11 | Saved registers | Callee |
| x28-x31 | t3-t6 | Temporaries | Caller |

**Key registers:**
- **zero (x0)**: Always reads as 0, writes are ignored
- **ra (x1)**: Return address for function calls
- **sp (x2)**: Stack pointer
- **a0-a7 (x10-x17)**: Function arguments and return values
- **t0-t6**: Temporary registers (caller-saved)
- **s0-s11**: Saved registers (callee-saved)

### Instruction Formats

RISC-V instructions are very regular:

**R-Type** (Register-register operations):
```
add  a0, a1, a2    # a0 = a1 + a2
sub  t0, t1, t2    # t0 = t1 - t2
```

**I-Type** (Immediate operations):
```
addi a0, a1, 100   # a0 = a1 + 100
lw   t0, 0(sp)     # t0 = memory[sp + 0]
```

**S-Type** (Store operations):
```
sw   t0, 4(sp)     # memory[sp + 4] = t0
```

**B-Type** (Branches):
```
beq  a0, a1, label # if a0 == a1, goto label
blt  t0, t1, label # if t0 < t1, goto label
```

**U-Type** (Upper immediate):
```
lui  a0, 0x12345   # Load upper immediate
```

**J-Type** (Jumps):
```
jal  ra, function  # Jump and link (call)
```

## Projects

After completing lessons, try these hands-on projects:

1. **[Calculator](./projects/01-calculator/)** - Command-line calculator
2. **[String Library](./projects/02-strings/)** - String manipulation functions
3. **[Sorting Algorithms](./projects/03-sorting/)** - Implement quicksort
4. **[Mini Emulator](./projects/04-emulator/)** - Emulate simple CPU
5. **[Bare Metal LED](./projects/05-bare-metal/)** - Run on real hardware

## Examples

Quick reference examples for common tasks:
- [Basic Operations](./examples/basic-ops.s)
- [Function Calls](./examples/functions.s)
- [System Calls](./examples/syscalls.s)
- [Data Structures](./examples/data-structures.s)

## Setup Guide

Before you start, set up your development environment:
**[→ RISC-V Setup Instructions](./setup.md)**

## Quick Reference

- **[RISC-V Instruction Reference](./reference/instructions.md)** - All base instructions
- **[Register Reference](./reference/registers.md)** - Register conventions
- **[Syscall Reference](./reference/syscalls.md)** - Linux RISC-V syscalls
- **[Calling Conventions](./reference/calling-conventions.md)** - ABI standard

## Comparison with Other Architectures

### RISC-V vs x86
- **RISC-V**: Simple, regular instructions; open standard
- **x86**: Complex instructions (CISC); proprietary but ubiquitous

### RISC-V vs ARM
- **RISC-V**: Open, royalty-free; newer design
- **ARM**: Proprietary, licensing fees; established ecosystem

### RISC-V vs 6502
- **RISC-V**: Modern, 32/64-bit; rich instruction set
- **6502**: Vintage, 8-bit; minimal, elegant

## Tips for Success

1. **Use the emulator** - Test code before hardware
2. **Read the spec** - RISC-V spec is clear and readable
3. **Think in registers** - No hidden state
4. **Follow conventions** - Use standard ABI
5. **Start simple** - Master basics before extensions

## Common Pitfalls

- Forgetting x0 is always zero (can't modify it)
- Not preserving callee-saved registers
- Wrong immediate size (watch sign extension)
- Misaligned memory access (RISC-V requires alignment)
- Confusing pseudo-instructions with real ones

See [Common Mistakes](../resources/common-mistakes.md) for more.

## Hardware Options

Want to run on real hardware?

### Development Boards

**Budget (~$10-30):**
- Sipeed Longan Nano (GD32VF103) - RISC-V microcontroller
- Seeed Studio XIAO ESP32C3 - WiFi + RISC-V

**Mid-Range (~$50-100):**
- HiFive1 Rev B - SiFive RISC-V board
- SparkFun RED-V - Arduino-compatible RISC-V

**High-End (~$200+):**
- BeagleV-Ahead - RISC-V single-board computer
- StarFive VisionFive 2 - Linux-capable RISC-V SBC

### FPGAs

You can also run RISC-V on FPGAs:
- PicoRV32 - Minimal RISC-V core
- NEORV32 - Full-featured RISC-V SoC
- Various Xilinx/Intel FPGA boards

## Resources

### Official Documentation
- [RISC-V Specifications](https://riscv.org/technical/specifications/)
- [RISC-V International](https://riscv.org/)
- [RISC-V Software Status](https://wiki.riscv.org/display/HOME/RISC-V+Software+Status)

### Books
- "The RISC-V Reader" by Patterson & Waterman
- "Computer Organization and Design RISC-V Edition" by Patterson & Hennessy

### Online Resources
- [RISC-V Assembly Programmer's Manual](https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md)
- [RISC-V Online Simulator](https://riscvasm.lucasteske.dev/)

## Need Help?

- Check the [Debugging Tips](../resources/debugging-tips.md)
- Review the [Glossary](../resources/glossary.md)
- Open an issue on GitHub
- Read the RISC-V spec (it's surprisingly readable!)

## Next Steps

Ready to begin? **[Start with Lesson 01: Hello World →](./lessons/01-hello-world/)**

---

*Remember: RISC-V is designed to be simple and elegant. Perfect for learning!* 🚀
