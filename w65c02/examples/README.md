# W65C02 Assembly Examples

This directory contains quick reference examples for W65C02 assembly programming. Each file is a complete, working assembly program that demonstrates common programming tasks and techniques.

## Files

### basic-examples.s
Fundamental W65C02 operations and programming patterns:
- Loading and storing values (immediate, memory, zero page)
- Register transfers (A, X, Y, stack operations)
- Basic arithmetic (addition, subtraction, increment, decrement)
- Logical operations (AND, OR, XOR, bit testing)
- Shift and rotate operations (ASL, LSR, ROL, ROR)
- Basic loops and branches (counting, comparisons)
- Conditional branches (BEQ, BNE, BCC, BCS)
- Simple subroutines (JSR, RTS)
- Indexed addressing modes
- Stack usage patterns

**Examples:** 10 complete code examples with detailed comments

### math-examples.s
Mathematical operations and algorithms:
- 8-bit addition with carry detection
- 16-bit addition (little-endian)
- 8-bit subtraction with borrow detection
- 16-bit subtraction
- Multiplication by powers of 2 (fast shifts)
- 8-bit multiplication (general algorithm)
- Division by powers of 2 (fast shifts)
- 8-bit division (general algorithm)
- BCD arithmetic (addition and subtraction)
- Min/max functions
- Absolute value calculation
- 16-bit increment and decrement
- Average calculation

**Examples:** 16 complete code examples with algorithms

### io-examples.s
Input/Output operations with memory-mapped I/O:
- Simple LED control (on/off, patterns)
- LED pattern generators (running lights)
- Button reading (single and multiple buttons)
- Button debouncing (noise filtering)
- Polling loops (wait for input)
- Character output to memory locations
- Character input from memory locations
- Bit-banging (manual bit control)
- Read-modify-write patterns
- Data direction register setup
- Binary display on LEDs
- Button state machines
- Input with timeout

**Examples:** 14 complete code examples for I/O operations

### hardware-examples.s
Hardware interfacing with 65C22 VIA and LCD displays:
- VIA port configuration (direction registers)
- Basic port I/O operations
- Timer 1 free-running mode
- Timer 1 one-shot mode
- Timer 2 pulse counting
- Square wave generation
- Shift register mode (serial I/O)
- LCD initialization (4-bit mode)
- LCD command and data operations
- LCD string printing
- LCD custom character definition
- Interrupt setup (IRQ configuration)
- IRQ handler implementation
- Edge detection (CA1/CA2)

**Examples:** 15 complete code examples for hardware control

## How to Use

Each file is a standalone assembly program that can be assembled with ca65:

```bash
ca65 basic-examples.s -o basic-examples.o
ld65 basic-examples.o -t none -o basic-examples.bin
```

### Usage Patterns

1. **Learning**: Read through the examples in order to learn various techniques
2. **Reference**: Search for specific examples when you need to implement a feature
3. **Copy & Adapt**: Copy example code into your projects and modify as needed
4. **Testing**: Assemble and test examples to understand behavior

### Example Structure

Each example includes:
- **Clear section headers**: Describes what the example demonstrates
- **Detailed comments**: Explains each instruction and its purpose
- **Register usage**: Documents which registers are used and modified
- **Memory locations**: Shows where data is stored and read
- **Working code**: All examples are complete and functional

## Assembly Syntax

These examples use **ca65 assembler syntax**:

```assembly
.segment "CODE"           ; Define code segment
.org $8000               ; Set origin address

label:
    LDA #$42             ; Load immediate value
    STA $0200            ; Store to memory
    
.segment "VECTORS"       ; Define vector segment
.org $FFFC
.word reset              ; Reset vector
.word $0000              ; NMI vector
```

## Memory Map

Common memory locations used in examples:
- `$0000-$00FF`: Zero page (fast access)
- `$0100-$01FF`: Stack
- `$0200-$07FF`: General RAM (used for data storage in examples)
- `$6000-$600F`: Memory-mapped I/O (VIA, LCD)
- `$8000-$FFFF`: ROM/Program space

## Hardware Assumptions

The examples assume a typical 6502-based system with:
- 1 MHz clock (adjust timer values for different speeds)
- 65C22 VIA at $6000 for I/O
- HD44780-compatible LCD (4-bit mode)
- Memory-mapped I/O for LEDs and buttons

**Note**: Adjust addresses and hardware configurations for your specific system.

## Tips

1. **Start with basic-examples.s** to learn fundamental operations
2. **Use math-examples.s** when you need arithmetic routines
3. **Reference io-examples.s** for input/output patterns
4. **Study hardware-examples.s** for advanced hardware control

## Further Learning

After mastering these examples, explore:
- The lesson files in `../lessons/` for structured tutorials
- The reference documentation in `../reference/` for detailed information
- Real projects that combine multiple techniques

## Contributing

When adding new examples:
- Follow the existing format and comment style
- Include clear section headers
- Provide detailed explanations
- Test that code assembles and works correctly
- Update this README with new examples
