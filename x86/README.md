# x86 Assembly Learning Path 🖥️

Welcome to the x86 Assembly learning path! This is the assembly language used in modern PCs and servers.

## What is x86 Assembly?

x86 is a family of instruction set architectures based on the Intel 8086 CPU. It's what runs on:
- Your desktop or laptop computer
- Servers running Linux/Windows
- Modern operating systems and applications

Learning x86 assembly gives you deep insight into how modern computers work!

## Why Start Here?

Choose the x86 path if you want to:
- Understand how modern operating systems work
- Write system-level software
- Learn about modern CPU features (64-bit, SIMD, etc.)
- Work with existing PC hardware

## Prerequisites

- Basic programming knowledge (any language is fine)
- A computer running Linux, Windows, or macOS
- Patience and curiosity!

## Learning Path

### Phase 1: Fundamentals (Start Here!)
1. **[Lesson 01: Hello World](./lessons/01-hello-world/)** - Your first x86 program
2. **[Lesson 02: Registers and Data](./lessons/02-registers/)** - Understanding CPU registers
3. **[Lesson 03: Arithmetic Operations](./lessons/03-arithmetic/)** - Basic math in assembly
4. **[Lesson 04: Memory and Addressing](./lessons/04-memory/)** - Working with RAM
5. **[Lesson 05: Control Flow](./lessons/05-control-flow/)** - Jumps and loops

### Phase 2: Intermediate Concepts
6. **[Lesson 06: Functions and Stack](./lessons/06-functions/)** - Calling conventions
7. **[Lesson 07: String Operations](./lessons/07-strings/)** - Text manipulation
8. **[Lesson 08: Arrays and Structures](./lessons/08-arrays/)** - Complex data types
9. **[Lesson 09: System Calls](./lessons/09-syscalls/)** - Interacting with the OS
10. **[Lesson 10: File I/O](./lessons/10-file-io/)** - Reading and writing files

### Phase 3: Advanced Topics
11. **[Lesson 11: 64-bit Programming](./lessons/11-64bit/)** - x86-64 architecture
12. **[Lesson 12: Optimization Techniques](./lessons/12-optimization/)** - Writing fast code
13. **[Lesson 13: SIMD Instructions](./lessons/13-simd/)** - Parallel processing
14. **[Lesson 14: Interfacing with C](./lessons/14-c-interface/)** - Mixed language programming
15. **[Lesson 15: Debugging](./lessons/15-debugging/)** - Using GDB and other tools

## Projects

After completing lessons, try these hands-on projects:

1. **[Calculator](./projects/01-calculator/)** - Command-line calculator
2. **[File Encryption](./projects/02-encryption/)** - Simple XOR cipher
3. **[Mini Shell](./projects/03-shell/)** - Basic command interpreter
4. **[Snake Game](./projects/04-snake/)** - Text-based game
5. **[Bootloader](./projects/05-bootloader/)** - Boot from USB (advanced!)

## Examples

Quick reference examples for common tasks:
- [Input/Output Examples](./examples/io-examples.asm)
- [Math Examples](./examples/math-examples.asm)
- [String Examples](./examples/string-examples.asm)
- [Syscall Examples](./examples/syscall-examples.asm)

## Setup Guide

Before you start, set up your development environment:
**[→ x86 Setup Instructions](./setup.md)**

## Quick Reference

- **[x86 Instruction Reference](./reference/instructions.md)** - Common instructions
- **[Register Reference](./reference/registers.md)** - All x86 registers
- **[Syscall Reference](./reference/syscalls.md)** - Linux system calls
- **[Calling Conventions](./reference/calling-conventions.md)** - Function calling

## Tips for Success

1. **Type the code yourself** - Don't just copy-paste
2. **Experiment** - Change values, see what breaks
3. **Use the debugger** - GDB is your friend
4. **Read error messages** - They tell you what's wrong
5. **Take breaks** - Assembly can be intense!

## Common Pitfalls

- Forgetting to link your programs
- Wrong system call numbers
- Stack alignment issues (especially on macOS)
- Mixing 32-bit and 64-bit instructions

See [Common Mistakes](../resources/common-mistakes.md) for more.

## Need Help?

- Check the [Debugging Tips](../resources/debugging-tips.md)
- Review the [Glossary](../resources/glossary.md)
- Open an issue on GitHub
- Read the error message carefully!

## Next Steps

Ready to begin? **[Start with Lesson 01: Hello World →](./lessons/01-hello-world/)**

---

*Remember: Start simple, build up gradually. You've got this!* 💪
