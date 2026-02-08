# Lesson 15: Building a Monitor/Debugger - Summary

## Overview
This lesson teaches students how to build a complete interactive monitor/debugger for RISC-V systems. It covers both theory and practice of system-level debugging tools.

## Files Created

### README.md (1,120 lines)
Comprehensive educational content covering:
- What monitors and debuggers are
- Monitor architecture and design
- Command-line interface principles
- Memory inspection techniques
- Register manipulation
- Breakpoint mechanisms (software and hardware)
- Single-stepping implementation
- Command parsing strategies
- Complete working examples
- 4 hands-on experiments
- 4 deep dive topics
- Common mistakes and fixes
- Advanced features
- Resources for further learning

### monitor.s (17KB)
Complete working monitor with:
- Interactive command loop
- Command tokenizer and dispatcher
- Memory commands (dump, examine, write)
- Hex parsing and printing utilities
- ASCII display for memory
- Help system
- Proper error handling
- Clean, educational code structure

### commands.s (18KB)
Advanced command parser featuring:
- Command lookup table system
- Case-insensitive matching
- Argument validation
- Advanced memory operations (fill, compare, copy, search)
- Instruction disassembler
- Overlap detection for memory copy
- Extensible design

## Key Learning Outcomes

Students will learn:
1. How debuggers like GDB work internally
2. Building interactive command-line interfaces
3. Memory inspection and manipulation techniques
4. String parsing in assembly
5. Software vs hardware breakpoints
6. Instruction decoding
7. Bare-metal systems programming

## Educational Approach

- Follows established lesson structure (like lessons 11-14)
- Theory explained clearly with diagrams
- Complete working code examples
- Hands-on experiments for practice
- Deep dives for advanced students
- Common mistakes section for debugging
- Professional coding style and comments

## Technical Highlights

- Pure RISC-V RV32I assembly
- Linux system calls for I/O
- Modular design (monitor + commands)
- Proper stack usage
- Error handling throughout
- Educational comments
- Production-quality code structure

This lesson completes the RISC-V assembly course, giving students the tools to debug and understand systems at the lowest level.
