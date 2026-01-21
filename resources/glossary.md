# Assembly Language Glossary

Quick reference for assembly language terms. Listed alphabetically.

## A

**Accumulator**: Main register for arithmetic operations. In 6502, this is the A register.

**Address**: Location in memory where data is stored. Usually written in hexadecimal (e.g., $8000).

**Addressing Mode**: Method used to specify where data is located (immediate, absolute, indexed, etc.).

**Assembler**: Program that converts assembly code into machine code.

**Assembly Language**: Low-level programming language with human-readable instructions that correspond directly to machine code.

## B

**Binary**: Base-2 number system using only 0 and 1.

**Bit**: Single binary digit (0 or 1).

**Branch**: Instruction that changes program flow based on a condition.

**Byte**: 8 bits. Can represent values 0-255 (unsigned) or -128 to 127 (signed).

**Bus**: Set of wires that carry data, addresses, or control signals.

## C

**Carry Flag**: Status bit indicating arithmetic overflow or borrow.

**Clock**: Signal that synchronizes CPU operations.

**CPU**: Central Processing Unit - the "brain" of the computer.

**Cycle**: One tick of the CPU clock.

## D

**Debugger**: Tool for examining and controlling program execution.

**Directive**: Instruction to the assembler (not CPU instruction). Examples: `.byte`, `.word`, `section`.

**Displacement**: Offset added to an address in relative addressing.

## E

**Endianness**: Order bytes are stored in memory. Little-endian (low byte first) vs Big-endian (high byte first).

**EEPROM**: Electrically Erasable Programmable Read-Only Memory.

## F

**Flag**: Single bit in the status register indicating a condition.

**Frame Pointer**: Register pointing to the current stack frame.

## H

**Hexadecimal**: Base-16 number system. Often prefixed with 0x or $.

**High Byte**: Most significant byte of a multi-byte value.

## I

**Immediate**: Addressing mode where the value is part of the instruction itself.

**Instruction**: Single operation the CPU can perform.

**Interrupt**: Signal that temporarily stops normal execution to handle an event.

**I/O**: Input/Output - communication with external devices.

## J

**Jump**: Unconditional change in program flow (go to another address).

## L

**Label**: Named location in assembly code that becomes an address.

**Linker**: Program that combines assembled code into executable.

**Little-endian**: Storing least significant byte first.

**Low Byte**: Least significant byte of a multi-byte value.

## M

**Machine Code**: Binary instructions that CPU directly executes.

**Memory Map**: Organization of memory showing what each region is used for.

**Mnemonic**: Human-readable name for an instruction (e.g., MOV, ADD).

## N

**NASM**: Netwide Assembler - popular x86 assembler.

**Negative Flag**: Status bit indicating result was negative.

**NOP**: No Operation - instruction that does nothing (used for timing/alignment).

## O

**Opcode**: Operation code - the binary code for an instruction.

**Operand**: Value or location an instruction operates on.

**Overflow Flag**: Indicates signed arithmetic overflow.

## P

**PC**: Program Counter - register holding address of next instruction.

**Pointer**: Value that holds a memory address.

**Push/Pop**: Operations to add/remove data from stack.

## R

**RAM**: Random Access Memory - read/write memory.

**Register**: Small, fast storage location inside the CPU.

**ROM**: Read-Only Memory - permanent storage.

**RTS/RET**: Return from Subroutine - ends a function.

## S

**Section**: Organized part of program (code, data, bss).

**Segment**: Memory region with specific purpose.

**Sign Flag**: Indicates if result is negative (most significant bit).

**Stack**: LIFO (Last In, First Out) memory structure.

**Stack Pointer**: Register pointing to top of stack.

**Status Register**: Register containing CPU flags.

**Subroutine**: Callable piece of code (like a function).

**Syscall**: System call - requesting OS service.

## T

**Two's Complement**: Method for representing signed integers.

## W

**Word**: 2 bytes (16 bits) on most systems. Sometimes 4 bytes on 32-bit systems.

## X

**XOR**: Exclusive OR - logical operation.

## Z

**Zero Flag**: Status bit indicating result was zero.

**Zero Page**: First 256 bytes of memory (6502). Faster to access.

---

## Size Reference

| Term | Bits | Bytes | Range (unsigned) |
|------|------|-------|------------------|
| Bit | 1 | - | 0-1 |
| Nibble | 4 | - | 0-15 |
| Byte | 8 | 1 | 0-255 |
| Word | 16 | 2 | 0-65535 |
| Dword | 32 | 4 | 0-4294967295 |
| Qword | 64 | 8 | 0-18446744073709551615 |

## Number Systems Quick Reference

| Decimal | Binary | Hex | Octal |
|---------|--------|-----|-------|
| 0 | 0000 | 0 | 0 |
| 1 | 0001 | 1 | 1 |
| 10 | 1010 | A | 12 |
| 15 | 1111 | F | 17 |
| 16 | 10000 | 10 | 20 |
| 255 | 11111111 | FF | 377 |

## Common Prefixes

- **0x** or **$**: Hexadecimal (0x10 = 16)
- **0b** or **%**: Binary (0b1010 = 10)
- **#**: Immediate value (6502)
- **%**: Register (AT&T syntax)

---

Need more detail on any term? Check the specific lesson or reference guide!
