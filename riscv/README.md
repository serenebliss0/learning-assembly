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

**Budget (~$10-$30):**
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

## Running RISC-V Code on Real Hardware

Ready to move beyond simulation? Here's a complete guide to running your RISC-V assembly on actual hardware!

### Development Environment Setup

#### 1. Install RISC-V Toolchain

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```

**macOS:**
```bash
brew install riscv-gnu-toolchain
```

**From Source:**
```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
make
```

#### 2. Install Programming Tools

**For Longan Nano (DFU):**
```bash
sudo apt-get install dfu-util
```

**For ESP32-C3:**
```bash
pip install esptool
```

**For SiFive boards (OpenOCD):**
```bash
sudo apt-get install openocd
```

### Getting Started with Different Boards

#### Sipeed Longan Nano ($5-10)

**Specs:**
- RISC-V GD32VF103 @ 108 MHz
- 32KB SRAM, 128KB Flash
- Built-in RGB LED, USB-C
- Arduino-compatible headers

**Quick Start:**

1. **Write your code** (`blink.s`):
```assembly
.section .text
.globl _start
_start:
    li t0, 0x40010C00      # GPIO base
    li t1, 0x00300000      # Configure output
    sw t1, 0(t0)
loop:
    li t1, 0x20
    sw t1, 12(t0)          # LED on
    call delay
    sw zero, 12(t0)        # LED off
    call delay
    j loop
delay:
    li t0, 1000000
1:  addi t0, t0, -1
    bnez t0, 1b
    ret
```

2. **Assemble and link:**
```bash
riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 -o blink.o blink.s
riscv64-unknown-elf-ld -T linker.ld -o blink.elf blink.o
riscv64-unknown-elf-objcopy -O binary blink.elf blink.bin
```

3. **Flash to board:**
```bash
# Hold BOOT button, press RESET, release BOOT
dfu-util -a 0 -s 0x08000000:leave -D blink.bin
```

**Resources:**
- [Longan Nano Datasheet](https://dl.sipeed.com/shareURL/LONGAN/Nano)
- [GD32VF103 User Manual](https://www.gigadevice.com/products/microcontrollers/gd32/risc-v/)

#### ESP32-C3 ($5-10)

**Specs:**
- RISC-V @ 160 MHz
- WiFi + Bluetooth
- 400KB SRAM, 4MB Flash
- USB-C programming

**Quick Start:**

1. **Install ESP-IDF:**
```bash
git clone --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh esp32c3
. ./export.sh
```

2. **Create project and write assembly code**

3. **Build and flash:**
```bash
idf.py build
idf.py -p /dev/ttyUSB0 flash
idf.py -p /dev/ttyUSB0 monitor
```

**Resources:**
- [ESP32-C3 Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/)
- [Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf)

#### HiFive1 Rev B / SparkFun RED-V ($60)

**Specs:**
- SiFive FE310 @ 320 MHz
- 16KB SRAM, 4MB Flash
- Professional quality
- Arduino IDE support

**Quick Start:**

1. **Using Freedom E SDK:**
```bash
git clone https://github.com/sifive/freedom-e-sdk.git
cd freedom-e-sdk
# Follow their documentation
```

2. **Using Arduino IDE:**
- Install SiFive board support
- Write code in Arduino IDE
- Upload via USB

**Resources:**
- [HiFive1 Getting Started](https://www.sifive.com/boards/hifive1-rev-b)
- [Freedom E SDK](https://github.com/sifive/freedom-e-sdk)

### Bare Metal Programming Workflow

#### Memory Map

Understanding your board's memory layout is crucial:

**Typical RISC-V Microcontroller:**
```
0x00000000 - 0x0001FFFF : Flash (program memory)
0x20000000 - 0x20007FFF : SRAM (data memory)
0x40000000 - 0x5FFFFFFF : Peripherals (GPIO, UART, etc.)
```

#### Linker Script

Every bare metal program needs a linker script (`linker.ld`):

```ld
MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 32K
}

SECTIONS
{
    .text : {
        KEEP(*(.text._start))
        *(.text*)
    } > FLASH
    
    .rodata : { *(.rodata*) } > FLASH
    .data : { *(.data*) } > RAM AT > FLASH
    .bss : { *(.bss*) } > RAM
    
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
```

#### Startup Code

Minimal startup code to initialize the processor:

```assembly
.section .text._start
.globl _start

_start:
    # Set up stack pointer
    la sp, _stack_top
    
    # Zero the BSS section
    la t0, _bss_start
    la t1, _bss_end
bss_loop:
    bge t0, t1, bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j bss_loop
bss_done:
    
    # Copy .data section from flash to RAM
    la t0, _data_load
    la t1, _data_start
    la t2, _data_end
data_loop:
    bge t1, t2, data_done
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j data_loop
data_done:
    
    # Call main
    jal ra, main
    
    # Infinite loop if main returns
halt:
    j halt
```

#### GPIO Control

Example of controlling GPIO (LED):

```assembly
# For GD32VF103 (Longan Nano)
.equ GPIOB_BASE, 0x40010C00
.equ GPIO_CTL0,  0x00          # Configuration register
.equ GPIO_OCTL,  0x0C          # Output control register

init_led:
    li t0, GPIOB_BASE
    li t1, 0x00300000          # Configure PB5 as output
    sw t1, GPIO_CTL0(t0)
    ret

led_on:
    li t0, GPIOB_BASE
    li t1, (1 << 5)
    sw t1, GPIO_OCTL(t0)
    ret

led_off:
    li t0, GPIOB_BASE
    sw zero, GPIO_OCTL(t0)
    ret
```

### Debugging on Hardware

#### Serial Output (UART)

Add debug output via UART:

```assembly
# Initialize UART
init_uart:
    li t0, USART0_BASE
    li t1, 0x0C             # 115200 baud, 8N1
    sw t1, USART_BRR(t0)
    li t1, 0x2008           # Enable TX
    sw t1, USART_CR1(t0)
    ret

# Print character
putchar:
    li t0, USART0_BASE
1:  lw t1, USART_SR(t0)
    andi t1, t1, 0x80       # Wait for TXE
    beqz t1, 1b
    sb a0, USART_DR(t0)
    ret
```

#### Using OpenOCD + GDB

For boards with JTAG/SWD:

```bash
# Terminal 1: Start OpenOCD
openocd -f interface/jlink.cfg -f target/riscv32.cfg

# Terminal 2: Start GDB
riscv64-unknown-elf-gdb program.elf
(gdb) target remote :3333
(gdb) load
(gdb) break main
(gdb) continue
```

### Common Hardware Pitfalls

1. **Misaligned Access**: RISC-V requires aligned memory access
   - ❌ `lw t0, 1(sp)` (not aligned)
   - ✅ `lw t0, 0(sp)` (aligned to 4 bytes)

2. **Incorrect Pin Configuration**: Check datasheet for GPIO modes

3. **Clock Configuration**: Some boards need clock initialization

4. **Power Supply**: Ensure adequate power for peripherals

5. **Wrong Memory Addresses**: Double-check peripheral base addresses

### Performance Tips

1. **Use compressed instructions (C extension)** - Smaller code, better cache usage
2. **Enable instruction cache** if available
3. **Optimize critical loops** - Minimize memory access
4. **Use DMA** for bulk data transfers
5. **Profile with hardware timers** - Measure actual execution time

### Complete Example Project

See **[Project 5: Bare Metal LED](./projects/05-bare-metal/)** for:
- Complete working code for multiple boards
- Detailed build instructions
- Linker scripts
- Startup code
- GPIO control examples
- Troubleshooting guide

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
